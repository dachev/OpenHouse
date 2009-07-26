#!/usr/bin/env python
import sys
import urllib
import libxml2
import re
import locale
import Queue
import json
import time
from datetime import datetime, timedelta
from dateutil import parser
from sqlalchemy import Table, Column, DateTime, MetaData, text, create_engine
from sqlalchemy.pool import NullPool
from ThreadUrl import ThreadUrl

SEARCH_BASE = 'http://base.google.com/base/feeds/snippets'
IMAGE_BASE  = 'http://localhost/service/image/resize.png'
Houses = Images = engine = None

def search(req):
    global Houses, engine

    # initialize response
    req.content_type = 'application/json'
    response = {'success':False, 'msg': ''}

    # initialize DB
    init_db()

    # parse arguments
    try:
        lat      = float(req.form.getfirst('lat', ''))
        lng      = float(req.form.getfirst('lng', ''))
        distance = float(req.form.getfirst('distance', 50))
        offset   = int(req.form.getfirst('offset', ''))
        records  = int(req.form.getfirst('records', ''))
        bdate    = extractDates(req.form.getfirst('bdate', ''))
        edate    = extractDates(req.form.getfirst('edate', ''))
        if len(bdate) != 1:
            raise Exception('bdate is missing or invalid')
        if len(edate) != 1:
            raise Exception('edate is missing or invalid')
        if offset < 1:
            raise Exception('offset must be an integer larger than 1')
        if records < 1 or records > 250:
            raise Exception('records must be an integer between 1 and 250')
    except Exception as e:
        response['msg'] = e.message
        req.write(json.dumps(response));
        return
    
    response = {'success':True, 'total':0, 'offset':offset, 'houses':[]}
    total    = count_houses(lat, lng, distance, bdate[0], edate[0])
    
    response['total'] = total
    if total > 0:
        houses = get_houses(lat, lng, distance, bdate[0], edate[0], offset, records)
        response['houses'] = houses

    # write response
    req.write(json.dumps(response))

def update(req):
    global Houses, Images, engine

    # initialize DB
    init_db()

    # perform action
    action = req.form.getfirst('action', '')
    if action == 'houses':
        houses_action()
    elif action == 'images':
        images_action()
    elif action == 'cleanup':
        cleanup_action()

def houses_action():
    global Houses, Images
    
    html    = ''
    offset  = 1
    page    = 20
    startdt = datetime.today() + timedelta(+1)
    startdt = datetime(startdt.year, startdt.month, startdt.day)
    qparts  = [
        '[item type:housing]',
        '[listing status:active]',
        '([listing type:for sale]|[listing type:foreclosure])',
        '[target country:US]',
        '[open house date range:%s..2100-07-20]' % startdt.strftime("%Y-%m-%d"),
        '[location]'
    ]
    query = ''.join(map(str, qparts))

    # query the API
    while (True):
        args = {
            'bq'          : query,
            'content'     : 'geocodes',
            'max-results' : page,
            'orderby'     : 'modification_time',
            'sortorder'   : 'ascending',
            'alt'         : 'atom',
            'start-index' : offset
        }
        url = SEARCH_BASE + '?' + urllib.urlencode(args)
        xml = urllib.urlopen(url).read()
        doc = libxml2.parseDoc(xml)
    
        ctxt = doc.xpathNewContext()
        ctxt.xpathRegisterNs('atom', 'http://www.w3.org/2005/Atom')
        ctxt.xpathRegisterNs('g', 'http://base.google.com/ns/1.0')
        entries = ctxt.xpathEval('//atom:entry')
        offset += len(entries)
        
        for entry in entries:
            ctxt.setContextNode(entry)
            housedata = parse(ctxt)

            if housedata == None:
                continue

            houses = Houses.select(Houses.c.gbid==housedata['gbid']).execute()
            if houses.fetchone():
                houses.close()
                continue
            houses.close()
            
            ids = Houses.insert().execute(housedata).last_inserted_ids()
            if len(ids) !=1:
                continue

            if type(housedata['imglinks']) != list:
                continue

            hid = ids[0]
            housedata['imglinks'].sort()
            for imglink in housedata['imglinks']:
                imgdata = {'hid':hid, 'url':imglink, 'thumb':0,'attempted':0}
                if imglink == housedata['imglinks'][0]:
                    imgdata['thumb'] = 1
                
                Images.insert().execute(imgdata)

        doc.freeDoc()
        ctxt.xpathFreeContext()

        if len(entries) < 1:
            break

def images_action():
    global Houses, Images

    queue = Queue.Queue()
    for i in range(5):
        t = ThreadUrl(queue)
        t.setDaemon(True)
        t.start()
    
    condition = Images.c.attempted==0
    images    = Images.select(condition).execute()
    for image in images:
        args = {
            'size'     : 'f',
            'location' : image['url'],
        }

        # fetch full-size image
        url = IMAGE_BASE + '?' + urllib.urlencode(args)
        queue.put(url)

        # fetch thumbnail
        if image['thumb'] == 1:
            args['size'] = 't'
            url = IMAGE_BASE + '?' + urllib.urlencode(args)
            queue.put(url)

        # set DB flag
        condition = Images.c.id == image['id']
        Images.update().where(condition).values(attempted=1).execute()

    queue.join()
    images.close()

def cleanup_action():
    now    = datetime.today()
    houses = Houses.select(Houses.c.edate<now).execute()
    for house in houses:
        Images.delete(Images.c.hid==house['id']).execute()
        Houses.delete(Houses.c.id==house['id']).execute()

    houses.close()
    # TODO: Call image server and delete photos

def init_db():
    global Houses, Images, engine
    
    engine = create_engine('mysql://blago:F$USA&4?sE@localhost:3306/openhouses', poolclass=NullPool)
    meta = MetaData()
    meta.bind = engine
    meta.create_all()
    Images = Table('images', meta, autoload=True)
    Houses = Table('houses', meta,
                   Column('bdate', DateTime(timezone=False)),
                   Column('edate', DateTime(timezone=False)),
                   Column('expdate', DateTime(timezone=False)),
                   autoload=True)

def count_houses(lat, lng, distance, bdate, edate):
    global Houses, engine

    # initialize DB
    init_db()

    # load data from the DB
    houses = []
    sql    = text("""
        SELECT count(*)
        FROM houses
        WHERE (3959 * ACOS(SIN(RADIANS(:alat)) * SIN(RADIANS(lat)) + COS(RADIANS(:alat)) * COS(RADIANS(lat)) * COS(RADIANS(lng) - RADIANS(:alng)))) < :adistance
        AND bdate > :abdate
        AND edate < :aedate
    """)
    results = engine.execute(sql, alat=lat, alng=lng, abdate=bdate, aedate=edate, adistance=distance)
    total   = results.fetchone()[0]
    results.close()

    return total

def get_houses(lat, lng, distance, bdate, edate, offset, records):
    global Houses, engine

    # initialize DB
    init_db()

    # load house data from the DB
    sql = text("""
    
        SELECT h.*, i.url FROM (
            SELECT *, (3959 * ACOS(SIN(RADIANS(:alat)) * SIN(RADIANS(lat)) + COS(RADIANS(:alat)) * COS(RADIANS(lat)) * COS(RADIANS(lng) - RADIANS(:alng)))) AS distance
            FROM houses
            WHERE bdate > :abdate
            AND edate < :aedate
            HAVING distance < :adistance
            ORDER BY distance
            LIMIT :aoffset, :arecords
        ) AS h
        LEFT JOIN images AS i
        ON h.id = i.hid
        ORDER BY h.distance, h.id ASC, i.thumb DESC
    """)
    results = engine.execute(sql, alat=lat, alng=lng, abdate=bdate, aedate=edate, aoffset=offset-1, arecords=records, adistance=distance)

    # generate column list
    keys = []
    for c in Houses.c:
        keys.append(c.name)
    keys.append('distance')
    keys.append('url')

    # create row dictionaries
    rows = []
    for result in results:
        vals = []
        for c in result:
            val = c
            if type(val) == datetime:
                val = int(time.mktime(c.timetuple()))
            vals.append(val)
        house = dict(zip(keys, vals))
        
        hid = str(house['id'])
        rows.append(house);
        
    results.close()
    
    # normalize results
    last_hid = 0
    houses   = []
    for row in rows:
        if row['id'] != last_hid:
            row['images'] = []
            houses.append(row)
            last_hid = row['id']
            
        if row['url'] != None:
            houses[-1]['images'].append(row['url'])
            del row['url']

    return houses

def parse(ctxt):
    entry = {
        'gbid'        : {'sel':'atom:id[1]', 'val':[]},
        'price'       : {'sel':'g:price[1]', 'val':[]},
        'drange'      : {'sel':'g:open_house_date_range[1]', 'val':[]},
        'description' : {'sel':'atom:content[1]', 'val':[]},
        'expdate'     : {'sel':'g:expiration_date[1]', 'val':[]},
        'ptaxes'      : {'sel':'g:property_taxes[1]', 'val':[]},
        'hoa'         : {'sel':'g:hoa_dues[1]', 'val':[]},
        'bathrooms'   : {'sel':'g:bathrooms[1]', 'val':[]},
        'bedrooms'    : {'sel':'g:bedrooms[1]', 'val':[]},
        'area'        : {'sel':'g:area[1]', 'val':[]},
        'lot'         : {'sel':'g:lot_size[1]', 'val':[]},
        'year'        : {'sel':'g:year[1]', 'val':[]},
        'ptype'       : {'sel':'g:property_type[1]', 'val':[]},
        'pclass'      : {'sel':'g:provider_class[1]', 'val':[]},
        'zoning'      : {'sel':'g:zoning[1]', 'val':[]},
        'school'      : {'sel':'g:school[1]', 'val':[]},
        'schoold'     : {'sel':'g:school_district[1]', 'val':[]},
        'mlsname'     : {'sel':'g:mls_name[1]', 'val':[]},
        'mlsid'       : {'sel':'g:mls_listing_id[1]', 'val':[]},
        'imglinks'    : {'sel':'g:image_link', 'val':[]},
        'broker'      : {'sel':'g:broker[1]', 'val':[]},
        'agent'       : {'sel':'g:agent[1]', 'val':[]},
        'ltype'       : {'sel':'g:listing_type[1]', 'val':[]},
        'model'       : {'sel':'g:model[1]', 'val':[]},
        'style'       : {'sel':'g:style[1]', 'val':[]},
        'lat'         : {'sel':'g:location/g:latitude[1]', 'val':[]},
        'lng'         : {'sel':'g:location/g:longitude[1]', 'val':[]},
        'addr'        : {'sel':'g:location/text()', 'val':[]},
        'floor'       : {'sel':'g:floor_number[1]', 'val':[]},
        'parking'     : {'sel':'g:parking[1]', 'val':[]}
    }

    # parse XML and populate structure
    for k,v in entry.iteritems():
        for node in ctxt.xpathEval(v['sel']):
            v['val'].append(node.content)

    # ensure val length>0
    for k,v in entry.iteritems():
        if len(v['val']) == 0:
            v['val'].append('')

    entry['price']['val'][0]  = formatPrice(entry['price']['val'][0])
    entry['ptaxes']['val'][0] = formatPrice(entry['ptaxes']['val'][0])
    entry['hoa']['val'][0]    = formatPrice(entry['hoa']['val'][0])
    entry['expdate']['val']   = extractDates(entry['expdate']['val'][0])
    entry['drange']['val']    = extractDates(entry['drange']['val'][0])
    
    # flatten the structure
    for k,v in entry.iteritems():
        if len(v['val']) == 1:
            v['val'] = v['val'][0]

    # create final structure
    item = {}
    for k,v in entry.iteritems():
        item[k] = v['val']
    
    # break up and delete the range array
    item['bdate'] = None
    item['edate'] = None
    if type(item['drange']) == list:
        bdate         = item['drange'][0]
        edate         = item['drange'][1]
        if edate.hour == 0:
            edate = datetime(edate.year, edate.month, edate.day, 23, 59, 59)
        item['bdate'] = bdate
        item['edate'] = edate
    else:
        bdate         = item['drange']
        edate         = datetime(bdate.year, bdate.month, bdate.day, 23, 59, 59)
        item['bdate'] = bdate
        item['edate'] = edate
    del item['drange']

    # validate data
    if type(item['gbid']) != str or item['gbid'] == '':
        return None
    if type(item['addr']) != str or item['addr'] == '':
        return None
    if item['lat'] == '' or item['lng'] == '':
        return None
    if type(item['bdate']) != datetime:
        return None

    # type conversion for lat, lng
    item['lat'] = float(item['lat'])
    item['lng'] = float(item['lng'])
    
    return item

def formatPrice(price):
    p = ''
    
    if price == '': return p

    regex = re.compile('[^0-9\.]')
    price = regex.sub('', price)
    if price == '' or price == '.':
        return p

    locale.setlocale(locale.LC_ALL, '')
    p = '$' + locale.format('%.2f', float(price), 1)

    return p

def extractDates(date):
    d = []

    if date == '': return d
    
    dates = date.split(' ')
    if len(dates) < 1 or dates[0] == '':
        return d

    try:
        for date in dates:
            d.append(parser.parse(date))
    except:
        print(date)
        return []

    return d

def usage(command):
    report('Usage: ' + command + ' houses|images|cleanup')


if __name__ == "__main__":
    if len(sys.argv) < 2:
        usage(sys.argv[0])
        sys.exit(0)

    # initialize DB
    init_db()

    # perform action
    action = sys.argv[1]
    if action == 'houses':
        houses_action()
    elif action == 'images':
        images_action()
    elif action == 'cleanup':
        cleanup_action()

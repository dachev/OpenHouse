//
//  Constants.h
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

/* Request URLs */
#define OPEN_HOUSES_REQUEST_QUERY @"[item type:housing][listing status:active][listing type:for sale][target country:US][open house date range:%@..%@][location:@%+08.4f%+09.4f+50mi]"
#define IMAGE_API_REQUEST_URL @"http://openhouse.dachev.com/service/image/resize.jpg?size=%@&location=%@"
#define SEARCH_API_REQUEST_URL @"http://openhouse.dachev.com/~blago/openhouse/service.py/search?offset=%d&records=%d&lat=%f&lng=%f&distance=%f&bdate=%@&edate=%@"
#define STATIC_MAPS_REQUEST_URL @"http://maps.google.com/maps/api/staticmap?center=%f,%f&zoom=15&size=310x233&maptype=roadmap&markers=color%@blue%@label%@%@%f,%f&sensor=true"
#define GOOGLE_GEOCODING_URL @"http://maps.google.com/maps/api/geocode/json?sensor=true&region=us&address=%@"

#define RESULTS_PER_PAGE_DISPLAY 10
#define RESULTS_PER_PAGE_FETCH 50

#define OPEN_HOUSE_DATE_RANGE @"yyyy-MM-dd'T'HH:mm:ss"
#define OPEN_HOUSE_DATE_DATE @"EEEE MMMM d"
#define OPEN_HOUSE_DATE_TIME @"hh:mm aaa"
#define LOCATION_HISTORY_DATETIME @"hh:mm aaa, EEEE MMMM d"

/* Dick cache */
#define DISK_CACHE_MAX_SIZE 1024*1024*20;

/* DB */
#define DB_NAME @"openhouses.db"

/* Misc config */
#define CONFIG_NETWORK_TIMEOUT 10
#define CONFIG_PAGE_VIEW_HEIGHT 253
#define CONFIG_SEARCH_DISTANCE 50.0f

/* Flurry */
#define ANALYTICS_API_KEY @"H2S9NJ6VW43CXGKY26LT"
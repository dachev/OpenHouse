//
//  Constants.h
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

/* Request URLs */
//@"[item type:housing][open house date range:2009-05-26..2009-05-30][location:@\"minneapolis,MN,USA\"+10mi]"
//@"[item type:housing][open house date range:2009-05-27..2009-05-31][location:@+44.97614-093.27704+50mi]"
//@"[item type:housing][open house date range:2009-05-27..2009-05-31][location: @+40.5-090.5..@+44-095.27704]"
#define OPEN_HOUSES_REQUEST_QUERY @"[item type:housing][listing status:active][listing type:for sale][target country:US][open house date range:%@..%@][location:@%+08.4f%+09.4f+50mi]"
#define IMAGE_API_REQUEST_URL @"http://localhost/service/image/resize.png?size=%@&location=%@"
#define SEARCH_API_REQUEST_URL @"http://localhost/~blago/openhouses/service.py/search?offset=%d&records=%d&lat=%f&lng=%f&bdate=%@&edate=%@"

#define RESULTS_PER_PAGE_DISPLAY 10
#define RESULTS_PER_PAGE_FETCH 100

#define OPEN_HOUSE_DATE_RANGE @"yyyy-MM-dd'T'HH:mm:ss"
//#define OPEN_HOUSE_DATE_DAY @"MM/dd/yyyy"
#define OPEN_HOUSE_DATE_DATE @"EEEE MMMM d"
#define OPEN_HOUSE_DATE_TIME @"hh:mm aaa"

/* Misc config */
#define CONFIG_NETWORK_TIMEOUT 10
#define CONFIG_PAGE_VIEW_HEIGHT 253

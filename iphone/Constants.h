//
//  Constants.h
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

/* Request URLs */
#define OPEN_HOUSES_REQUEST_QUERY @"[item type:housing][listing status:active][listing type:for sale][target country:US][open house date range:%@..%@][location:@%+08.4f%+09.4f+50mi]"
#define IMAGE_API_REQUEST_URL @"http://localhost/service/image/resize.png?size=%@&location=%@"
#define SEARCH_API_REQUEST_URL @"http://blago.dachev.com/~blago/openhouses/service.py/search?offset=%d&records=%d&lat=%f&lng=%f&distance=%f&bdate=%@&edate=%@"
#define STATIC_MAPS_REQUEST_URL @"http://maps.google.com/staticmap?center=%f,%f&zoom=15&size=310x233&maptype=mobile&markers=%f,%f,red&sensor=false"

#define RESULTS_PER_PAGE_DISPLAY 10
#define RESULTS_PER_PAGE_FETCH 50

#define OPEN_HOUSE_DATE_RANGE @"yyyy-MM-dd'T'HH:mm:ss"
#define OPEN_HOUSE_DATE_DATE @"EEEE MMMM d"
#define OPEN_HOUSE_DATE_TIME @"hh:mm aaa"

/* Misc config */
#define CONFIG_NETWORK_TIMEOUT 10
#define CONFIG_PAGE_VIEW_HEIGHT 253
#define CONFIG_SEARCH_DISTANCE 50.0f

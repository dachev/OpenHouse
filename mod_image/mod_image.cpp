/* Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <string>
#include <map>
#include <vector>

#include "httpd.h"
#include "http_config.h"
#include "http_protocol.h"
#include "http_log.h"

#include <math.h>
#include <boost/algorithm/string.hpp>
#include <Magick++.h>
#include <QUrl>
#include "curl/curl.h"
#include "UrlLibrary.h"
#include "md5wrapper.h"

#define THUMBNAIL_HORIZONTAL_SIDE 50
#define FULL_HORIZONTAL_SIDE 310
#define FULL_VERTICAL_SIDE 233

using namespace std;
using namespace boost;
using namespace Magick;

extern "C" module AP_MODULE_DECLARE_DATA image_module;

typedef vector< string > split_vector_type;

typedef struct {
    char* command;
} image_module_dir_config_t;

apr_status_t send_local_file(const string *full_path, request_rec *r) {
    apr_file_t *fd;
    apr_size_t offset=0, len, nbytes;
    apr_status_t status;
    apr_finfo_t finfo;
    
    status=apr_stat(&finfo, full_path->c_str(), APR_FINFO_SIZE, r->pool);
    if (status != APR_SUCCESS) {
        return 1;
    }
    
    status=apr_file_open(&fd, full_path->c_str(), APR_READ, APR_OS_DEFAULT, r->pool);
    if (status != APR_SUCCESS) {
        return 1;
    }
    
    len = finfo.size;
    ap_set_content_type(r, "image/png");
    ap_set_content_length(r, finfo.size);
    //apr_table_set(r->headers_out, "Cache-Control", "no-cache, no-store");
    apr_table_set(r->headers_out, "Expires", "01 Jul 2010 06:12:33 GMT");
    apr_table_set(r->headers_out, "Last-Modified", "Tue, 09 Jun 2009 19:40:16 GMT");
    apr_table_set(r->headers_out, "Cache-Control", "public, max-age=31536000");
    
    status = ap_send_fd(fd, r, offset, len, &nbytes);
    apr_file_close(fd);
    if (status != APR_SUCCESS) {
        return 1;
    }
    
    return APR_SUCCESS;
}

map<string, string> GetQueryParameters(string query) {
    map<string, string> params;
    
    size_t query_idx = query.find("?");
    if (query_idx != string::npos) {
        query.replace(0, query_idx + 1, "");
    }
    
    split_vector_type split_params;
    split(split_params, query, is_any_of("&") );
    for (unsigned int i=0; i<split_params.size(); i++) {
        string name   = split_params[i];
        string value  = "";
        size_t val_idx = name.find("=");
        
        if (val_idx != string::npos) {
            value = name.substr(val_idx + 1, name.size() - val_idx);
            name  = name.substr(0, val_idx);
        }
        
        name  = UrlLibrary::UrlDecode(name);
        value = UrlLibrary::UrlDecode(value);
        params[name] = value;
    }
    
    return params;
}

int writer(char *data, size_t size, size_t nmemb, std::string *buffer) {
    int result = 0;
    
    if (buffer != NULL) {
        buffer->append(data, size * nmemb);
        result = size * nmemb;
    }
    
    return result;
}

bool getURL(QUrl *url, string *out) {
    CURL *curl;
    CURLcode result;
    struct curl_slist *slist = NULL;

    curl = curl_easy_init();
    
    if (!curl) {
        return false;
    }

    std::string ua = "User-Agent:Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_3; en-US) AppleWebKit/533.2 (KHTML, like Gecko) Chrome/5.0.342.9 Safari/533.2";
    slist = curl_slist_append(slist, ua.c_str());
    
    curl_easy_setopt(curl, CURLOPT_URL, url->toEncoded().data());
    curl_easy_setopt(curl, CURLOPT_HEADER, 0);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writer);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, out);
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, slist);
    //curl_easy_setopt(curl, CURLOPT_TIMEOUT, 1);
    curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);
    
    result = curl_easy_perform(curl);
    if (result != CURLE_OK) {
        curl_easy_cleanup(curl);
        return false;
    }
    
    long status = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &status);
    if (status != 200) {
        curl_easy_cleanup(curl);
        return false;
    }
    
    curl_easy_cleanup(curl);
    
    return true;
}

Image* makeFull(string *data) {
    Blob blob((void *) data->c_str(), data->size());
    Image *image = new Image(blob);
    
    try {
        image->zoom(Geometry(FULL_HORIZONTAL_SIDE,FULL_VERTICAL_SIDE));
        image->magick("PNG");
    }
    catch (Exception &error) {
        delete image;
        image = NULL;
    }
    
    return image;
}

Image* makeThumb(string *data) {
    Blob blob((void *) data->c_str(), data->size());
    Image *image = new Image(blob);
    
    unsigned int nx, ny;
    float mul;
    
    unsigned int xo = 0;
    unsigned int yo = 0;
    
    unsigned int ox = image->baseColumns();
    unsigned int oy = image->baseRows();
    
    if (ox > oy) {
        ny  = THUMBNAIL_HORIZONTAL_SIDE;
        mul = (float)ox / oy;
        nx  = (unsigned int)floor(THUMBNAIL_HORIZONTAL_SIDE*mul);
        xo  = (unsigned int)floor((nx - THUMBNAIL_HORIZONTAL_SIDE) / 2.0);
    }
    else {
        nx  = THUMBNAIL_HORIZONTAL_SIDE;
        mul = (float)oy / ox;
        ny  = (unsigned int)floor(THUMBNAIL_HORIZONTAL_SIDE*mul);
        yo  = (unsigned int)floor((ny - THUMBNAIL_HORIZONTAL_SIDE) / 2.0);
    }
    
    try {
        image->zoom(Geometry(nx,ny));
        image->crop(Geometry(THUMBNAIL_HORIZONTAL_SIDE,THUMBNAIL_HORIZONTAL_SIDE, xo, yo));
        image->zoom(Geometry(THUMBNAIL_HORIZONTAL_SIDE,THUMBNAIL_HORIZONTAL_SIDE));
        image->magick("PNG");
    }
    catch (Exception &error) {
        delete image;
        image = NULL;
    }
    
    return image;
}

bool saveImage(const string *full_path, Image *image) {
    bool ret = true;
    
    try {
        image->write(full_path->c_str());
    }
    catch(Exception &error) {
        fprintf(stderr, "%s\n", error.what());
        ret = false;
    }
    
    return ret;
}

int image_handler(request_rec *r) {
    apr_status_t rv;
    int rc = OK;

    if (strcmp(r->handler, "image-service") != 0) {
        return DECLINED;
    }

    {
        
        string query(r->parsed_uri.query);
        map< string, string > params = GetQueryParameters(query);
        if(params.find("location") == params.end()) {
            return 400;
        }
        if(params.find("size") == params.end()) {
            return 400;
        }
        
        string location(params.find("location")->second.c_str());
        string size(params.find("size")->second.c_str());
        if(size != "t" && size != "f") {
            return 400;
        }
        
        image_module_dir_config_t* config =
        (image_module_dir_config_t*)ap_get_module_config(r->per_dir_config, &image_module);
        string path(config->command);
        if (size == "t") {
            path.append("/thumb/");
        }
        else if (size == "f") {
            path.append("/full/");
        }
        
        md5wrapper md5;
        string hash = md5.getHashFromString(location).append(".png");
        
        string full_path(path);
        full_path.append(hash);
        ap_log_rerror(APLOG_MARK, APLOG_NOTICE, NULL, r, "try:  %s", full_path.c_str());
        
        
        
        rv = send_local_file(&full_path, r);
        if (!rv) {
            return APR_SUCCESS;
        }
        
        QUrl url(location.c_str());
        ap_log_rerror(APLOG_MARK, APLOG_NOTICE, NULL, r, "curl:  %s", url.toEncoded().data());
            
        string data;
        if (getURL(&url, &data) == false) {
            return 404;
        }
        
        Image *image;
        if (size == "f") {
            image = makeFull(&data);
        }
        else if (size == "t") {
            image = makeThumb(&data);
        }

        if (image == NULL || !image->isValid() || !saveImage(&full_path, image)) {
            delete image;
            return 404;
        }

        ap_log_rerror(APLOG_MARK, APLOG_NOTICE, NULL, r, "done: %s", url.toEncoded().data());
            
        delete image;
        rv = send_local_file(&full_path, r);
        if (!rv) {
            return APR_SUCCESS;
        }
    }

    return rc;
}

static void* image_module_create_dir_cfg(apr_pool_t* pool, char* x) {
    image_module_dir_config_t* cfg = (image_module_dir_config_t*)apr_palloc(pool, sizeof(image_module_dir_config_t));
    char command[] = "";
    cfg->command=command;
    return cfg;
}

static const command_rec image_module_command_table[] = {
    AP_INIT_TAKE1(
                  "ImageRoot",
                  (const char*(*)())ap_set_string_slot,
                  (void*)APR_OFFSETOF(image_module_dir_config_t,command),
                  OR_ALL,
                  "Command to run inside terminal"),
    {NULL}
};

static void image_module_register_hooks(apr_pool_t *p)
{
    InitializeMagick(NULL);
    ap_hook_handler(image_handler, NULL, NULL, APR_HOOK_MIDDLE);
}

extern "C" {

    module AP_MODULE_DECLARE_DATA image_module = {
        STANDARD20_MODULE_STUFF,
        image_module_create_dir_cfg, /* dir config creater */
        NULL,                        /* dir merger --- default is to override */
        NULL,                        /* server config */
        NULL,                        /* merge server config */
        image_module_command_table,  /* commands */
        image_module_register_hooks  /* set up other request processing hooks */
    };

}; /* end extern C */



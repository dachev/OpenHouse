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

#include "httpd.h"
#include "http_config.h"
#include "http_protocol.h"
#include "http_log.h"

#include <math.h>
#include <Magick++.h>
#include <QUrl>
#include <QDir>
#include <QCryptographicHash>
#include "curl/curl.h"

#define THUMBNAIL_HORIZONTAL_SIDE 50
#define FULL_HORIZONTAL_SIDE 310
#define FULL_VERTICAL_SIDE 233

using namespace std;
using namespace Magick;

extern "C" module AP_MODULE_DECLARE_DATA image_module;

typedef struct {
    char* command;
} image_module_dir_config_t;

apr_status_t send_local_file(const QString &fullpath, request_rec *r) {
    apr_file_t *fd;
    apr_size_t offset=0, len, nbytes;
    apr_status_t status;
    apr_finfo_t finfo;
    
    status=apr_stat(&finfo, fullpath.toAscii().data(), APR_FINFO_SIZE, r->pool);
    if (status != APR_SUCCESS) {
        return 1;
    }
    
    status=apr_file_open(&fd, fullpath.toAscii().data(), APR_READ, APR_OS_DEFAULT, r->pool);
    if (status != APR_SUCCESS) {
        return 1;
    }
    
    len = finfo.size;
    ap_set_content_type(r, "image/jpeg");
    ap_set_content_length(r, finfo.size);
    //apr_table_set(r->headers_out, "Cache-Control", "no-cache, no-store");
    apr_table_set(r->headers_out, "Expires", "01 Jul 2050 06:12:33 GMT");
    apr_table_set(r->headers_out, "Last-Modified", "Tue, 09 Jun 2009 19:40:16 GMT");
    apr_table_set(r->headers_out, "Cache-Control", "public, max-age=31536000");
    
    status = ap_send_fd(fd, r, offset, len, &nbytes);
    apr_file_close(fd);
    if (status != APR_SUCCESS) {
        return 1;
    }
    
    return APR_SUCCESS;
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
        image->magick("JPG");
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
        image->magick("JPG");
    }
    catch (Exception &error) {
        delete image;
        image = NULL;
    }
    
    return image;
}

bool saveImage(const QString &fullpath, Image *image) {
    bool ret = true;
    
    try {
        image->write(fullpath.toAscii().data());
    }
    catch(Exception &error) {
        fprintf(stderr, "%s\n", error.what());
        ret = false;
    }
    
    return ret;
}

bool ensurePath(const QString &basepath, const QString &imagepath) {
    QDir basedir(basepath);
    
    if (basedir.exists() == false) {
        return false;
    }
    
    if (!basedir.mkpath(imagepath)) {
        return false;
    }
    
    return true;
}

int image_handler(request_rec *r) {
    apr_status_t rv;
    int rc = OK;

    if (strcmp(r->handler, "image-service") != 0) {
        return DECLINED;
    }

    {
        
        QUrl query;
        query.setEncodedQuery(QByteArray(r->parsed_uri.query));
        
        if(!query.hasQueryItem("size")) {
            return 400;
        }
        if(!query.hasQueryItem("location")) {
            return 400;
        }
        
        QString location(QUrl::fromPercentEncoding(query.encodedQueryItemValue(QByteArray("location"))));
        QString size(QUrl::fromPercentEncoding(query.encodedQueryItemValue(QByteArray("size"))));
        if(size != "t" && size != "f") {
            return 400;
        }
        
        image_module_dir_config_t* config =
        (image_module_dir_config_t*)ap_get_module_config(r->per_dir_config, &image_module);
        QString basepath(config->command);
        if (size == "t") {
            basepath.append("/thumb");
        }
        else if (size == "f") {
            basepath.append("/full");
        }
        
        QByteArray md5 = QCryptographicHash::hash(location.toAscii(), QCryptographicHash::Md5).toHex();
        QString hash = QString(md5).append(".jpg");
        QString nib1 = hash.mid(0,2).toUpper();
        QString nib2 = hash.mid(2,2).toUpper();
        
        QString imagepath = nib1 + "/" + nib2;
        QString fullpath  = basepath + "/" + imagepath + "/" + hash;
        ap_log_rerror(APLOG_MARK, APLOG_NOTICE, NULL, r, "try:  %s", fullpath.toAscii().data());
        
        rv = send_local_file(fullpath, r);
        if (!rv) {
            return APR_SUCCESS;
        }
        
        QUrl url(location);
        if (!url.isValid()) {
            return 400;
        }
        ap_log_rerror(APLOG_MARK, APLOG_NOTICE, NULL, r, "curl:  %s", url.toString().toAscii().data());
            
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

        if (image == NULL || !image->isValid() || !ensurePath(basepath, imagepath) || !saveImage(fullpath, image)) {
            delete image;
            return 404;
        }

        ap_log_rerror(APLOG_MARK, APLOG_NOTICE, NULL, r, "done: %s", url.toEncoded().data());
            
        delete image;
        rv = send_local_file(fullpath, r);
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



#!/bin/bash

NPS_VERSION=1.13.35.2-beta

# nginx init

useradd --system --home /var/cache/nginx --shell /sbin/nologin --comment "nginx user" --user-group nginx

cd ~;mkdir tmp;cd ~/tmp
cd ~/tmp; mkdir ngx-pagespeed; mkdir nginx; mkdir lib_png; mkdir pcre; mkdir zlib
mkdir openssl; mkdir frickle; mkdir ngx_fancyindex

# pagespeed

cd ~/tmp/ngx-pagespeed
wget https://github.com/apache/incubator-pagespeed-ngx/archive/v1.13.35.2-beta.tar.gz -P ~/tmp/ngx-pagespeed/
nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d)
cd "$nps_dir"
NPS_RELEASE_NUMBER=${NPS_VERSION/beta/}
NPS_RELEASE_NUMBER=${NPS_VERSION/stable/}
psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
wget ${psol_url}
tar -xzvf $(basename ${psol_url})  # extracts to psol/

cd ~/tmp/nginx
wget https://nginx.org/download/nginx-1.13.8.tar.gz ~/tmp/nginx/
tar -zxvf nginx-1.13.8.tar.gz && rm -f nginx-1.13.8.tar.gz

cd ~/tmp/lib_png
wget http://prdownloads.sourceforge.net/libpng/libpng-1.2.56.tar.gz -P ~/tmp/lib_png/
tar -zxvf libpng-1.2.56.tar.gz && rm -f libpng-1.2.56.tar.gz

# zlib version 1.2.11
wget https://github.com/madler/zlib/archive/v1.2.11.tar.gz --tries=3 -P ~/tmp/zlib/
cd ~/tmp/zlib; tar -xzf v1.2.11.tar.gz

# OpenSSL version 1.1.0f
wget https://www.openssl.org/source/openssl-1.1.1.tar.gz --tries=3 -P ~/tmp/openssl/
cd ~/tmp/openssl; tar -xzf openssl-1.1.1.tar.gz

#Frickle version 2.3
wget https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.tar.gz --tries=3 -P ~/tmp/frickle/
cd ~/tmp/frickle; tar -xzf 2.3.tar.gz

# ngx_fancyindex 0.4.2
wget https://github.com/aperezdc/ngx-fancyindex/archive/v0.4.3.tar.gz --tries=3 -P ~/tmp/ngx_fancyindex/
cd ~/tmp/ngx_fancyindex; tar -zxf v0.4.3.tar.gz

cd ~/tmp/nginx/nginx-1.13.8

./configure --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib64/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=nginx \
            --group=nginx \
            --build=Ubuntu \
            --builddir=nginx-1.13.8 \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
	        --add-module=/root/tmp/ngx-pagespeed/incubator-pagespeed-ngx-1.13.35.2-beta \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
	        --add-module=/root/tmp/frickle/ngx_cache_purge-2.3 \
	        --add-dynamic-module=/root/tmp/ngx_fancyindex/ngx-fancyindex-0.4.3 \
            --with-http_addition_module \
            --with-http_xslt_module=dynamic \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_slice_module \
            --with-http_stub_status_module \
            --http-log-path=/var/log/nginx/access.log \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-mail=dynamic \
            --with-mail_ssl_module \
            --with-stream=dynamic \
            --with-stream_ssl_module \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
            --with-stream_ssl_preread_module \
            --with-compat \
            --with-zlib=/root/tmp/zlib/zlib-1.2.11 \
            --with-openssl=/root/tmp/openssl/openssl-1.1.1 \
            --with-openssl-opt=no-nextprotoneg

make
make install

cd /var/log/nginx
touch access.log
touch error.log

mkdir -p /var/cache/ngx_pagespeed /var/log/pagespeed /var/cache/nginx/client_temp

chmod -R 777 /var/cache/ngx_pagespeed
chmod -R 777 /var/log/pagespeed
chmod -R 777 /var/cache/nginx/client_temp

nginx

echo " SUCCESS "
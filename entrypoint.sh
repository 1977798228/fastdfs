#!/bin/sh
/etc/init.d/fdfs_trackerd start
/etc/init.d/fdfs_storaged start
ln -s /fastdfs/storage/data/ /fastdfs/storage/data/M00
/usr/local/nginx/sbin/nginx -g 'daemon off;'

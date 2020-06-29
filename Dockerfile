FROM ubuntu:xenial

LABEL maintainer="wucanheng <1977798228@qq.com>"

# 更新数据源

WORKDIR /etc/apt
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse' > sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse' >> sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse' >> sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse' >> sources.list
RUN apt-get update

# 安装依赖

RUN apt-get install vim make gcc libpcre3-dev zlib1g-dev --assume-yes

# 复制工具包
ADD ./lib/fastdfs-6.06.tar.gz /usr/local/src
ADD ./lib/fastdfs-nginx-module-1.22.tar.gz /usr/local/src
ADD ./lib/libfastcommon-1.0.43.tar.gz /usr/local/src
ADD ./lib/nginx-1.18.0.tar.gz /usr/local/src

# 安装 libfastcommon
WORKDIR /usr/local/src/libfastcommon-1.0.43
RUN ./make.sh && ./make.sh install

# 安装 FastDFS
WORKDIR /usr/local/src/fastdfs-6.06
RUN ./make.sh && ./make.sh install

# 配置 FastDFS tracker
ADD ./conf/tracker.conf /etc/fdfs
RUN mkdir -p /fastdfs/tracker

# 配置 FastDFS storage
ADD ./conf/storage.conf /etc/fdfs
RUN mkdir -p /fastdfs/storage

# 配置 FastDFS 客户端
ADD ./conf/client.conf /etc/fdfs

# 配置 fastdfs-nginx-module
# ADD ./conf/config /usr/local/src/fastdfs-nginx-module-1.22/src

# WORKDIR /usr/local/src/fastdfs-nginx-module-1.22/src
# RUN ls

# FastDFS 与 Nginx 集成
WORKDIR /usr/local/src/nginx-1.18.0
RUN ./configure --add-module=/usr/local/src/fastdfs-nginx-module-1.22/src
RUN make && make install
ADD ./conf/mod_fastdfs.conf /etc/fdfs

WORKDIR /usr/local/src/fastdfs-6.06/conf
RUN cp http.conf mime.types /etc/fdfs/

# 配置 Nginx
ADD ./conf/nginx.conf /usr/local/nginx/conf

COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /
EXPOSE 80
CMD ["/bin/bash"]

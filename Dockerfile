FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LAPIS_ENV=production
ENV LAPIS_OPENRESTY=/usr/local/openresty/nginx/sbin/nginx
ENV PATH=/usr/local/bin:$PATH

RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    software-properties-common \
    lsb-release \
    lua-bitop \
    libluajit-5.1-dev 

RUN wget -O - https://openresty.org/package/pubkey.gpg | apt-key add - && \
    add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" && \
    apt-get update && \
    apt-get install -y openresty

RUN apt-get install -y \
    libluajit-5.1-dev \
    luajit \
    luarocks \
    curl \
    git \
    build-essential \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.xz \
    && tar xf expat-2.5.0.tar.xz \
    && cd expat-2.5.0 \
    && ./configure --prefix=/usr \
    && make \
    && make install

RUN luarocks install moonscript && \
    luarocks install lapis && \
    luarocks install lua-cjson && \
    luarocks install luasocket && \
    luarocks install lpeg && \
    luarocks install mimetypes &&\
    luarocks install luaexpat && \
    luarocks install luasec && \
    luarocks install cloud_storage

WORKDIR /apps

COPY . /apps

WORKDIR /apps

RUN moonc -o app.lua app.moon && \
    moonc -o models.lua models.moon && \
    moonc -o migrations.lua migrations.moon

EXPOSE 8080

CMD ["lapis", "server"]

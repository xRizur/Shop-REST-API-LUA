FROM ubuntu:20.04

# Ustawienia środowiskowe
ENV DEBIAN_FRONTEND=noninteractive
# Używamy trybu produkcyjnego (OpenResty) – LuaJIT (zgodny z Lua 5.1)
ENV LAPIS_ENV=production
# Ścieżka do binariów OpenResty
ENV LAPIS_OPENRESTY=/usr/local/openresty/nginx/sbin/nginx
ENV PATH=/usr/local/bin:$PATH

# Instalacja narzędzi niezbędnych do dodania repozytorium OpenResty
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    software-properties-common \
    lsb-release \
    lua-bitop \
    libluajit-5.1-dev

# Dodanie repozytorium OpenResty i instalacja OpenResty
RUN wget -O - https://openresty.org/package/pubkey.gpg | apt-key add - && \
    add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" && \
    apt-get update && \
    apt-get install -y openresty

# Instalacja LuaJIT oraz pakietów deweloperskich, LuaRocks i innych zależności
RUN apt-get install -y \
    libluajit-5.1-dev \
    luajit \
    luarocks \
    curl \
    git \
    build-essential \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# (Opcjonalnie) Upewnij się, że luarocks wykorzystuje LuaJIT – zazwyczaj gdy luajit jest zainstalowany, luarocks go wykrywa.
# Instalacja modułów MoonScript, Lapis, lua-cjson, luasocket oraz lpeg (dla LuaJIT / Lua 5.1)
RUN luarocks install moonscript && \
    luarocks install lapis && \
    luarocks install lua-cjson && \
    luarocks install luasocket && \
    luarocks install lpeg 

# Ustawienie katalogu roboczego
WORKDIR /apps

# Kopiowanie całego projektu do obrazu (upewnij się, że pliki takie jak nginx.conf, app.moon, modele itp. znajdują się w projekcie)
COPY . /apps

WORKDIR /apps

# RUN moonc -o app/app.lua app/app.moon && \
#     moonc -o app/models.lua app/models.moon && \
#     moonc -o app/routes.lua app/routes.moon
# RUN moonc -o app.lua app.moon && \
#     moonc -o models.lua models.moon && \
#     moonc -o routes.lua routes.moon && \
#     moonc -o migrations.lua migrations.moon
RUN moonc -o app.lua app.moon && \
    moonc -o models.lua models.moon && \
    moonc -o migrations.lua migrations.moon
#     moonc -o routes.lua routes.moon && \
# Eksponowanie portu 8080
EXPOSE 8080

# Uruchomienie serwera Lapis (który w trybie produkcyjnym korzysta z OpenResty i pliku nginx.conf)
CMD ["lapis", "server"]

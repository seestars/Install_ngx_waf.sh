#!/usr/bin/env bash

Color_Text()
{
    echo -e " \e[0;$2m$1\e[0m"
}

Echo_Green()
{
    echo $(Color_Text "$1" "32")
}

Press_Start()
{
    echo ""
    Echo_Green "Press any key to start...or Press Ctrl+c to cancel"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}

Select_lnmp_dir()
{
    echo 'Please select you lnmp directory: '
    echo ${Cur_Lnmp_Dir}

    read Lnmp_Dir
}

Install_ngx_waf()
{
    echo "Initializing, please wait."
    Nginx_Version=`/usr/local/nginx/sbin/nginx -v 2>&1 | cut -c22-`
    Num_Lnmp_Dir=`find / -name 'lnmp*' -type d | wc -l`
    Cur_Lnmp_Dir=`find / -name 'lnmp*' -type d`
    Lnmp_Dir=""

    if [[ ${Num_Lnmp_Dir} == 0 ]]; then
        echo "Your server does not have lnmp installed."
        exit 1
    elif [[ ${Num_Lnmp_Dir} -ge 2 ]]; then
        Select_lnmp_dir
    else
        Lnmp_Dir=${Cur_Lnmp_Dir}
    fi

    echo "+---------------------------------------------------------+"
    echo "|    You will install ngx-waf with nginx version ${Nginx_Version}"
    echo "+---------------------------------------------------------+"
    echo "|    This script only supports Debian/Ubuntu systems"
    echo "+---------------------------------------------------------+"
    Press_Start

    apt update
    apt install -y libtool m4 automake gcc g++ make git wget libpcre3 libpcre3-dev libmodsecurity3 libmodsecurity-dev libsodium23 libsodium-dev

    Echo_Green "Clone the ngx_waf file"

    cd /usr/local/src \
        && git clone -b current https://github.com/ADD-SP/ngx_waf.git \
        && cd ngx_waf

    cd /usr/local/src/ngx_waf \
        && git clone https://github.com/DaveGamble/cJSON.git lib/cjson

    cd /usr/local/src/ngx_waf \
        && git clone https://github.com/libinjection/libinjection.git inc/libinjection

    cd /usr/local/src \
        && git clone https://github.com/jedisct1/libsodium.git --branch stable libsodium-src \
        && cd libsodium-src \
        && ./configure --prefix=/usr/local/src/libsodium --with-pic \
        && make -j$(nproc) && make check -j $(nproc) && make install \
        && export LIB_SODIUM=/usr/local/src/libsodium

    cd/usr/local/src/ngx_waf\
        && git clone -b v2.3.0 https://github.com/troydhanson/uthash.git lib/uthash\
        && export LIB_UTHASH=/usr/local/src/ngx_waf/uthash


    Echo_Green "Clone the Modsecurity file"

    cd /usr/local/src \
        &&  wget https://github.com/maxmind/libmaxminddb/releases/download/1.6.0/libmaxminddb-1.6.0.tar.gz -O libmaxminddb.tar.gz && mkdir libmaxminddb \
        && tar -zxf "libmaxminddb.tar.gz" -C libmaxminddb --strip-components=1 \
        && cd libmaxminddb \
        && ./configure --prefix=/usr/local/libmaxminddb \
        && make -j $(nproc) \
        && make install \
        && cd /usr/local/src \
        && git clone -b v3.0.5 https://github.com/SpiderLabs/ModSecurity.git \
        && cd ModSecurity \
        && chmod +x build.sh \
        && ./build.sh \
        && git submodule init \
        && git submodule update \
        && ./configure --prefix=/usr/local/modsecurity --with-maxmind=/usr/local/libmaxminddb \
        && make -j$(nproc) \
        && make install \
        && export LIB_MODSECURITY=/usr/local/modsecurity

    sed -i "/^Nginx_Modules_Options=/ s/'$/ --add-module=\/usr\/local\/src\/ngx_waf'/" ${Lnmp_Dir}/lnmp.conf
    sed -i "/\.\/configure --user=www --group=www --prefix=\/usr\/local\/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_/a\sed -i \'s\/-Werror\/\/\' objs\/Makefile\nsed -i \'s\/\^\\\(CFLAGS\.*\\\)\/\\\1 -fstack-protector-strong -Wno-sign-compare\/\' objs\/Makefile" upgrade_nginx.sh

    echo ${Lnmp_Dir}|./upgrade.sh nginx

    echo "The installation is complete. Goodbye~"

}

Install_ngx_waf

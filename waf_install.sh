#!/usr/bin/env bash

Install_ngx_waf()
{
    Cur_Nginx_Version=`/usr/local/nginx/sbin/nginx -v 2>&1 | cut -c22-`
    Num_lnmp_dir=`find / -name 'lnmp*' -type d | wc -l`
    Cur_lnmp_dir=`find / -name 'lnmp*' -type d`

    if [ ${Num_lnmp_dir} = 0 ]; then
        exit 1
    elif [ ${Num_lnmp_dir} >= 2 ]; then
        Select_lnmp_dir
    else
        NginxMAOpt=""
    fi

    Nginx_Version=""
    echo "Current Nginx Version:${Cur_Nginx_Version}"
    echo "You can get version number from http://nginx.org/en/download.html"
    read -p "Please enter nginx version you want, (example: 1.20.2): " Nginx_Version
    if [ "${Nginx_Version}" = "" ]; then
        echo "Error: You must enter a nginx version!!"
        exit 1
    fi
    echo "+---------------------------------------------------------+"
    echo "|    You will install ngx-waf by nginx version to ${Nginx_Version}"
    echo "+---------------------------------------------------------+"

    Press_Start

    echo "============================check files=================================="
    cd ${cur_dir}/src
    if [ -s nginx-${Nginx_Version}.tar.gz ]; then
        echo "nginx-${Nginx_Version}.tar.gz [found]"
    else
        echo "Notice: nginx-${Nginx_Version}.tar.gz not found!!!download now......"
        wget -c --progress=dot:giga http://nginx.org/download/nginx-${Nginx_Version}.tar.gz
        if [ $? -eq 0 ]; then
            echo "Download nginx-${Nginx_Version}.tar.gz successfully!"
        else
            echo "You enter Nginx Version was:"${Nginx_Version}
            Echo_Red "Error! You entered a wrong version number, please check!"
            sleep 5
            exit 1
        fi
    fi
    echo "============================check files=================================="

    Install_Nginx_Openssl
    Install_Nginx_Lua
    Install_Pcre
    Install_Ngx_FancyIndex
    Tar_Cd nginx-${Nginx_Version}.tar.gz nginx-${Nginx_Version}
    Get_Dist_Version
    if [[ "${DISTRO}" = "Fedora" && ${Fedora_Version} -ge 28 ]]; then
        patch -p1 < ${cur_dir}/src/patch/nginx-libxcrypt.patch
    fi
    Nginx_Ver_Com=$(${cur_dir}/include/version_compare 1.14.2 ${Nginx_Version})
    if gcc -dumpversion|grep -q "^[8]" && [ "${Nginx_Ver_Com}" == "1" ]; then
        patch -p1 < ${cur_dir}/src/patch/nginx-gcc8.patch
    fi
    Nginx_Ver_Com=$(${cur_dir}/include/version_compare 1.9.4 ${Nginx_Version})
    if [[ "${Nginx_Ver_Com}" == "0" ||  "${Nginx_Ver_Com}" == "1" ]]; then
        ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_spdy_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module --with-http_realip_module ${Nginx_With_Openssl} ${Nginx_With_Pcre} ${Nginx_Module_Lua} ${NginxMAOpt} ${Ngx_FancyIndex} ${Nginx_Modules_Options}
	sed -i 's/^\(CFLAGS.*\)/\1 -fstack-protector-strong -Wno-sign-compare/' objs/Makefile
    else
        ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --with-http_sub_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-http_realip_module ${Nginx_With_Openssl} ${Nginx_With_Pcre} ${Nginx_Module_Lua} ${NginxMAOpt} ${Ngx_FancyIndex} ${Nginx_Modules_Options}
	sed -i 's/^\(CFLAGS.*\)/\1 -fstack-protector-strong -Wno-sign-compare/' objs/Makefile
    fi
    make -j `grep 'processor' /proc/cpuinfo | wc -l`
    if [ $? -ne 0 ]; then
        make
    fi

    cd ${cur_dir} && rm -rf ${cur_dir}/src/nginx-${Nginx_Version}
    if [ "${Enable_Nginx_Lua}" = 'y' ]; then
        if ! grep -q 'lua_package_path "/usr/local/nginx/lib/lua/?.lua";' /usr/local/nginx/conf/nginx.conf; then
            sed -i "/server_tokens off;/i\        lua_package_path \"/usr/local/nginx/lib/lua/?.lua\";\n" /usr/local/nginx/conf/nginx.conf
        fi
        if ! grep -q "content_by_lua 'ngx.say(\"hello world\")';" /usr/local/nginx/conf/nginx.conf; then
            sed -i "/location \/nginx_status/i\        location /lua\n        {\n            default_type text/html;\n            content_by_lua 'ngx.say\(\"hello world\"\)';\n        }\n" /usr/local/nginx/conf/nginx.conf
        fi
    fi

    echo "Checking ..."
    if [[ -s /usr/local/nginx/conf/nginx.conf && -s /usr/local/nginx/sbin/nginx ]]; then
        echo "Program will display Nginx Version......"
        /usr/local/nginx/sbin/nginx -v
        Echo_Green "======== upgrade nginx completed ======"
    else
        Echo_Red "Error: Nginx upgrade failed."
    fi
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
    echo "${Cur_lnmp_dir}"
}
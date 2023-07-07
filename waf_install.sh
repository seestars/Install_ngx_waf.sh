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
    Press_Start

    sed -i "/^Nginx_Modules_Options=/ s/'$/ --add-module=\/usr\/local\/src\/ngx_waf'/" ${Lnmp_Dir}/lnmp.conf

    echo ${Lnmp_Dir}|./upgrade.sh nginx

}

Install_ngx_waf

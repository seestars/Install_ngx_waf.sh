#!/usr/bin/env bash

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
        echo "Installation is about to begin."
    fi

    echo "+---------------------------------------------------------+"
    echo "|    You will install ngx-waf with nginx version ${Nginx_Version}"
    echo "+---------------------------------------------------------+"
    Press_Start

    

}

Install_ngx_waf

#!/usr/bin/env bash
# by 运维朱工
# site：www.lutixia.cn
####################################



check_single_host() {
    read -p "请输入要检测的主机ip,多个ip用空格分隔：" -a  ip
    echo -e "\t\033[0;32m检测中，请稍后...\033[0m"
    fping  -r 1  `echo ${ip[@]}`  &> /tmp/ip_temp_list
    awk 'BEGIN{printf "%-20s\n","当前在线的ip:"}/alive/{printf "%20s\n",$1}' /tmp/ip_temp_list
    awk 'BEGIN{printf "\n%-20s\n","当前不在线的ip:"}/unreachable/{printf "%20s\n",$1}' /tmp/ip_temp_list
    awk 'BEGIN{printf "\n%-20s\n","格式错误的ip:"}/found/{printf "%20s\n",$1}' /tmp/ip_temp_list
    rm -rf /tmp/ip_temp_list
}

check_multi_host() {
    echo -e "Usage:\n\
    # 当要检测192.168.75.100到192.168.75.200的主机时，请输入：\n\
      192.168.75.100  192.168.75.200 \n\
    # 当要检测192.168.75.0整个网段时，请输入：\n\
      192.168.75.0/24 \n\
    "
    read -p "请输入要ip范围或者网段：" -a  ip
    echo -e "\t\033[0;32m检测中，请稍后...\033[0m"
    fping -r 1 -g `echo ${ip[@]}` &>/tmp/ip_temp_list
    if  grep "parse" /tmp/ip_temp_list &>/dev/null;then
        echo -e "\t\033[0;31m请参考提示，输入正确格式的ip范围或者网段！\033[0m"
    else
        awk 'BEGIN{printf "\n%-20s\n","当前不在线的ip:"}/unreachable/{printf "%20s\n",$1}' /tmp/ip_temp_list
        awk 'BEGIN{printf "%-20s\n","当前在线的ip:"}/alive/{printf "%20s\n",$1}' /tmp/ip_temp_list
        rm -rf /tmp/ip_temp_list
    fi
}


# fping菜单：
fping_menu() {
    clear
    echo -e "\t\t\tFping菜单"
    echo -e "\033[0;32m-------------------------------------------------\033[0m"
    echo -e "\t\t1、检查指定主机是否在线"
    echo -e "\t\t2、显示局域网主机状态"
    echo -e "\t\t3、退出"
    echo -e "\033[0;32m-------------------------------------------------\033[0m"

    read -p "请输入对应的数字编号：" FPING_CHOICE
    case ${FPING_CHOICE} in
          1)
                echo
                check_single_host
                ;;
          2)
                echo
                check_multi_host
                ;;
          3)
                echo
                exit
                ;;
     esac
}

fping_menu

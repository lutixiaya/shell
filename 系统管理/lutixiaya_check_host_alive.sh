#!/usr/bin/env bash
# by 运维朱工
# site：www.lutixia.cn
####################################


check_fping() {
    echo -e "\t\033[0;32m正在检测并安装fping工具，请稍后...\033[0m"
    rpm -q fping &>/dev/null && echo -e "\t\033[1;34mfping已成功安装！请继续...\033[0m" || {
    yum install fping -y &>/dev/null  || echo -e "\t\033[0;31m安装fping工具包失败！请检查是否配置好镜像仓库...\033[0m" && \
	exit 1
    }
}


check_single_host() {
    read -p "请输入要检测的主机ip,多个ip用空格分隔：" -a  ip
    [[ -n ${ip} ]] && {\
    echo -e "\t\033[0;32m检测中，请稍后...\n---------------------------------------\033[0m"
    fping  -r 1  `echo ${ip[@]}`  &> /tmp/ip_temp_list
    awk 'BEGIN{printf "%-20s\n","\033[1;36m当前在线的ip:\033[0m"}/alive/{printf "%20s\n",$1}' /tmp/ip_temp_list
    awk 'BEGIN{printf "\n%-20s\n","\033[1;31m当前不在线的ip:\033[0m"}/unreachable/{printf "%20s\n",$1}' /tmp/ip_temp_list
    awk 'BEGIN{printf "\n%-20s\n","\033[1;33m格式错误的ip:\033[0m"}/found/{printf "%20s\n",$1}' /tmp/ip_temp_list
    rm -rf /tmp/ip_temp_list
    } || \
    echo -e "\t\033[0;32m你还没有输入ip地址！\033[0m"
}

check_multi_host() {
    echo -e "Usage:\n\
    # 当要检测192.168.75.100到192.168.75.200的主机时，请输入：\n\
      192.168.75.100  192.168.75.200 \n\
    # 当要检测192.168.75.0整个网段时，请输入：\n\
      192.168.75.0/24 \n\
    "
    read -p "请输入要检测ip范围或者网段：" -a  ip
    [[ -n ${ip} ]] && {\
    echo -e "\t\033[0;32m检测中，请稍后...\n---------------------------------------\033[0m"
    fping -r 1 -g `echo ${ip[@]}` &>/tmp/ip_temp_list
    if  grep "parse" /tmp/ip_temp_list &>/dev/null;then
        echo -e "\t\033[0;31m请参考提示，输入正确格式的ip范围或者网段！\033[0m"
    else
        awk 'BEGIN{printf "\n%-20s\n","\033[1;31m当前不在线的ip:\033[0m"}/unreachable/{printf "%20s\n",$1}' /tmp/ip_temp_list
        awk 'BEGIN{printf "%-20s\n","\033[1;36m当前在线的ip:\033[0m"}/alive/{printf "%20s\n",$1}' /tmp/ip_temp_list
        rm -rf /tmp/ip_temp_list
    fi
    } || \
    echo -e "\t\033[0;32m你还没有输入ip地址！\033[0m"
}


# fping菜单：
fping_menu() {
    clear
    echo -e "\t\t\tFping菜单"
    echo -e "\033[0;32m-------------------------------------------------\033[0m"
    echo -e "\t\t1、检测指定主机是否在线"
    echo -e "\t\t2、检测局域网主机状态"
    echo -e "\t\t3、退出"
    echo -e "\033[0;32m-------------------------------------------------\033[0m"

    read -p "请输入对应的数字编号：" FPING_CHOICE
    case ${FPING_CHOICE} in
          1)
                echo
                check_fping && \
                check_single_host
                ;;
          2)
                echo
                check_fping && \
                check_multi_host
                ;;
          3)
                echo
                exit
                ;;
     esac
}


fping_menu

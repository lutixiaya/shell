#!/bin/bash
#by lutixiaya
#########################

#以下两种方式均可实现主机扫描，选择注释哦

#第一种方式：

fping -g 192.168.0.0/24 2>/dev/null |grep -v unreachable

#-g 指定网段

#第二种方式：

#fping -a -g 192.168.0.0/24 2>/dev/null

#如果执行没有反应，检查是否安装了fping软件包



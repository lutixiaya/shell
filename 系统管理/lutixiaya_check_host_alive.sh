#!/bin/bash
#by lutixiaya
#########################

#以下两种方式均可实现主机扫描，选择注释哦

fping -g 192.168.0.0/24 2>/dev/null |grep -v unreachable

#-g 指定网段

#或者

#fping -a -g 192.168.0.0/24 2>/dev/null


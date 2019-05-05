#!/bin/bash
#by lutixiaya
############################
#执行这个脚本，需要该服务器上安装nginx WEB服务器，因为我将抓取的电影名放置在nginx的发布目录中（查看cat行），如果没有安装，则手动修改下存放文件地址。

USER_AGENT="Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.67 Mobile Safari/537.36"

HOST="https://movie.douban.com"

j=0

for i in `seq 0 9`;do
        ARG="top250?start=$(( 25 * $i ))"
        [[ $i = $j ]]||[[ $i = $(($j + 1))  ]]&&{
        curl  -A $USER_AGENT $HOST/$ARG  2>/dev/null |awk  -v FS='"'  '/alt/{print $4}'|grep -v "App" |sed 's/$/\<br\>/' >>part.txt
        echo "part_${i}已经创建完成"
        j=$(($j+1))
        sleep 2
        }
done

cat  > /usr/share/nginx/html/douban.html << EOF
<html>
<head>        <meta charset="utf-8" />    </head>    
<body>        
<table border="1" cellspacing="0" width="1000" height="400">           
<tr><td>第1~50部 </td><td>第51~100部</td><td>第101~150部</td><td>第151~200部</td><td>第201~250部</td></tr>
<tr><td>$(sed -n '1,50p' part.txt)</td><td>$(sed -n '51,100p' part.txt)</td><td>$(sed -n '101,150p'  part.txt)</td><td>$(sed -n '151,200p'  part.txt)</td><td>$(sed -n '201,250p' part.txt)</td></tr>
</table>  
</body>
</html>
EOF

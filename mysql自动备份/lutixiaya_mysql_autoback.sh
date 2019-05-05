#!/bin/bash
#by lutixiaya 
##############
MYSQL_USER="root"
MYSQL_PASSWD="123456"
BACK_DIR="/data"

#查看当前数据库
mysql -u$MYSQL_USER -p$MYSQL_PASSWD -e "show databases;"

echo -e "\n---------------温馨提示--------------\n\n你除了可以选择单个或多个数据库备份，你还可以选择使用all进行全备份\n\n"
#将用户输入创建为数组
read -p "请输入你要备份数据库：" -a database_name
#遍历数组
for i in $(seq 0 $(expr ${#database_name[@]} - 1));do
        #过滤出真实的数据库
        value=`mysql -u$MYSQL_USER -p$MYSQL_PASSWD -e "show databases;"|grep -v Database`
        echo $value|grep -w ${database_name[$i]} >/dev/null
        #判断数据库是否匹配成功
        if [[ $? == 0 ]];then
                mysqldump -u$MYSQL_USER -p$MYSQL_PASSWD --databases ${database_name[$i]} > $BACK_DIR/${database_name[$i]}.$(date +%F).sql
                echo -e "\n${database_name[$i]}数据库备份成功~\n"

        else
                if [[ ${database_name[$i]} == all ]];then
                        mysqldump -u$MYSQL_USER -p$MYSQL_PASSWD --all-databases  > $BACK_DIR/${database_name[$i]}.$(date +%F).sql
                else
                        echo "${database_name[$i]}不存在，请检查。
                fi
        fi
done

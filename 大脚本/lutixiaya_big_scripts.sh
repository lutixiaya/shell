#!/bin/bash
# by 运维朱工
# site：www.lutixia.cn
####################################



#-------------------------变量定义----------------------------------
# 存放源码包的目录：
BASE_DIR=/usr/src/
# 软件统一安装目录：
INSTALL_PATH=/usr/local/
# 菜单输入提示符：
PS3="请输入对应的数字编号："
# 软件包列表，用空格分隔：
APPS=(nginx mysql redis exit)
#------------------------------------------------------------------


#------------------------安装软件函数--------------------------------

# yum安装nginx:
yum_install_nginx() {
# 配置nginx官方仓库：
echo '
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true ' > /etc/yum.repos.d/nginx.repo

    # 检查nginx是否已安装：
    rpm  -q ${app} &>/dev/null
    if [[ $? -eq 0 ]];then
        INSTALLED_NGINX_VERSION=`rpm -q ${app}`
        echo -e  "\t请核实!\033[1;31m 系统已安装${INSTALLED_NGINX_VERSION:0:12}版本！\033[0m"
    else
        # nginx的安装版本：
        NGINX_LIST=(1.16.0 1.18.0 1.20.0)
        echo -e "请输入${app}版本号：例如：${NGINX_LIST[@]}\033[0;31m，推荐使用1.18.0版本\033[0m。"
        read -p "请参考上面的格式输入${app}版本号：" NGINX_VERSION
        [[ -n ${NGINX_VERSION} ]] && {\
        echo -e "\t\033[0;36m正在安装 ${app}-${NGINX_VERSION},请稍等...\033[0m"
        yum install ${app}-${NGINX_VERSION} -y && \
        echo -e "\t\033[1;32m---------------------------------------------------------" && \
        echo -e "\t| \t\t${app}-${NGINX_VERSION} 部署成功！\t\t\t|"
        echo -e "\t| ${app}的默认配置文件路径：`rpm -qc nginx | awk '/nginx\.conf$/{printf "%-10s\n", $1}'`\t|"
        echo -e "\t| ${app}的默认发布目录路径：`rpm -ql nginx  | awk '/\/html$/{printf "%-10s\n", $1}'`\t|"
        echo -e "\t| ${app}的更多教程可以访问：`printf '%-29s' https://www.lutixia.cn`|"
        echo -e "\t--------------------------------------------------------\033[0m"  || \
        echo -e "\033[0;31m ${app}-${NGINX_VERSION} 安装失败！\033[0m"
        } || \
		echo -e "\t\033[0;32m你还没有输入${app}版本！\033[0m"
    fi
}

# 源码安装nginx:
source_install_nginx() {
    # nginx的安装版本：
    NGINX_LIST=(1.16.0 1.18.0 1.20.0)
    # nginx的安装路径：
    INSTALL_NGINX_PATH=${INSTALL_PATH}${app}
	if [ -d ${INSTALL_NGINX_PATH} ];then
		echo -e  "\t请核实!在\033[1;31m${INSTALL_NGINX_PATH%/${app}}\033[0m目录下是否已安装${app}服务！"
	else
		echo -e "请输入${app}版本号：例如：${NGINX_LIST[@]}\033[0;31m，推荐使用1.18.0版本\033[0m。"
        read -p "请参考上面的格式输入${app}版本号：" NGINX_VERSION
        [[ -n ${NGINX_VERSION} ]] && {\
        echo -e "\t\033[0;36m正在安装${app}-${NGINX_VERSION},请稍等...\033[0m"
        # 安装依赖：
		yum install wget pcre-devel zlib-devel -y >/dev/null && \
		wget -c -P "${BASE_DIR}" http://nginx.org/download/${app}-${NGINX_VERSION}.tar.gz
		if [[ $? -ne 0 ]];then
			echo -e "\t\033[0;31m ${app}-${NGINX_VERSION}下载失败！请检查网络是否正常 or ${app}版本是否存在！\033[0m"
		else
			cd "$BASE_DIR"
			tar xf ${app}-${NGINX_VERSION}.tar.gz
			cd ${app}-${NGINX_VERSION}
			./configure --prefix=${INSTALL_NGINX_PATH} && make && make install && {\
			echo -e "\t\033[1;32m-----------------------------------------------------------------"
            echo -e "\t| \t\t${app}-${NGINX_VERSION} 部署成功！\t\t\t\t|"
            echo -e "\t| ${app}的默认安装目录路径：`printf '%-37s' ${INSTALL_NGINX_PATH}`|"
            echo -e "\t| ${app}的默认配置文件路径：`printf '%-37s' ${INSTALL_NGINX_PATH}/conf/nginx.conf`|"
            echo -e "\t| ${app}的默认发布目录路径：`printf '%-37s' ${INSTALL_NGINX_PATH}/html`|"
            echo -e "\t| ${app}的更多教程可以访问：`printf '%-37s' https://www.lutixia.cn`|"
            echo -e "\t-----------------------------------------------------------------\033[0m" ;}  || \
			echo -e "\033[0;31m ${app}-${NGINX_VERSION} 安装失败！\033[0m"
		fi
		} || \
		echo -e "\t\033[0;32m你还没有输入${app}版本！\033[0m"
	fi
}

# yum安装MySQL：
yum_install_mysql() {
    rpm  -q ${app}-community-server &>/dev/null
    if [[ $? -eq 0 ]];then
        INSTALLED_MYSQL_VERSION=`rpm -q mysql-community-server | awk -F"-" '{print $1"-"$4}'`
        echo -e  "\t请核实!\033[1;31m 系统已安装${INSTALLED_MYSQL_VERSION}版本！\033[0m"
    else
        cat >/etc/yum.repos.d/mysql.repo <<'EOF'
# Enable to use MySQL 5.5
[mysql55-community]
name=MySQL 5.5 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.5-community/el/7/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

# Enable to use MySQL 5.6
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/7/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

# Enable to use MySQL 5.7
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2022
       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql80-community]
name=MySQL 8.0 Community Server
baseurl=http://repo.mysql.com/yum/mysql-8.0-community/el/7/$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2022
       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-connectors-community]
name=MySQL Connectors Community
baseurl=http://repo.mysql.com/yum/mysql-connectors-community/el/7/$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2022
       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-tools-community]
name=MySQL Tools Community
baseurl=http://repo.mysql.com/yum/mysql-tools-community/el/7/$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2022
       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-tools-preview]
name=MySQL Tools Preview
baseurl=http://repo.mysql.com/yum/mysql-tools-preview/el/7/$basearch
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2022
       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-cluster-7.5-community]
name=MySQL Cluster 7.5 Community
baseurl=http://repo.mysql.com/yum/mysql-cluster-7.5-community/el/7/$basearch
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2022
       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-cluster-7.6-community]
name=MySQL Cluster 7.6 Community
baseurl=http://repo.mysql.com/yum/mysql-cluster-7.6-community/el/7/$basearch
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2022
       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-cluster-8.0-community]
name=MySQL Cluster 8.0 Community
baseurl=http://repo.mysql.com/yum/mysql-cluster-8.0-community/el/7/$basearch
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2022
       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

EOF
        MYSQL_LIST=(5.5 5.6 5.7 8.0)
        echo -e "请输入${app}版本号：例如：${MYSQL_LIST[@]}\033[0;31m ,推荐使用8.0版本\033[0m。"
        read -p "请参考上面的格式输入${app}版本号：" MYSQL_VERSION
        [[ -n ${MYSQL_VERSION} ]] && {\
        echo -e "\t\033[0;36m正在安装 ${app}-${MYSQL_VERSION},请稍等...\033[0m"
        yum install yum-utils -y && \
        if [[ ${MYSQL_VERSION} == "5.5" ]];then
            yum-config-manager --disable mysql80-community mysql57-community mysql56-community &>/dev/null  && \
            yum-config-manager --enable mysql55-community &>/dev/null  && \
            yum install ${app} ${app}-server -y && {\
            echo -e "\t\033[1;32m---------------------------------------------------------"
            echo -e "\t| \t\t${app}-${MYSQL_VERSION} 部署成功！\t\t\t|"
            echo -e "\t| ${app}的默认配置文件路径：`printf '%-29s' "/etc/my.cnf"`|"
            echo -e "\t| ${app}的默认数据目录路径：`printf '%-29s' "/var/lib/mysql"`|"
            echo -e "\t| ${app}的更多教程可以访问：`printf '%-29s' https://www.lutixia.cn`|"
            echo -e "\t--------------------------------------------------------\033[0m"
            }  || \
            echo -e "\033[0;31m ${app}-${MYSQL_VERSION} 安装失败！\033[0m"
        elif [[ ${MYSQL_VERSION} == "5.6" ]];then
            yum-config-manager --disable mysql80-community mysql57-community &>/dev/null && \
            yum-config-manager --enable mysql56-community &>/dev/null  && \
            yum install ${app} ${app}-server -y && {\
            echo -e "\t\033[1;32m---------------------------------------------------------"
            echo -e "\t| \t\t${app}-${MYSQL_VERSION} 部署成功！\t\t\t|"
            echo -e "\t| ${app}的默认配置文件路径：`printf '%-29s' "/etc/my.cnf"`|"
            echo -e "\t| ${app}的默认数据目录路径：`printf '%-29s' "/var/lib/mysql"`|"
            echo -e "\t| ${app}的更多教程可以访问：`printf '%-29s' https://www.lutixia.cn`|"
            echo -e "\t--------------------------------------------------------\033[0m"
             } || \
            echo -e "\033[0;31m ${app}-${MYSQL_VERSION} 安装失败！\033[0m"
        elif [[ ${MYSQL_VERSION} == "5.7" ]];then
            yum-config-manager --disable mysql80-community &>/dev/null && \
            yum-config-manager --enable mysql57-community &>/dev/null  && \
            yum install ${app} ${app}-server -y && {\
            echo -e "\t\033[1;32m---------------------------------------------------------"
            echo -e "\t| \t\t${app}-${MYSQL_VERSION} 部署成功！\t\t\t|"
            echo -e "\t| ${app}的默认配置文件路径：`printf '%-29s' "/etc/my.cnf"`|"
            echo -e "\t| ${app}的默认数据目录路径：`printf '%-29s' "/var/lib/mysql"`|"
            echo -e "\t| ${app}的更多教程可以访问：`printf '%-29s' https://www.lutixia.cn`|"
            echo -e "\t--------------------------------------------------------\033[0m"
             } || \
            echo -e "\033[0;31m ${app}-${MYSQL_VERSION} 安装失败！\033[0m"
        else
            yum-config-manager --enable mysql80-community &>/dev/null  && \
            yum install ${app} ${app}-server -y && {\
            echo -e "\t\033[1;32m---------------------------------------------------------"
            echo -e "\t| \t\t${app}-${MYSQL_VERSION} 部署成功！\t\t\t|"
            echo -e "\t| ${app}的默认配置文件路径：`printf '%-29s' "/etc/my.cnf"`|"
            echo -e "\t| ${app}的默认数据目录路径：`printf '%-29s' "/var/lib/mysql"`|"
            echo -e "\t| ${app}的更多教程可以访问：`printf '%-29s' "https://www.lutixia.cn"`|"
            echo -e "\t--------------------------------------------------------\033[0m"
             } || \
            echo -e "\033[0;31m ${app}-${MYSQL_VERSION} 安装失败！\033[0m"
        fi
        } || \
		echo -e "\t\033[0;32m你还没有输入${app}版本！\033[0m"
	fi
}

# mysql 安装成功提示：
mysql_sucess() {
    echo -e "\t\033[1;32m-----------------------------------------------------------------"
    echo -e "\t| \t\t${app}-${MYSQL_VERSION} 部署成功！\t\t\t\t|"
    echo -e "\t| ${app}的默认安装目录路径：`printf '%-37s' ${INSTALL_MYSQL_PATH}`|"
    echo -e "\t| ${app}的默认配置文件路径：`printf '%-37s' ${INSTALL_MYSQL_PATH}/my.cnf`|"
    echo -e "\t| ${app}的默认数据目录路径：`printf '%-37s' ${DATA_DIR}`|"
    echo -e "\t| ${app}的更多教程可以访问：`printf '%-37s' https://www.lutixia.cn`|"
    echo -e "\t-----------------------------------------------------------------"
}

# 源码安装MySQL：
source_install_mysql() {
    #  mysql的安装版本：
    MYSQL_LIST=(5.5.60 5.7.36 8.0.27)
    # mysql的安装路径：
    INSTALL_MYSQL_PATH=${INSTALL_PATH}${app}
    # 数据目录：
    DATA_DIR=/data/mysql
	if [[ -d ${INSTALL_MYSQL_PATH} ]];then
		echo -e  "\t请核实!在\033[1;31m${INSTALL_MYSQL_PATH%/${app}}\033[0m目录下是否已安装${app}服务！"
	else
		echo -e "请输入${app}版本号：例如：${MYSQL_LIST[@]}\033[0;31m，推荐使用8.0版本\033[0m。"
        read -p "请参考上面的格式输入${app}版本号：" MYSQL_VERSION
        [[ -n ${MYSQL_VERSION} ]] && {\
        echo -e "\t\033[0;36m正在安装${app}-${MYSQL_VERSION},请稍等...\033[0m"
		yum install wget gcc libaio bison gcc-c++  git cmake  ncurses-devel  openssl-devel -y
		[[ $? -eq 0 ]] && {
            if [ ${MYSQL_VERSION} = "5.5.60" ];then
			    wget -c -P $BASE_DIR \
			    http://mirrors.163.com/mysql/Downloads/MySQL-5.5/mysql-${MYSQL_VERSION}.tar.gz
			    if [[ $? -ne 0 ]];then
			        echo -e "\t\033[0;31m ${app}-${MYSQL_VERSION}下载失败！请检查网络是否正常 or ${app}版本是否存在！\033[0m"
		        else
		            echo
			        cd $BASE_DIR
                    tar xf mysql-${MYSQL_VERSION}.tar.gz
                    cd mysql-${MYSQL_VERSION}
                    cmake . -DCMAKE_INSTALL_PREFIX=${INSTALL_MYSQL_PATH} \
					-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
					-DMYSQL_DATADIR=${DATA_DIR} \
					-DSYSCONFDIR=${INSTALL_PATH}/${app} \
					-DMYSQL_USER=mysql \
					-DMYSQL_TCP_PORT=3306 \
					-DWITH_XTRADB_STORAGE_ENGINE=1 \
					-DWITH_INNOBASE_STORAGE_ENGINE=1 \
					-DWITH_PARTITION_STORAGE_ENGINE=1 \
					-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
					-DWITH_MYISAM_STORAGE_ENGINE=1 \
					-DWITH_READLINE=1 \
					-DENABLED_LOCAL_INFILE=1 \
					-DWITH_EXTRA_CHARSETS=1 \
					-DDEFAULT_CHARSET=utf8 \
					-DDEFAULT_COLLATION=utf8_general_ci \
					-DEXTRA_CHARSETS=all \
					-DWITH_BIG_TABLES=1 \
					-DWITH_DEBUG=0
                    [ $? -eq 0 ] && {
                        make && make install
                        # 初始化MySQL：
                        [ $? -eq 0 ] && {
                        \cp support-files/my-large.cnf ${INSTALL_MYSQL_PATH}/my.cnf
                        \cp support-files/mysql.server /etc/init.d/mysqld
                        chmod +x  /etc/init.d/mysqld
                        mkdir -p ${DATA_DIR}
                        useradd -s /sbin/nologin mysql
                        chown -R mysql. ${DATA_DIR}
                        ${INSTALL_MYSQL_PATH}/scripts/mysql_install_db  --user=mysql \
                        --datadir=${DATA_DIR} --basedir=${INSTALL_MYSQL_PATH}
                        }
                        [[ $? -eq 0 ]] &&  \
                        mysql_sucess || \
                        echo -e "\033[0;31m ${app}-${MYSQL_VERSION} 安装失败！\033[0m"
			        }
			   fi
			elif [[ ${MYSQL_VERSION} = "5.7.36" ]];then
			    wget -cP ${BASE_DIR}  http://nchc.dl.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz && \
			    cd ${BASE_DIR} && tar xf boost_1_59_0.tar.gz && mv boost_1_59_0 /usr/local/boost && \
			    wget -cP ${BASE_DIR} \
			    https://mirrors.163.com/mysql/Downloads/MySQL-5.7/mysql-${MYSQL_VERSION}.tar.gz
			    if [[ $? -ne 0 ]];then
			        echo -e "\t\033[0;31m ${app}-${MYSQL_VERSION}下载失败！请检查网络是否正常 or ${app}版本是否存在！\033[0m"
		        else
			        cd ${BASE_DIR}
                    tar xf mysql-${MYSQL_VERSION}.tar.gz
                    cd mysql-${MYSQL_VERSION}
                    cmake . -DCMAKE_INSTALL_PREFIX=${INSTALL_MYSQL_PATH} \
                    -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
                    -DMYSQL_DATADIR=${DATA_DIR} \
                    -DSYSCONFDIR=${INSTALL_MYSQL_PATH} \
                    -DMYSQL_TCP_PORT=3306 \
                    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
                    -DWITH_PARTITION_STORAGE_ENGINE=1 \
                    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
                    -DWITH_MYISAM_STORAGE_ENGINE=1 \
                    -DWITH_READLINE=1 \
                    -DENABLED_LOCAL_INFILE=1 \
                    -DWITH_EXTRA_CHARSETS=1 \
                    -DDEFAULT_CHARSET=utf8 \
                    -DDEFAULT_COLLATION=utf8_general_ci \
                    -DEXTRA_CHARSETS=all \
                    -DWITH_DEBUG=0 \
                    -DENABLE_DTRACE=0 \
                    -DWITH_BOOST=/usr/local/boost

                    [[ $? -eq 0 ]] && {
                        make && make install
                        # 初始化MySQL：
                        [[ $? -eq 0 ]] && {
                            mkdir -p ${DATA_DIR}
                            useradd -s /sbin/nologin mysql
                            chown -R mysql. ${DATA_DIR}
                            cp support-files/mysql.server /etc/init.d/mysqld
                            chmod +x  /etc/init.d/mysqld
                            cat > ${INSTALL_MYSQL_PATH}/my.cnf <<-EOF
                            [mysqld]
                            basedir=${INSTALL_MYSQL_PATH}
                            datadir=${DATA_DIR}
                            port=3306
                            pid-file=${DATA_DIR}/mysql.pid
                            socket=/tmp/mysql.sock

                            [mysqld_safe]
                            log-error=/${DATA_DIR}/mysql.log
EOF

                            # 初始化
                            ${INSTALL_MYSQL_PATH}/bin/mysqld --initialize --user=mysql --datadir=${DATA_DIR} \
                            --basedir=${INSTALL_MYSQL_PATH}
                            [[ $? -eq 0 ]] && \
                            mysql_sucess || \
                            echo -e "\033[0;31m ${app}-${MYSQL_VERSION} 安装失败！\033[0m"
                        }
                    }
                fi
		    fi
		    }
		} || \
		echo -e "\t\033[0;32m你还没有输入${app}版本！\033[0m"
	fi
}

yum_install_redis() {
    rpm  -q ${app} &>/dev/null
    if [[ $? -eq 0 ]];then
        INSTALLED_REDIS_VERSION=`rpm -q redis | awk -F"-" '{print $1"-"$2}'`
        echo -e  "\t请核实!\033[1;31m 系统已安装${INSTALLED_REDIS_VERSION}版本！\033[0m"
    else
        yum install ${app} -y && {\
        INSTALLED_REDIS_VERSION=`rpm -q redis | awk -F"-" '{print $1"-"$2}'`
        echo -e "\t\033[1;32m---------------------------------------------------------" && \
        echo -e "\t| \t\t${INSTALLED_REDIS_VERSION} 部署成功！\t\t\t|"
        echo -e "\t| ${app}的默认配置文件路径：`rpm -qc ${app} | awk '/redis.conf/{printf "%-29s\n", $0}'`|"
        echo -e "\t| ${app}的默认数据目录路径：`rpm -ql ${app} | awk '/lib\/redis/{printf "%-29s\n", $0}'`|"
        echo -e "\t| ${app}的更多教程可以访问：`printf '%-29s' https://www.lutixia.cn`|"
        echo -e "\t--------------------------------------------------------\033[0m"  || \
        echo -e "\033[0;31m ${app}-${NGINX_VERSION} 安装失败！\033[0m"
        } || \
        echo -e "\t\033[0;31m安装${app}失败！\033[0m"
    fi
}

source_install_redis() {
     # redis的安装版本：
    REDIS_LIST=(4.0.8 5.0.6 5.0.12 6.2.0)
    # redis的安装路径：
    INSTALL_REDIS_PATH=${INSTALL_PATH}${app}
    REDIS_IP="0.0.0.0"
    REDIS_PORT="6379"

    if [[ -d ${INSTALL_REDIS_PATH} ]];then
        echo -e  "\t在\033[1;31m${INSTALL_REDIS_PATH%${app}}\033[0m目录下是否已安装${app}服务,请核实!"
    else
        echo -e "请输入${app}版本号：例如：${REDIS_LIST[@]}\033[0;31m，推荐使用5.0.6版本\033[0m。"
        read -p "请参考上面的格式输入${app}版本号：" REDIS_VERSION
        [[ -n ${REDIS_VERSION} ]] && {\
            echo -e "\t\033[0;36m正在安装${app}-${REDIS_VERSION},请稍等...如果想退出，请按Ctrl + c ！\033[0m" && \
            sleep 2
            if [[ ${REDIS_VERSION} == 6* ]];then
                # 配置源：
                yum -y install centos-release-scl && \
                yum -y install devtoolset-9-gcc && \
                export PKG_CONFIG_PATH="/opt/rh/devtoolset-9/root/usr/lib64/pkgconfig"
                export LD_LIBRARY_PATH="/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib:/opt/rh/devtoolset-9/root/usr/lib64/dyninst:/opt/rh/devtoolset-9/root/usr/lib/dyninst:/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib"
                export PATH="/opt/rh/devtoolset-9/root/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin"
                export PCP_DIR="/opt/rh/devtoolset-9/root"
                export X_SCLS="devtoolset-9"
                cd /usr/src/ && \
                wget -c http://download.redis.io/releases/${app}-${REDIS_VERSION}.tar.gz &>/dev/null
                if [[ $? -eq 0 ]];then
                    tar xf  ${app}-${REDIS_VERSION}.tar.gz
                    cd ${app}-${REDIS_VERSION}  && make PREFIX=${INSTALL_REDIS_PATH}  install && {\
                    sed -i '77,84s/^/#/' /usr/src/${app}-${REDIS_VERSION}/utils/install_server.sh
                    echo -e "${REDIS_PORT}\n${INSTALL_REDIS_PATH}/$REDIS_PORT/$REDIS_PORT.conf\n${INSTALL_REDIS_PATH}/$REDIS_PORT/$REDIS_PORT.log\n${INSTALL_REDIS_PATH}/$REDIS_PORT\n${INSTALL_REDIS_PATH}/bin/redis-server" \
                             | /usr/src/${app}-${REDIS_VERSION}/utils/install_server.sh
                    sed -i "/^bind/cbind $REDIS_IP" ${INSTALL_REDIS_PATH}/${REDIS_PORT}/${REDIS_PORT}.conf
                    echo -e "\t\033[1;32m-----------------------------------------------------------------"
                    echo -e "\t| \t\t${app}-${REDIS_VERSION} 部署成功！\t\t\t\t|"
                    echo -e "\t| ${app}的默认安装目录路径：`printf '%-37s' ${INSTALL_REDIS_PATH}`|"
                    echo -e "\t| ${app}的默认配置文件路径：`printf '%-37s' ${INSTALL_REDIS_PATH}/${REDIS_PORT}/${REDIS_PORT}.conf`|"
                    echo -e "\t| ${app}的默认数据目录路径：`printf '%-37s' ${INSTALL_REDIS_PATH}/${REDIS_PORT}`|"
                    echo -e "\t| ${app}的默认启动脚本路径：`printf '%-37s' /etc/init.d/${app}_${REDIS_PORT}`|"
                    echo -e "\t| ${app}的更多教程可以访问：`printf '%-37s' https://www.lutixia.cn`|"
                    echo -e "\t-----------------------------------------------------------------\033[0m"
                    } || \
                    echo -e "\033[0;31m ${app}-${REDIS_VERSION} 安装失败！\033[0m"
                else
                    echo -e "\t\033[0;31m ${app}-${REDIS_VERSION}下载失败！请检查网络是否正常 or ${app}-${REDIS_VERSION}版本是否存在！\033[0m"
                fi
            else
                cd /usr/src/ && \
                wget -c http://download.redis.io/releases/${app}-${REDIS_VERSION}.tar.gz &>/dev/null
                if [[ $? -eq 0 ]];then
                    tar xf  ${app}-${REDIS_VERSION}.tar.gz
                    cd ${app}-${REDIS_VERSION}  && make PREFIX=${INSTALL_REDIS_PATH}  install && {\
                    echo -e "${REDIS_PORT}\n${INSTALL_REDIS_PATH}/$REDIS_PORT/$REDIS_PORT.conf\n${INSTALL_REDIS_PATH}/$REDIS_PORT/$REDIS_PORT.log\n${INSTALL_REDIS_PATH}/$REDIS_PORT\n${INSTALL_REDIS_PATH}/bin/redis-server" \
                             | /usr/src/${app}-${REDIS_VERSION}/utils/install_server.sh
                    sed -i "/^bind/cbind $REDIS_IP" ${INSTALL_REDIS_PATH}/${REDIS_PORT}/${REDIS_PORT}.conf
                    echo -e "\t\033[1;32m-----------------------------------------------------------------"
                    echo -e "\t| \t\t${app}-${REDIS_VERSION} 部署成功！\t\t\t\t|"
                    echo -e "\t| ${app}的默认安装目录路径：`printf '%-37s' ${INSTALL_REDIS_PATH}`|"
                    echo -e "\t| ${app}的默认配置文件路径：`printf '%-37s' ${INSTALL_REDIS_PATH}/${REDIS_PORT}/${REDIS_PORT}.conf`|"
                    echo -e "\t| ${app}的默认数据目录路径：`printf '%-37s' ${INSTALL_REDIS_PATH}/${REDIS_PORT}`|"
                    echo -e "\t| ${app}的默认启动脚本路径：`printf '%-37s' /etc/init.d/${app}_${REDIS_PORT}`|"
                    echo -e "\t| ${app}的更多教程可以访问：`printf '%-37s' https://www.lutixia.cn`|"
                    echo -e "\t-----------------------------------------------------------------\033[0m"
                    } || \
                    echo -e "\033[0;31m ${app}-${REDIS_VERSION} 安装失败！\033[0m"
                else
                    echo -e "\t\033[0;31m ${app}-${REDIS_VERSION}下载失败！请检查网络是否正常 or ${app}-${REDIS_VERSION}版本是否存在！\033[0m"
                fi
            fi
        } || \
        echo -e "\t\033[0;32m你还没有输入${app}版本！\033[0m"
    fi
}
#------------------------------------------------------------------------------------


#---------------------------------系统资源函数------------------------------------------

system_list=(cpu disk memory exit)

#CPU基本信息：
cpu_base() {
    echo -e "\t\t\033[0;36mcpu的基本信息...\033[0m"
    echo -e "\033[0;30m------------------------------------------------\033[0m"
    echo "CPU型号：`cat /proc/cpuinfo  | awk -F:  '/model name/{printf "%-25s",$2}'`"
    echo "CPU核心数：`lscpu | awk -F:  'NR==4{printf "%-25s",$2}'`"
    echo "CPU主频：`lscpu | awk -F:  '/MHz/{printf "%-25s",$2}'`"
    echo -e "\033[0;30m------------------------------------------------\033[0m"
}

# CPU占用率排行
cpu_info() {
    echo -e "\t\t\033[0;36mcpu占用率前十进程...\033[0m"
    echo -e "\033[0;30m------------------------------------------------\033[0m"
    ps -eo pcpu,cpu,state,cputime,cmd --sort -pcpu | awk 'NR<=10&&!(/0\.0/)'
    echo -e "\033[0;30m------------------------------------------------\033[0m"
}

# CPU负载信息：
cpu_load() {
    echo -e "\t\t\033[0;36mcpu的负载情况...\033[0m"
    echo -e "\033[0;30m------------------------------------------------\033[0m"
    echo "CPU load in 1  min is: `awk  '{printf "%15s",$1}' /proc/loadavg`"
    echo "CPU load in 5  min is: `awk  '{printf "%15s",$2}' /proc/loadavg`"
    echo "CPU load in 10 min is: `awk  '{printf "%15s",$3}' /proc/loadavg`"
    echo -e "\033[0;30m------------------------------------------------\033[0m"
}

# mem基本信息：
memory_info() {
    echo -e "\t\t\033[0;36m内存的基本信息...\033[0m"
    echo -e "\033[0;30m------------------------------------------------\033[0m"
    echo "`free -h | awk '/Mem/{printf "%-10s %s","内存总容量:",$2}'`"
    echo "`free -h | awk '/Mem/{printf "%-10s %s","内存空闲容量:",$4}'`"
    echo "`free -h | awk '/Mem/{printf "%-10s %s","内存缓存:",$6}'`"
    echo -e "\033[0;30m------------------------------------------------\033[0m"
}

# 磁盘使用量排序：
disk_rank() {
    echo -e "\t\t\033[0;36m各分区使用率从高到低排序...\033[0m"
    echo -e "\033[0;30m------------------------------------------------\033[0m"
    df -h -x tmpfs -x devtmpfs | ( read   one ;  echo "$one" ;sort -nr -k 5)
    echo -e "\033[0;30m------------------------------------------------\033[0m"
}

system_info() {
    echo "请选择你要查看的系统资源："
    select system_choice in `echo ${system_list[@]}`;do
        case ${system_choice} in
            "cpu")
                cpu_base
                echo
                cpu_info
                echo
                cpu_load
                ;;
            "disk")
                disk_rank
                ;;
            "memory")
                memory_info
                ;;
            "exit")
                system_menu
                ;;
            *)
                echo -e "\033[0;31m\t请输入正确数字编号！\033[0m"
                ;;
        esac
        echo -e "\033[0;30m------------------------------------------------\033[0m"
        system_info
    done
}


#------------------------------------------------------------------------------------

# 安装服务次菜单：
apps_list() {
    echo -e "\033[0;32m-------------------------------------------------------------------------\033[0m"
    echo  "请选择你要安装的服务："
    select app in  `echo ${APPS[@]}`;do
        case ${app} in
            "nginx")
                    if [[ ${choice} == "yum" ]];then
                        yum_install_nginx
                    else
                        source_install_nginx
                    fi
                    ;;
            "mysql")
                    if [[ ${choice} == "yum" ]];then
                        yum_install_mysql
                    else
                        source_install_mysql
                    fi
                    ;;
            "redis")
                    if [[ ${choice} == "yum" ]];then
                        yum_install_redis
                    else
                        source_install_redis
                    fi
                    ;;
            "exit")
                    install_apps
                    ;;
            *)
                    echo -e "\t\033[0;31m请输入正确数字编号！\033[0m"
                    ;;
        esac
        apps_list
    done
}

# 安装服务主菜单：选择安装包的方式是源码还是yum
install_apps() {
    echo
    echo -e "请选择\033[4;36m源码部署\033[0m还是\033[4;36myum部署\033[0m:"
    select choice in  源码  yum  exit;do
         case ${choice} in
              "源码"|"yum")
                 apps_list
                  ;;
              "exit")
                  main
                  ;;
              *)
                    echo -e "\033[0;31m\t请输入正确数字编号！\033[0m"
                    ;;
          esac
    done
}


# 系统菜单：
system_menu() {
    clear
    SYSTEM_NAME=`cat /etc/redhat-release | awk '{print $1,$4}'`

    echo -e "\t\t${SYSTEM_NAME%%.*} 系统菜单"
    echo -e "\033[0;32m-------------------------------------------------\033[0m"
    echo -e "\t\t1、常见服务部署"
    echo -e "\t\t2、系统资源查看"
    echo -e "\t\t3、退出"
    echo -e "\033[0;32m-------------------------------------------------\033[0m"

    read -p "请输入对应的数字编号：" SYSTEM_CHOICE
    case ${SYSTEM_CHOICE} in
          1)
                echo
                # 检查网络：
                echo -e "\t\033[0;36m正在检查网络,请稍等...\033[0m"
                ping -c2 baidu.com &>/dev/null && echo -e "\t\033[0;32m网络正常,请继续！\033[0m\n-------------------------------------------------" \ || {
                echo -e "\t\033[0;31m网络异常!请再次核实网络配置!\033[0m" && exit; }
                install_apps
                ;;
          2)
                echo
                system_info
                ;;
          3)
                echo
                exit
                ;;
     esac
}

check_root() {
	[[ $UID -ne 0 ]] &&  echo -e "\033[0;31m 请使用管理员权限执行该脚本！\033[0m"
}

# 脚本主程序函数
main() {
    check_root
    system_menu
}

main

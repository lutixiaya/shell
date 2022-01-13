#!/usr/bin/env bash
# by 运维朱工
# site：www.lutixia.cn
####################################

APP=nginx
NGINX_VERSION=1.18.0
BASE_DIR=/usr/src/
INSTALL_NGINX_PATH=/usr/local/nginx
CONFIG_OPTIONS="--prefix=${INSTALL_NGINX_PATH} \
               --with-http_stub_status_module"

auto_install_nginx() {
	if [ -d ${INSTALL_NGINX_PATH} ];then
		echo -e  "\t在\033[1;31m${INSTALL_NGINX_PATH%${APP}}\033[0m目录下是否已安装${APP}服务,请核实!"
	else
        echo -e "\t\033[0;36m正在安装${APP}-${NGINX_VERSION},请稍等...\033[0m"
        # 安装依赖：
		yum install wget pcre-devel zlib-devel -y >/dev/null && \
		wget -c -P "${BASE_DIR}" http://nginx.org/download/${APP}-${NGINX_VERSION}.tar.gz
		if [[ $? -ne 0 ]];then
			echo -e "\t\033[0;31m ${APP}-${NGINX_VERSION}下载失败！请检查网络是否正常 or ${APP}版本是否存在！\033[0m"
		else
			cd "$BASE_DIR"
			tar xf ${APP}-${NGINX_VERSION}.tar.gz
			cd ${APP}-${NGINX_VERSION}
			./configure ${CONFIG_OPTIONS} && make && make install && \
			echo -e "\t\033[1;32m-----------------------------------------------------------------"
            echo -e "\t| \t\t${APP}-${NGINX_VERSION} 部署成功！\t\t\t\t|"
            echo -e "\t| ${APP}的默认安装目录路径：`printf '%-37s' ${INSTALL_NGINX_PATH}`|"
            echo -e "\t| ${APP}的默认配置文件路径：`printf '%-37s' ${INSTALL_NGINX_PATH}/conf/nginx.conf`|"
            echo -e "\t| ${APP}的默认发布目录路径：`printf '%-37s' ${INSTALL_NGINX_PATH}/html`|"
            echo -e "\t| ${APP}的更多教程可以访问：`printf '%-37s' https://www.lutixia.cn`|"
            echo -e "\t-----------------------------------------------------------------\033[0m"   || \
			echo -e "\033[0;31m ${APP}-${NGINX_VERSION} 安装失败！\033[0m"
		fi
	fi
}

auto_install_nginx

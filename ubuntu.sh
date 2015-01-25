#!/bin/bash

TMP_DIR=`dirname $0`
OPERATE=$1
ISO_NAME="ubuntu-14.04.1-desktop-i386.iso"


#检查是否以sudo权限运行
check_user() {
    if [ $UID != 0 ];then
        echo "请用sudo运行本脚本，使用类似如下的命令："
        echo -e "\033[34m  sudo\033[0m ./ubuntu.sh custom"
        exit 1
    fi
}

#检查参数和变量
check_param() {
    #提示命令后面需要输入操作
    if [ -z $OPERATE ]; then
        echo -e "请在命令后输入参数：init或custom或clean,例如：sudo ./ubuntu.sh\033[34m init\033[0m " 
        echo "  1、init:初始化环境，在同一个系统中只需执行一次，以后就不需要执行了 "
        echo "  2、custom:开始定制系统"
        echo "  3、clean:清除定制过程中产生的多余文件"
        exit
    fi

    #如果$TMP_DIR为空则退出,防止出现严重错误
    if [ -z $TMP_DIR ]; then
        echo "定制失败..."
        exit
    fi
}

#检查是否安装了需要的软件
check_depend() {
    if [ ! -x /usr/bin/uck-remaster ] && [ $OPERATE != "init" ]; then
        echo -e "请先执行命令sudo ./ubuntu.sh\033[34m init\033[0m"
        exit
    fi
}


#初始化，安装所需的软件UCK
initialize() {
    apt-get update
    apt-get -y install uck
    cp -f ${TMP_DIR}/extra-files/remaster-live-cd.sh /usr/lib/uck/remaster-live-cd.sh
    if [ ! -x /usr/bin/uck-remaster ]; then
        chmod a+x /usr/bin/uck-remaster
    fi
}

#定制系统
customize() {
    if [ ! -e $HOME/${ISO_NAME} ]; then
        echo "请将用于定制的原始ubuntu镜像复制到主目录，并重命名为${ISO_NAME}"
        exit
    fi
    uck-remaster $HOME/${ISO_NAME} ${TMP_DIR}/customization-scripts ${TMP_DIR}
}

#清理UCK自动生成和定制脚本下载的多余文件
clean() {
    echo "正在清除脚本自动产生的文件..."
    rm -rf ${TMP_DIR}/remaster-apt-cache ${TMP_DIR}/remaster-new-files
    rm -rf ${TMP_DIR}/remaster-iso ${TMP_DIR}/remaster-root ${TMP_DIR}/remaster-root-home
    rm -rf ${TMP_DIR}/customization-scripts/tdx/{*.deb,*.vbox-extpack}
    rm -rf ${TMP_DIR}/customization-scripts/tdx/FontPack*.tar.gz
    if [ -d ${TMP_DIR}/remaster-iso-mount ]; then
        umount ${TMP_DIR}/remaster-iso-mount
        rm -rf ${TMP_DIR}/remaster-iso-mount
    fi
    echo "清除完成"
}

#-----------------------------主程序开始---------------------------------------
check_user
check_depend
check_param

if [ "$1" == "init" ]; then
    initialize
elif [ "$1" == "custom" ]; then
    customize
elif [ "$1" == "clean" ]; then
    clean
else
    echo -e "请在命令后输入参数：\033[34minit\033[0m或\033[34mcustom\033[0m或\033[34mclean\033[0m,例如：sudo ./ubuntu.sh init" 
    echo "  1、init:初始化环境，在同一个系统中只需执行一次，以后就不需要执行了 "
    echo "  2、custom:开始定制系统"
    echo "  3、clean:清除定制过程中产生的多余文件"
    exit
fi

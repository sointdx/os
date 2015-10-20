#!/bin/bash

TMP_DIR=`dirname $0`
#改成绝对路径
TMP_DIR=`cd ${TMP_DIR};pwd`
OPERATE=$1
# 32位镜像名字必须要包含i386字样，64位镜像名字不能包含i386字样，
# 后面以此判断安装不同的软件包
ISO_NAME="ubuntu-14.04.3-desktop-i386.iso"
ISO_NONPAE="ubuntu-14.04.3-desktop-i386-custom.iso"

# 定义ARCH变量
if ( echo ${ISO_NAME} | grep -i "i386" ); then
    export ARCH="i386"
else
    export ARCH="amd64"
fi


#检查是否以sudo权限运行
check_user() {
    if [ $UID != 0 ];then
        echo "请用sudo运行本脚本，使用类似如下的命令："
        echo -e "\033[34m  sudo\033[0m ./tdxos.sh custom"
        exit 1
    fi
}

#检查参数和变量
check_param() {
    #提示命令后面需要输入操作
    if [ -z $OPERATE ]; then
        echo -e "请在命令后输入参数：init或custom或clean,例如：sudo ./tdxos.sh\033[34m init\033[0m " 
        echo "  1、init:初始化环境，在同一个系统中只需执行一次，以后就不需要执行了 "
        echo "  2、custom:开始定制系统"
        echo "  3、nonpae:使镜像支持没有物理地址扩展功能的电脑"
        echo "  4、clean:清除定制过程中产生的多余文件"
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
        echo -e "请先执行命令sudo ./tdxos.sh\033[34m init\033[0m"
        exit
    fi
}


#初始化，安装所需的软件UCK
initialize() {
    apt-get update
    apt-get -y install uck syslinux
    
    #给UCK打补丁
    if [ -f /usr/lib/uck/remaster-live-cd.sh ] && [ -f /usr/lib/uck/remaster-live-cd.bak ]; then
        changes=`diff /usr/lib/uck/remaster-live-cd.sh /usr/lib/uck/remaster-live-cd.bak`
    else
        b_patched=false
    fi
    if [ ! -z "${changes}" ] || ! ${b_patched}; then
        patch -b /usr/lib/uck/remaster-live-cd.sh < ${TMP_DIR}/extra-files/remaster-live-cd.patch
        cp /usr/lib/uck/remaster-live-cd{.sh,.bak}
    fi

    if [ ! -x /usr/bin/uck-remaster ]; then
        chmod a+x /usr/bin/uck-remaster
    fi
    #复制定制时需要的文件
    cp -f /usr/lib/uck/gui.sh ${TMP_DIR}/customization-scripts/gui.sh
    cp -f /usr/lib/uck/customization-profiles/localized_cd/customize_iso ${TMP_DIR}/customization-scripts/customize_iso
    if [ ! -f ${TMP_DIR}/customization-scripts/customize ]; then
        cp -f /usr/lib/uck/customization-profiles/localized_cd/customize ${TMP_DIR}/customization-scripts/customize
        cat >> ${TMP_DIR}/customization-scripts/customize << EOF

cd /tmp/customization-scripts/tdx
#set locale
export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:en_US:en
export LC_CTYPE="zh_CN.UTF-8"
export LC_NUMERIC=zh_CN.UTF-8
export LC_TIME=zh_CN.UTF-8
export LC_COLLATE="zh_CN.UTF-8"
export LC_MONETARY=zh_CN.UTF-8
export LC_MESSAGES="zh_CN.UTF-8"
export LC_PAPER=zh_CN.UTF-8
export LC_NAME=zh_CN.UTF-8
export LC_ADDRESS=zh_CN.UTF-8
export LC_TELEPHONE=zh_CN.UTF-8
export LC_MEASUREMENT=zh_CN.UTF-8
export LC_IDENTIFICATION=zh_CN.UTF-8

bash tdx.sh
EOF
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
    #rm -rf ${TMP_DIR}/remaster-apt-cache ${TMP_DIR}/remaster-new-files
    rm -rf ${TMP_DIR}/remaster-iso 
    #rm -rf ${TMP_DIR}/remaster-root ${TMP_DIR}/remaster-root-home
    rm -rf ${TMP_DIR}/customization-scripts/tdx/{*.deb,*.vbox-extpack}
    #rm -rf ${TMP_DIR}/customization-scripts/tdx/FontPack*.tar.gz
    if [ -d ${TMP_DIR}/remaster-iso-mount ]; then
        umount ${TMP_DIR}/remaster-iso-mount
        rm -rf ${TMP_DIR}/remaster-iso-mount
    fi
    if [ -d ${TMP_DIR}/remaster-root ] || [ -d ${TMP_DIR}/remaster-root-home ]; then
        echo "您需要重启后手动删除目录${TMP_DIR}/remaster-root和${TMP_DIR}/remaster-root-home"
        exit
    fi
    echo "清除完成"
}

#重新生成定制完成的镜像，使其支持没有物理地址扩展功能的电脑
regenerate() {
    if [ -e /mnt/old ] || [ -e /mnt/new ];then
        echo "重新制作失败，检测到/mnt/old或者/mnt/new目录已经存在"
        echo "请检查这两个目录是否有重要文件，并手动删除目录后重新运行命令生成镜像"
        exit
    fi

    mkdir -p /mnt/old
    mkdir -p /mnt/new
    if [ -f ${TMP_DIR}/remaster-new-files/livecd.iso ]; then
        mount ${TMP_DIR}/remaster-new-files/livecd.iso /mnt/old
        echo "正在重新制作镜像使系统支持没有物理地址扩展功能的电脑..."
    else
        rm -rf /mnt/old
        rm -rf /mnt/old
        echo "重新制作失败"
        echo "请将源镜像复制到${TMP_DIR}/remaster-new-files/livecd.iso"
        exit
    fi

    cp -rp /mnt/old/* /mnt/new
    #隐藏的文件夹也需要拷贝，否则重新制作的镜像不能被“启动盘创建器”识别
    cp -rp /mnt/old/.disk /mnt/new
    #支持non-pae的电脑
    cp -f ${TMP_DIR}/extra-files/txt.cfg /mnt/new/isolinux

    #安装完系统不自动卸载gparted
    line_num=`awk '$1=="gparted" {print NR}' /mnt/new/casper/filesystem.manifest-remove`
    sed -i "${line_num}d" /mnt/new/casper/filesystem.manifest-remove

    #重新制作镜像
    mkisofs -D -r -V "tdxos2.0" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ${HOME}/${ISO_NONPAE} /mnt/new

    rm -rf /mnt/new
    umount /mnt/old && rm -rf /mnt/old
    if [ -e ${ISO_NONPAE} ]; then
        chmod a+rw ${ISO_NONPAE}
    fi
}

#-----------------------------主程序开始---------------------------------------
check_user
check_depend
check_param

if [ "$1" == "init" ]; then
    initialize
elif [ "$1" == "custom" ]; then
    customize
elif [ "$1" == "nonpae" ]; then
    regenerate
elif [ "$1" == "clean" ]; then
    clean
else
    echo -e "请在命令后输入参数：\033[34minit\033[0m或\033[34mcustom\033[0m或\033[34mnonpae\033[0m或\033[34mclean\033[0m"
    echo -e "例如：sudo ./tdxos.sh init" 
    echo "  1、init:初始化环境，在同一个系统中只需执行一次，以后就不需要执行了 "
    echo "  2、custom:开始定制系统"
    echo "  3、nonpae:使镜像支持没有物理地址扩展功能的电脑"
    echo "  4、clean:清除定制过程中产生的多余文件"
    exit
fi

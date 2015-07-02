#!/bin/bash

export WD_DIR=/tmp/customization-scripts/tdx
# main restricted universe multiverse的区别
#
# 这是按软件的自由度来分的。
# main:完全的自由软件。
# restricted:不完全的自由软件。
# universe:ubuntu官方不提供支持与补丁，全靠社区支持。
# muitiverse：非自由软件，完全不提供支持和补丁。
#
# backport proposed security updated的区别
#
# 简单的解释：
# 基础：由于ubuntu是每6个月发行一个新版，当发行后，所有软件包的版本在这六个月内将保持不变，即使是有新版都不更新。除开重要的安全补丁外，所有新功能和非安全性补丁将不会提供给用户更新。
#
# security：仅修复漏洞，并且尽可能少的改变软件包的行为。低风险。
# backports：backports 的团队则认为最好的更新策略是 security 策略加上新版本的软件（包括候选版本的）。但不会由Ubuntu security team审查和更新。
# update：修复严重但不影响系统安全运行的漏洞，这类补丁在经过QA人员记录和验证后才提供，和security那类一样低风险。
# proposed：update类的测试部分，仅建议提供测试和反馈的人进行安装。
#
# 个人认为：
# 1.重要的服务器：用发行版默认的、security 
# 2.当有要较新软件包才行能运作的服务器：用发行版默认的、 security、（backports 还是不适合） 
# 3.一般个人桌面：用发行版默认的、 security、backports、update
# 4.追求最新、能提供建议和反馈大虾：发行版默认的、 security、backports、update、proposed 全部用上！

cat > /etc/apt/sources.list << EOF
deb http://archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse
EOF

#更新系统中的软件信息
apt-get update

#卸载不需要的软件
bash files/uninstall.sh

# not to upgrade libpam-systemd in chroot
# https://bugs.launchpad.net/ubuntu/+source/systemd/+bug/1325142  #9
# fix:/etc/init.d/systemd-logind not found
echo "libpam-systemd hold"|dpkg --set-selections

# 升级系统
apt-get -y dist-upgrade

#安装gdebi和synaptic，方便会员以后安装软件，用gdebi安装deb文件可以自动解决依赖问题，定制脚本后面会用到
apt-get -y install --no-install-recommends gdebi synaptic

apt-get -y install xfce4 alacarte xfce4-power-manager-plugins xfce4-whiskermenu-plugin xfce4-indicator-plugin
bash ./files/desktop/desktop.sh
xfconf-query -c xsettings -p /Net/ThemeName -s Bluediance
#卸载xfce的屏幕保护程序，默认用ubuntu的锁屏
apt-get -y purge xscreensaver
#禁用客人会话、设置默认桌面为xfce
#https://wiki.ubuntu.com/LightDM#Change_the_Default_Session
mkdir -p /etc/lightdm/lightdm.conf.d/
cat > /etc/lightdm/lightdm.conf.d/50-myconfig.conf << EOF
[SeatDefaults]
allow-guest=false
user-session=xfce
EOF
#https://tiandixing.org/viewtopic.php?f=83&t=165713&start=50#p1003656 
cp files/Thunar.mo /usr/share/locale/zh_CN/LC_MESSAGES/

#设置文件的默认打开方式
mkdir -p /etc/skel/.local/share/applications
cp ./files/mimeapps.list /etc/skel/.local/share/applications/

#光盘刻录
p=`pwd`
apt-get -y install --no-install-recommends ntrack-module-libnl-0
ls -l /usr/share/doc/ntrack-module-libnl-0/
cd /usr/share/doc/
mv ntrack-module-libnl-0 ntrack-module-libnl-0_original_but_bad
mkdir ntrack-module-libnl-0
cd ntrack-module-libnl-0
touch AUTHORS NEWS.gz README.gz copyright changelog.Debian.gz
apt-get -y install --no-install-recommends libntrack0
cd $p

#apt-get install -y --no-install-recommends k3b
# k3b 中文翻译
# https://tiandixing.org/viewtopic.php?f=83&t=126432#p711511
#apt-get install -y --no-install-recommends language-pack-kde-zh-hans
#安装多刻录机软件
gdebi --n deb/cdrecord_3.01a22-0ubuntu1~trusty~cdrtoolsppa4_${ARCH}.deb
gdebi --n deb/cdrg_1.1.2-0tdx1_${ARCH}.deb

#安装linuxmint的图标主题,图标主题和定制桌面有关系，定制桌面时用的是Mint-X
gdebi --n deb/mint-x-icons_1.1.8_all.deb
#更新icon缓存文件
gtk-update-icon-cache /usr/share/icons/Mint-X/
gtk-update-icon-cache /usr/share/icons/Mint-X-Dark/

#安装U盘格式化工具
gdebi --n deb/mintstick_1.2.1_all.deb

#安装truecrypt
gdebi --n deb/truecrypt_7.1a-3tdx1_${ARCH}.deb
#设置truecrypt
#https://www.tiandixing.org/viewtopic.php?f=83&t=135512&start=100#p775098
mkdir -p /etc/skel/.TrueCrypt
cp ./files/Configuration.xml /etc/skel/.TrueCrypt/Configuration.xml

#安装离线驱动管理软件，可以离线安装无线网卡的驱动
gdebi --n deb/tdxdrivers_1.0.4-0tdx1_all.deb

#截屏软件就用shutter
#http://tiandixing.org/viewtopic.php?f=83&t=125741#p707943
apt-get -y install shutter

#解压缩http://tiandixing.org/viewtopic.php?f=83&t=125964#p708191
apt-get -y install --no-install-recommends thunar-archive-plugin p7zip-full unrar

#linux下验证md5与sha1的软件http://tiandixing.org/viewtopic.php?f=83&t=125716#p706494
apt-get -y install --no-install-recommends gtkhash

#根据文件名称或者内容搜索文件
apt-get -y install --no-install-recommends gnome-search-tool

# 图片浏览软件
# https://tiandixing.org/viewtopic.php?f=83&t=126388
apt-get install -y --no-install-recommends gthumb

#安装小闹钟
apt-get -y install --no-install-recommends alarm-clock-applet

#安装启动盘创建器
apt-get -y install usb-creator-common usb-creator-gtk

#让用户可以设置成XP的样式
apt-get -y install --no-install-recommends xfwm4-themes gtk3-engines-xfce gtk2-engines-xfce

#设置火狐
tar xzf files/mozilla.tar.gz -C /etc/skel

# 打印光盘封面
# https://tiandixing.org/viewtopic.php?f=83&t=124640
apt-get -y install glabels

# chm viewer
# https://tiandixing.org/viewtopic.php?f=83&t=125722
#安装chm查看软件http://tiandixing.org/viewtopic.php?f=86&t=126006&p=708694#p708895
#apt-get -y install --no-install-recommends chmsee
#https://tiandixing.org/viewtopic.php?f=86&t=157467&p=885741#p885741
gdebi --n deb/chmsee_1.3.0-2ubuntu2_${ARCH}.deb

#timezone
echo "Asia/Shanghai" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata
sed -i 's/UTC=yes/UTC=no/' /etc/default/rcS

# 安装最新的flash
# http://tiandixing.org/viewtopic.php?f=83&t=125035&p=703877&hilit=flashplugin+installer#p703175
FLASHNAME=adobe-flashplugin_20150609.1-0trusty1_${ARCH}.deb
if [ ! -f ${FLASHNAME} ]; then
    wget http://archive.canonical.com/pool/partner/a/adobe-flashplugin/${FLASHNAME}
fi
dpkg -i ${FLASHNAME}

# Virtualbox
apt-get -y install virtualbox
#只用上面一条命令定制的系统virtualbox不能用，执行以下命令就可以成功
apt-get -y install virtualbox-qt
apt-get -y install virtualbox-dkms
apt-get -y install --reinstall virtualbox-dkms
#安装guest additions iso image for virtualbox
apt-get -y install virtualbox-guest-additions-iso

#安装virtualbox增强功能包
if [ ! -f Oracle_VM_VirtualBox_Extension_Pack-4.3.10-93012.vbox-extpack ]; then
    wget http://download.virtualbox.org/virtualbox/4.3.10/Oracle_VM_VirtualBox_Extension_Pack-4.3.10-93012.vbox-extpack
fi
VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-4.3.10-93012.vbox-extpack

# 视频播放器
apt-get install -y --no-install-recommends vlc
# 使vlc不自动联网下载所播放文件的专辑等信息
mkdir -p /etc/skel/.config/vlc/
cp $WD_DIR/files/vlcrc /etc/skel/.config/vlc/vlcrc

#安装fcitx拼音、双拼和五笔
apt-get -y install fcitx-pinyin fcitx-table-wubi
#安装手写识别软件Tegaki
apt-get -y install python-tegaki python-tegaki-gtk tegaki-recognize tegaki-zinnia-simplified-chinese tegaki-zinnia-traditional-chinese

#安装和汉化gpa
apt-get -y install gpa
mkdir -p /usr/share/locale/zh_CN/LC_MESSAGES/
cp files/gpa.mo /usr/share/locale/zh_CN/LC_MESSAGES/
#configure gpg
mkdir /etc/skel/.gnugp && cp files/gpg.conf /etc/skel/.gnupg/

#安装备份软件deja-dup
#https://www.tiandixing.org/viewtopic.php?f=83&t=166405&p=927744#p925410
apt-get -y install deja-dup

#禁用火线
#https://www.tiandixing.org/viewtopic.php?f=98&t=136590&p=828103#p828103
cat > /tmp/modprobe.d_blacklist <<EOF
# 禁止自动加载ohci1394模块
blacklist ohci1394
blacklist sbp2
blacklist dv1394
blacklist raw1394
blacklist video1394
blacklist firewire-ohci
blacklist firewire-sbp2
# 禁止手工加载ohci1394模块
install ohci1394 false
# 如果加载了ohci1394模块，强制禁止physical DMA support，好像是有关自动数据传输
options ohci1394 phys_dma=0
EOF
sh -c 'cat /tmp/modprobe.d_blacklist >> /etc/modprobe.d/blacklist-firewire.conf ; update-initramfs -u'

#安装wine
# https://tiandixing.org/viewtopic.php?f=83&t=122076#p711573
apt-get install -y --no-install-recommends wine
#由于没有安装recommends，初次运行自由门的时候会需要用户做两次图形界面的关于没有安装wine-gecko和wine-mono的回答
#用下面的命令后就没有这两次回答了，也放到一键定制脚本里
echo 'export WINEDLLOVERRIDES="mscoree,mshtml="' | tee /etc/profile.d/wine-no-gecko-mono.sh
# https://tiandixing.org/viewtopic.php?f=83&t=122076&p=711573#p711573
mkdir -p /etc/skel/.wine/drive_c/windows/system32/
cp files/wine/mfc42.dll /etc/skel/.wine/drive_c/windows/system32/
# 安装翻墙软件的启动脚本
gdebi --n deb/fanqiang_0.1.0-2tdx2_all.deb

# 安装佳能打印机依赖的libtiff4,ubuntu14.04的源中没有这个包
gdebi --n libtiff4_3.9.5-2ubuntu1.8_${ARCH}.deb

# for automatic security upgrade
###echo 'Acquire::http::proxy "http://127.0.0.1:8580";' | tee -a /etc/apt/apt.conf.d/111proxy
###echo 'Acquire::https::proxy "http://127.0.0.1:8580";' | tee -a /etc/apt/apt.conf.d/111proxy
###we can't do the above here, otherwise any subsequent apt commands would fail.
###let's rely on the security_update.sh alone.
###apt-get -y install unattended-upgrade
cp files/security_update.sh /usr/local/sbin
(crontab -l ; echo "05 09-22/6 * * * /usr/local/sbin/security_update.sh") | crontab -

#和~/.profile配合整点发正念,如果这样做不合适请在定制的时候将files/fzn15.mp3删除
if [ -f files/fzn15.mp3 ]; then
    mkdir -p /opt/mp3
    cp files/fzn15.mp3 /opt/mp3/fzn15.mp3
fi

#安装gimp
apt-get -y install --no-install-recommends gimp gimp-help-common

#用图形界面更改密码
apt-get -y install gnome-system-tools --no-install-recommends

#支持exfat文件系统
apt-get -y install exfat-utils exfat-fuse

# PDF 软件
# https://tiandixing.org/viewtopic.php?f=83&t=122592#p702647
AdobeReaderName=AdobeReader_chs-8.1.7-1.${ARCH}.deb
if [ ! -f ${AdobeReaderName} ]; then
    wget http://ardownload.adobe.com/pub/adobe/reader/unix/8.x/8.1.7/chs/${AdobeReaderName}
fi
if [ ! -f FontPack81_cht_i486-linux.tar.gz ]; then
    wget ftp://ftp.adobe.com/pub/adobe/reader/unix/8.x/8.1.2/misc/FontPack81_cht_i486-linux.tar.gz
fi
dpkg -i ${AdobeReaderName}
tar -xzvf reader_prefs.tar.gz -C /etc/skel
tar -xzvf FontPack81_cht_i486-linux.tar.gz -C /tmp/ && tar -xvf /tmp/CHTKIT/LANGCOM.TAR -C /opt/ && tar -xvf /tmp/CHTKIT/LANGCHT.TAR -C /opt/ && rm -r /tmp/CHTKIT
#rm AdobeReader_chs-8.1.7-1.i386.deb FontPack81_cht_i486-linux.tar.gz

# https://tiandixing.org/viewtopic.php?f=83&t=125949&p=711612#p711612
# viewtopic.php?f=83&t=125949
cat > /usr/share/glib-2.0/schemas/10_gnome.gedit.gschema.override <<EOF
[org.gnome.gedit.preferences.encodings]
auto-detected=['GB18030', 'GB2312', 'GBK', 'UTF-8', 'BIG5', 'CURRENT', 'UTF-16']
shown-in-menu=['UTF-8', 'GB18030', 'GB2312', 'GBK', 'BIG5', 'CURRENT', 'UTF-16']
EOF
glib-compile-schemas /usr/share/glib-2.0/schemas/

#在windows中用记事本创建的默认ANSI格式的字符在Linux中打开会乱码，用以下命令修复
#gsettings set org.gnome.gedit.preferences.encodings auto-detected "['GB18030', 'GB2312', 'GBK', 'UTF-8', 'BIG5', 'CURRENT', 'UTF-16']"
#gsettings set org.gnome.gedit.preferences.encodings shown-in-menu "['UTF-8', 'GB18030', 'GB2312', 'GBK', 'BIG5', 'CURRENT', 'UTF-16']"

#设置gedit不自动产生备份文件
#https://www.tiandixing.org/viewtopic.php?f=83&t=167771#p932684
cat >> /usr/share/glib-2.0/schemas/10_gnome.gedit.gschema.override <<EOF

[org.gnome.gedit.preferences.editor]
auto-save=true
auto-save-interval=5
create-backup-copy=false
EOF
#使设置生效
glib-compile-schemas /usr/share/glib-2.0/schemas/

#设置iptables防火墙
iptables -F
iptables -X
iptables -Z

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
#iptables -t mangle -A OUTPUT -j TTL --ttl-set 128 
#iptables -A INPUT -p tcp --dport 9000 -j ACCEPT

#支持扩展虚拟机host-only全局代理
#https://www.tiandixing.org/viewtopic.php?f=83&t=137818#p779165
iptables -A INPUT -i vboxnet0 -s 192.168.188.0/30 -p tcp -j ACCEPT
#iptables -A INPUT -i vboxnet0 -s 192.168.188.0/30 -p tcp --dport 8580 -j ACCEPT

iptables-save > /etc/iptables.saved
#echo "pre-up iptables-restore < /etc/iptables.saved" >> /etc/network/interfaces
#apt-get -y dist-upgrade
apt-get -y install libreoffice-help-zh-cn hunspell-en-ca sunpinyin-data gimp-help-en kde-l10n-engb libreoffice-l10n-en-gb ibus-sunpinyin fonts-arphic-uming libreoffice-l10n-zh-cn mythes-en-au myspell-en-au ibus-table fonts-arphic-ukai libreoffice-l10n-en-za libsunpinyin3 myspell-en-gb ibus-table-wubi hyphen-en-us libreoffice-help-en-gb mythes-en-us wbritish myspell-en-za openoffice.org-hyphenation

########### NOTHING should be put below this line!!! Otherwise will have wierd connection problems.
# 防直连海外正义网站
# https://tiandixing.org/viewtopic.php?f=83&t=124661
cd $WD_DIR
#cat hosts >> /etc/hosts
cp files/hosts /etc/hosts.append
#因为系统安装时会生成新的/etc/network/interfaces和/etc/hosts，并不会用我们修改
#的文件，放到系统安装之后启动的时候修改这两个文件。
#https://www.tiandixing.org/viewtopic.php?f=83&t=137818#p772107
cp files/rc.local /etc/rc.local

#开机自动判断并创建swap分区
mkdir -p /opt/tdx/
cp files/create_swap.sh /opt/tdx/create_swap.sh

# https://bugs.launchpad.net/ubuntu/+source/systemd/+bug/1325142  #9
echo "libpam-systemd install"|dpkg --set-selections
#!!!! this has to be put in the END!!! Otherwise will have wierd connection problems.

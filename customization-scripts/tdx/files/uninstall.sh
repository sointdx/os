#!/bin/bash -x

# https://tiandixing.org/viewtopic.php?f=83&t=124748
#对对碰mahjongg() 纸牌王 数独 扫雷 游戏数据(gnome-games-data)

#卸载Unity桌面（但不知是否会影响到什么地方）：
#apt-get -y --auto-remove purge unity unity-2d* unity-asset-pool unity-common unity-lens*
###apt-get -y install aptitude "~iunity ?not(~ilibunity9) ?not(~igir1.2-unity)"

apt-get -y purge --auto-remove aisleriot gnome-sudoku gnomine

#https://tiandixing.org/viewtopic.php?f=83&t=124748&view=unread#p709763
#~isamba ~i~Psamba \
apt-get -y install aptitude
aptitude -y purge \
~iubuntuone ~isso-client ~ioneconf ~ipython-zope.interface \
~i~sgames \
~i~Pthunderbird \
~igwibber ~itelepathy ~iempathy ~itransmission ~i~smail \
~ilandscape-client ~iremmina ~ivino \
~iwhoopsie ~iapport ~i~Ppopcon \
~iorca \
~i~drhythmbox "~i~dtotem ?not(~ilibtotem-plparser)" \
~izeitgeist ~iactivity-log-manager \
~ioverlay-scrollbar \
~iunity-lens ~iunity-scope \
~iibus~dinput \
~icompiz \
~ignome-accessibility-themes \
~itango-icon-theme \
~ifriends~dsocial \
~iaccount-plugin \
~ibaobab

#the above ~izeitgeist unintentionally removed gedit.  get it back.
apt-get -y install --no-install-recommends gedit cabextract

#the above may deleted winbind, which is required by wine, which will then issue:
# err:winediag:SECUR32_initNTLMSP ntlm_auth was not found or is outdated. Make sure that ntlm_auth >= 3.0.25 is in your path. Usually, you can find it in the winbind package of your distribution. 
# http://appdb.winehq.org/objectManager.php?sClass=version&iId=19444&iTestingId=63699&bShowAll=true
apt-get -y install winbind

# 关闭不需要的服务
mv /etc/init/avahi-daemon.conf /etc/init/avahi-daemon.conf.disabled
apt-get install -y rcconf dialog
rcconf --off brltty
rcconf --off saned
rcconf --off speech-dispatcher

cd $WD_DIR

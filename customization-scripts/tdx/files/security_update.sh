#!/bin/sh

# 要在tee /etc/apt/apt.conf.d/111proxy中添加类似Acquire::http::proxy "http://127.0.0.1:8580"
# 的内容，语法要求http://127.0.0.1:8580必须用双引号括起来，而需要将$p转换成数字，外层也必须
# 用双引号，不能内层是双引号而外层是单引号（这样$p不会换成数字），因此综合考虑必须用转意字符
sleep `echo "import random; print(random.randrange(0,60*30))" | python -`
for p in 8580 9666 433 8581 ; do
if netstat -tunl | grep $p ; then
   echo "Acquire::http::proxy \"http://127.0.0.1:$p\";" | tee /etc/apt/apt.conf.d/111proxy
   echo "Acquire::https::proxy \"http://127.0.0.1:$p\";" | tee -a /etc/apt/apt.conf.d/111proxy
   apt-get update -oDir::Etc::Sourcelist=/apt/sources.list.d/ubuntu-security.list
   unattended-upgrade 2>&1 | tee /root/update.log
   break
fi
done

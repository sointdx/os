#!/bin/bash

#在livecd中，直接退到上一层bash，不创建swap
if grep -i "overlayfs" /etc/fstab && grep -i "tmpfs" /etc/fstab; then
    exit
fi

mem_size=`free | grep -i mem | awk '{print $2}'`
swap_size=`free | grep -i swap | awk '{print $2}'`

if [ $mem_size -lt 12097152 ] && [ 0 == $swap_size ]; then
    dd if=/dev/zero of=/home/swap bs=1M count=2048
    if [ -e /home/swap ]; then
        mkswap /home/swap
        swapon /home/swap
        new_swap_size=`free | grep -i swap | awk '{print $2}'`
        #每次开机的时候都挂载创建的swap文件
        if [ $new_swap_size > $swap_size ] && ! grep "/home/swap" /etc/fstab; then
            echo "/home/swap     none    swap    sw    0    0" >> /etc/fstab
        fi
    fi
fi

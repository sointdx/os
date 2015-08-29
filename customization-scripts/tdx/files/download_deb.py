#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os,sys
import hashlib

def alread_download(record):
    if os.path.exists(record[1]):
        # record[3] = "MD5Sum:672fc1067496a20ba383dfa6d937af29"
        with open(record[1],'rb') as file_deb:
            if record[3].split(':')[1] == hashlib.md5(file_deb.read()).hexdigest():
                print "%s already download." %record[1]
                return True
    return False

def download_deb():
    if not os.path.exists("/tmp/upgrade_today"):
        for line in open("/tmp/urls"):
            # remove '\n'
            line = line.strip('\n')
            # record = ("url","filename","size","md5")
            record = tuple(line.split(' '))
            while not alread_download(record):
                if os.path.exists(record[1]):
                    print "removing %s..." %record[1]
                    os.remove(record[1])
                try:
                    port = sys.argv[1]
                    os.system("export http_proxy=http://127.0.0.1:%s;export https_proxy=http://127.0.0.1:%s;wget -c %s -O %s" %(port,port,record[0],record[1]))
                except IndexError,e:
                    print 'except:',e
                    return False
        return True
    return False

if download_deb():
    os.system("touch /tmp/upgrade_today")

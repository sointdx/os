#!/bin/bash

MYPROC="/usr/local/sbin/security_update.sh"
/usr/bin/pgrep -f security_update.sh > /dev/null 2>&1 || $MYPROC

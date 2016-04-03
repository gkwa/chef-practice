#!/bin/sh

# http://stackoverflow.com/a/23570150/1495086
# http://askubuntu.com/a/23797
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH

cd /tmp
sh script.sh

sudo -H sh installemacs.sh

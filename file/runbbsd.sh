#!/bin/sh

#
# Run MapleBBS
#
su bbs -c '/home/bbs/bin/camera'
su bbs -c '/home/bbs/bin/account'

#/home/bbs/bin/bbsd
/home/bbs/bin/bbsd 8888
#/home/bbs/bin/bpop3d
/home/bbs/bin/gemd
/home/bbs/bin/bguard
/home/bbs/bin/xchatd

sleep 5
#/home/bbs/bin/bhttpd 
#/home/bbs/innd/innbbsd
##/home/bbs/bin/bnntpd
##/home/bbs/bin/bmtad
##/home/bbs/bin/bhttpd

### Run Websocket ###
websockify -D --log-file /var/log/websocket.log 46783 localhost:8888

############## run cron ################
crontab /tmp/crontab
PIDFILE=/var/run/crond.pid
if [ -f "$PIDFILE" ]; then
    kill -HUP $(cat /var/run/crond.pid)
fi
crond && tail -f /dev/null

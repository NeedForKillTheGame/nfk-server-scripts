#!/bin/bash
CMDFILE=/srv/server/scc.cfg
LOGFILE=/srv/server/realtime.log
UNIXTIME=`date +%s`

# check if server responds
echo "Healthcheck on $UNIXTIME" > $CMDFILE
sleep 5
if ! $(logtail $LOGFILE | grep -q $UNIXTIME); then
    exit 1
fi

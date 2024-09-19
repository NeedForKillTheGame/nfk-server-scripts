#!/bin/bash
CMDFILE="/srv/server/scc.cfg"
LOGFILE="/srv/server/realtime.log"
UNIXTIME=`date +%s`

# check if server responds
echo "Healthcheck on $UNIXTIME" > $CMDFILE
sleep 5
if ! $(logtail $LOGFILE | grep -q $UNIXTIME); then
    echo "Healthcheck failed: server is not responding"
    exit 1
fi

NFKPLANET_INFO=`curl -m 10 -s -w "%{http_code}" https://stats.needforkill.ru/api.php?action=gsl`
NFKPLANET_CODE="${NFKPLANET_INFO: -3}"
NFKPLANET_BODY="${NFKPLANET_INFO:0:-3}"
SERVER_HOSTNAME="${NFK_HOSTNAME:-NFK dedicated server}"

# check if server is registered on nfkplanet
if [ "$NFKPLANET_CODE" -eq 200 ]; then
    if ! [ $(echo "$NFKPLANET_BODY" | jq --arg name "$SERVER_HOSTNAME" 'any(.[]; .hostname == $name)') == "true" ]; then
        echo "Healthcheck failed: could not find server on NFKPlanet"
        exit 1
    fi
fi

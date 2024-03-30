#!/bin/bash
set -eo pipefail

BINARY=$1

replaceConfigParam() {
    cfg=$1
    cvar=$2
    cvarValue="$3"
    if [[ $cvarValue ]]; then
        sed -i "s/^$cvar .*/$cvar $cvarValue/g" /srv/server/$cfg
    fi
}

launchServer() {
    xvfb-run --server-args="-screen 0, 320x240x16" \
        wine $BINARY +gowindow +nosound +nfkplanet +game server +exec server +dontsavecfg &> /srv/server/wine.log
}

replaceConfigParam server.cfg sv_hostname "$NFK_HOSTNAME"
replaceConfigParam server.cfg rconpassword "$RCON_PASSWORD"
replaceConfigParam server.cfg sv_port "$PORT"
replaceConfigParam server.cfg sv_maxplayers "$MAXPLAYERS"
replaceConfigParam server.cfg sv_mapcycle "$MAP_CYCLE_ENABLE"
replaceConfigParam server.cfg sv_maplistfile "$MAPLIST_FILE"
replaceConfigParam autoexec.cfg st_autorecord "$DEMO_AUTORECORD_ENABLE"
replaceConfigParam autoexec.cfg st_senddemos "$DEMO_SEND_ENABLE"
replaceConfigParam autoexec.cfg st_storedemos "$DEMO_STORE_ENABLE"
replaceConfigParam startup.cfg map "$MAP"
launchServer

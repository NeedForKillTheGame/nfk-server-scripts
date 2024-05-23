## NFK dedicated server scripts
Everything necessary for running your own game server in a Docker container.

### System requirements
1. GNU/Linux operating system with [Docker](https://docs.docker.com/engine/install/) installed
2. Single core from Intel/AMD (~2.5 GHz should be enough)
3. 128 MB RAM
4. 512 MB available disk space
5. Internet connection with a public IPv4 address

### Installation 
1. Clone this repository
```bash
git clone https://github.com/NeedForKillTheGame/nfk-server-scripts
cd nfk-server-scripts
```
2. Build the docker image
```bash
docker build . -t local/nfk-dedicated
```

### Usage
#### Synopsis
docker run [ **-p** *port:port/udp* ] [ **-p** *port:port/tcp* ] [ **-e** *option=value* ] local/nfk-dedicated [ **binary** ]

##### Ports
NFK dedicated server uses 29991 UDP port (for gaming) and 28991 TCP port (to provide missing map files for clients) by default.\
UDP port can be changed via options while TCP port will be calculated automatically by subtracting 1000 from it. For instance, if UDP port is set to 29995, TCP port will be 28995 (29995-1000).\
NOTE: used ports should be opened on the server in order to be publicly reachable. Portforwarding is required for servers behind NAT.

##### Options
To simplify server customization it's possible to set some server options via environmant variables.\
The available options are:\
`NFK_HOSTNAME`           — Server's hostname. Double quotes and slashes should be avoided to prevent parsing errors.\
`PORT`                   — Server UDP port binding. (*Default: 29991*).\
`RCON_PASSWORD`          — Sets the password for remote control.\
`MAXPLAYERS`             — Maximum number of players on the server. Available range: 2-8. (*Default: 4*).\
`MAP`                    — Default map and game mode server starts up with. E.g: "ctf1 ctf" or "tourney4 dm". *(Default: tdm1 tdm*).\
`MAP_CYCLE_ENABLE`       — Enables changing the map after the match ends. (*Default: 0*).\
`MAPLIST_FILE`           — Specifies maplist file for **MAP_CYCLE_ENABLE** option. Config file is expected in **basenfk** directory. (*Default: maplist.txt*).\
`DEMO_AUTORECORD_ENABLE` — Enables automatic demo recording. Demos are stored in **basenfk/demos** directory. (*Default: 1*).\
`DEMO_SEND_ENABLE`       — Enables sending demos and match details to [statistics site](https://stats.needforkill.ru). Your server IP address should be manually approved, please contact us by [Discord](https://needforkill.ru/discord). (*Default: 0*).\
`DEMO_STORE_ENABLE`      — Keeps the demo locally, otherwise removes it. Might be useful to turn it off with enabled **DEMO_SEND_ENABLE** option. (*Default: 1*).

##### Binaries
Dedicated server comes with two binaries: `Server.exe` and `Server_MG3.exe`. The only difference is in Machinegun damage: it equals 5 in `Server.exe` and 3 in `Server_MG3.exe`.\
By default, the server starts with `Server_MG3.exe` binary, but it can be overwritten at startup.

#### Runtime examples
##### Basic usage
```bash
docker run -d --restart=always \
 -p 29991:29991/udp \
 -p 28991:28991/tcp \
 -e NFK_HOSTNAME="Example TDM server" \
 -e RCON_PASSWORD="mypass" \
 local/nfk-dedicated
```
This will run NFK dedicated server on ports 29991/udp and 28991/tcp port with default settings (Machinegun damage = 3, sv_maxplayers 4 and so on).

```bash
docker run -d --restart=always \
 -p 29992:29992/udp \
 -p 28992:28992/tcp \
 -e NFK_HOSTNAME="Example CTF server MG5" \
 -e PORT=29992 \
 -e RCON_PASSWORD="mypass" \
 -e MAP="ctf1 ctf" \
 local/nfk-dedicated Server.exe
```
Example for running CTF server on port 29992 with Machinegun damage = 5.

#### Additional information
##### Healthchecks
NFK Dedicated server isn't particularly stable piece of software, so it might eventually hang up. There's built-in healthcheck which will restart the container if something went wrong, so it's better to keep `--restart=always` option in your `docker run` command.
##### Maps
It's possible to keep the maps up to date by syncing it from a separate [maps repository](https://github.com/NeedForKillTheGame/nfk-maps). To do that, first clone the repository:
```bash
cd /opt
git clone https://github.com/NeedForKillTheGame/nfk-maps.git
```
Then add `git pull` to your favorite task scheduler. In case of [crontab](https://man7.org/linux/man-pages/man5/crontab.5.html):
```bash
crontab -e
```
Add:
```bash
* * * * * cd /opt/nfk-maps && git pull > /dev/null 2>&1
```
And save the file.\
Then add [Docker volume flag](https://docs.docker.com/storage/volumes/) to your `docker run` command:
```bash
docker run -d --restart=always \
 -p 29993:29993/udp \
 -p 28993:28993/tcp \
 -e NFK_HOSTNAME="Example Duel server" \
 -e PORT=29993 \
 -e RCON_PASSWORD="mypass" \
 -e MAP="tourney4 dm" \
 -v /opt/nfk-maps:/srv/server/maps:ro \
 local/nfk-dedicated
```
##### CPU limits
Dedicated server will constantly utilize 100% of single core CPU regardless of the real usage (even with a single player connected). On modern CPUs with high single core performance it might be a good idea to [limit CPU usage](https://docs.docker.com/config/containers/resource_constraints/) to run multiple servers on a single core. For example, to limit usage with 50% of single core you can add `--cpus=0.5` to your `docker run` command.

On multi-core CPUs you can also consider pinning the container to a specific core, e.g. adding `--cpuset-cpus=0` will limit the container to the first CPU core. To prevent other tasks from being scheduled on selected cores it's possible to isolate them with [isolcpu= kernel parameter](https://www.kernel.org/doc/Documentation/admin-guide/kernel-parameters.txt).

Remember that these settings require proper testing as it might significantly impact performance of the server.

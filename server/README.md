# AQtion Server Hosting
---
### So you want to host your own server?

Great!  Hosting a server is a great way to contribute to the community and helps your local scene.  This document will help you set one up.

#### Requirements
* A basic understanding of Linux/Docker
    * Traverse the filesystem (cd, ls)
    * Edit files (nano, vi)
    * docker-compose, docker commands in general
* Some flavor of 64-bit Linux
    * Known good/tested:
        * Ubuntu 18.04 Server, Ubuntu 20.04 Server, Ubuntu 22.04 Server
        * Amazon Linux
        * Debian
    * Unknown but probably work fine
        * CentOS/Fedora
* A recent or latest version of Docker and Docker-Compose
* Reasonable bandwidth (10MBit+) and access to the Internet
    * If Internet access is not possible, please contact us in in **#troubleshooting** in our [Discord channel](https://discord.aq2world.com) for ways to distribute files to clients
* Ability to open UDP port 27910 (and more if hosting multiple) to the Internet (TCP on the same port to support remote GTV/MVD)
* Suggested providers:
    * [DigitalOcean](https://www.digitalocean.com) (relatively inexpensive)
    * [AWS](https://aws.amazon.com/) (several dozen locations)
    * [Hetzner](https://www.hetzner.com/cloud)
    * [OVH](https://www.ovhcloud.com/en/public-cloud/compute/)
    * [vultr](https://www.vultr.com/) (inexpensive with many locations)
    * Your favorite VPS
* **Keep in mind that these servers require very few resources; a few dozen megabytes of RAM and very little CPU, and less than 512MB of disk space just for AQtion, even with a _ton_ of maps.**
* **Windows hosts will likely work fine, but are not within the scope of this document.  If someone wants to document a clean method to host via Windows, we welcome that contribution.**
----
### Step by step

Use the following Docker images
* Official (AMD64 and ARM arch): `aqtiongame/server:v50`
* Espionage: `aqtiongame/espionage:v27`

1. If you have docker and docker-compose already, skip to step 3
1. Upon logging into the VPS/instance (ssh, console or otherwise) gaining access to the shell, install `docker` and `docker-compose`
    * Ubuntu: https://docs.docker.com/engine/install/ubuntu/
    * Other: https://docs.docker.com/engine/install/
1. Create a user that will run these containers, for security purposes
    * https://docs.docker.com/engine/install/linux-postinstall/
1. Create a directory to store your configs and go to that directory
    * `mkdir -p /opt/aqtion && cd /opt/aqtion`
1. Download the example files `docker-compose.yaml`, `environment` and `motd` files
    * `for file in docker-compose.yaml tp1.env tp1.motd dm1.env dm1.motd tdm1.env tdm1.motd 3team1.env 3team1.motd; do wget https://raw.githubusercontent.com/actionquake/distrib/main/server/${file}; done`
1. Edit the files downloaded to your liking (make sure you're using the latest images!), changes the team names, skins, hostname, MOTD file.
1. If you want to host more than one server from this docker-compose, duplicate the tp1.env and tp1.motd, for example:
    * `cp tp1.env ctf1.env`
    * `cp tp1.motd ctf1.motd`
    * Include another service in the `docker-compose.yaml` file, changing or incrementing the port (27910, 27911, etc), don't forget the `PORT` env var!
1. Bring your servers online!
    * `docker-compose up -d`
1. Try connecting to your server from your client in the console
    * `connect your.server.ip.address:27910`
1. If your server doesn't come up or you see errors and you don't know what's wrong, come ask for some help in **#troubleshooting** in our [Discord channel](https://discord.aq2world.com)

### Server operations / FAQ

#### Can I use a different port?
* Yes!  Suggested ports begin at 27910 and +1 for every server you plan to host (27911, 27912, etc..)  If you are opening ports on a firewall/ACL, this port is listening on the **UDP** protocol, but we suggest opening both **UDP** and **TCP** as any incoming MVD viewers would observe a match over TCP.

#### How do I get my server listed in the server browser?
* Ensure your server is connectable by testing out a client connection yourself, and that your `MASTER` environment variable is set to default.  Your server should appear in the server browser / master list during its next scan cycle which tends to be about 2-5 minutes.  Naming it to something relatively unique will help it stand out if you are looking for it.

#### Can I use DNS instead of IPs for my server?
* Yes!  But, do not use a CNAME, as this will cause issues with clients connecting.  Use an A record instead.  Also, do not _proxy_ behind services like Cloudflare; the master servers will not be able to list your server in the server browser, and clients will have difficulty connecting to it.

#### Which cloud provider should I use?
* This is up to your regional preference, your budget and how many servers you want to run.  Generally, AWS pings the best and is very easy to setup.  Gravitron servers tend to be half the price of normal x86 servers, so you can host a server for very cheap.

#### How do I get all of the maps?
* Your server will automatically download each map as set in your `ROTATION` env var, or if you set `FULLMAPS=TRUE` as an environment variable, it will download every single map.  This is recommended only if you intend to use all of them as they take up 1GB of space.  Clients will automatically download the maps and assets from the downloadserver, assuming you have not changed this setting from default (or if you know what you are doing, hosting one yourself)

#### How do I change the map rotation?
* Your `ROTATION` env var is a comma-delimited list of maps, ensure there are no spaces in this list, and double-check your spelling.  If you want to add a map, just add it to the list, and it will be downloaded automatically on container restart.  If you want to remove a map, just remove it from the list, and it will be removed from the server on container restart.  If you want to change the order of the maps, just change the order in the list and restart the container.

#### What if I have more questions?
* Visit us in Discord in **#troubleshooting** in our [Discord channel](https://discord.aq2world.com) and we'll be happy to help you out.

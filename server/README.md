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
* Reasonable bandwidth (10MBit+)
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
* Official: `aqtiongame/server:v41`
* Espionage: `aqtiongame/espionage:v27`
* ARM64 / Rasp Pi: `aqtiongame/server:v41`
* ARM32 / Rasp Pi: `aqtiongame/server:v41`

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
1. If your server doesn't come up or you see errors and you don't know what's wrong, come ask for some help in **#configs** in our [Discord channel](https://discord.aq2world.com)

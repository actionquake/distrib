* [![Linux Q2Pro (64-bit)](https://github.com/actionquake/distrib/actions/workflows/Q2Pro-Linux.yaml/badge.svg)](https://github.com/actionquake/distrib/actions/workflows/Q2Pro-Linux.yaml)
* [![Windows Q2Pro (32/64-bit)](https://github.com/actionquake/distrib/actions/workflows/Q2Pro-Windows.yaml/badge.svg)](https://github.com/actionquake/distrib/actions/workflows/Q2Pro-Windows.yaml)
* [![TNG Linux (64-bit)](https://github.com/actionquake/distrib/actions/workflows/TNG-Linux.yaml/badge.svg)](https://github.com/actionquake/distrib/actions/workflows/TNG-Linux.yaml)
* [![TNG Windows (32/64-bit)](https://github.com/actionquake/distrib/actions/workflows/TNG-Windows.yaml/badge.svg)](https://github.com/actionquake/distrib/actions/workflows/TNG-Windows.yaml)

# Action Quake Base Installation

## License considerations
Every effort has been made to ensure that no licensed, copyrighted and/or trademarked content exists in this distribution.  We abide by the license imposed by id software upon the Quake II source code, and its application upon the modification 'Action Quake 2' to redistribute the source along with the application stipulated under **TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION**

https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html

- Quake II source code: https://github.com/skullernet/q2pro (Game Engine)
- Quake II 3.14 Demo: http://tastyspleen.net/quake/downloads/q2-314-demo-x86.exe (Demo Content)
- Action Quake source code: https://github.com/aq2-tng/aq2-tng (Action Quake Libraries)
- The worldwide community of contributors over the decades: (Action Quake Content)

Should it be determined that assets included in this distribution are indeed unlicensed for use, the maintainers of this repository will make expedited and thorough adjustments to this distribution repository to remove said assets and replaced with appropriate content.  Please leave a message as a Github Issue containing links and references to the content, and we will respond as soon as we can.

## Requirements
* A computer built within the last 25 years
* Windows 98, ME, XP, Vista, 7, 8, 10 and probably 11 are all compatible, 32 and 64-bit
* Mac OS (Intel processors)
* 64-bit Linux with a video card and sound card
* Essentially, if you are able to run Quake II, you can run Action Quake.  We do not provide direct support for running Quake II as there are over 20 years of forum posts and articles on how to use it, but if you are running into problems with this specific release, contact us
* If there's a special request for 32-bit Linux, ARM or otherwise, open an Issue!

---

## Instructions/Installation

### RTX compatibility
If you wish to use your RTX card with Quake II
1. Install the RTX package for your platform [NVIDIA/Q2RTX](https://github.com/NVIDIA/Q2RTX/releases)
1. Follow the below instructions

### Existing Quake II installations
1. Download the action-quake-content zip file and extract the `action` directory into the same directory where `baseq2` exists
1. To start Quake II under the `action` mode, use the following startup parameters: `+set game action`
1. ***Note:*** Config files from your `baseq2` directory will still execute, so there may be some unexpected binds or cvars set


### New/Fresh Standalone Install
#### Mac (Intel and M1)
1. Install [Brew](https://brew.sh/) if you do not already have it
1. Install [OpenAL](https://formulae.brew.sh/formula/openal-soft) and [SDL2](https://formulae.brew.sh/formula/sdl2) if you do not already have it
1. Download the .dmg release package for your architecture
1. Drag AQ to the Applications directory
1. Double-click `AQ` to launch

#### Windows
1. Download the latest release zip file
1. Extract to anywhere on your machine you would like it to be permanently installed
1. Open/launch `q2pro.exe`

#### Linux
1. Easy Install:  
    * `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/actionquake/distrib/main/install.sh)"`
1. Your install will be in your home directory named `aqtion`

#### Tarball install
1. Download the latest release tarball file
1. Extract to anywhere on your machine you would like it to be permanently installed
1. Open/launch `q2pro`

#### All platforms
1. Join us in [Discord](https://discord.gg/aq2world) and find some people to play with

---

## Contact
* Github Issues in this repository
* [Discord](https://discord.gg/aq2world) ask for @Mods

## Contribute
1. Clone this repository
1. Checkout a new branch
1. Commit your modifications/additions
1. Submit pull request
* Notes: 
    * 'Official' releases via this distribution done in `pkz` files for game content (maps, etc)

## Site Links
* [AQ2World](https://www.aq2world.com)
* [AQ2Suomi](https://www.aq2suomi.com)
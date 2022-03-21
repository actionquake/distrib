# Steam Base Installation

## License considerations
Every effort has been made to ensure that no licensed, copyrighted and/or trademarked content exists in this distribution.  We abide by the license imposed by id software upon the Quake II source code, and its application upon the modification 'Action Quake 2' to redistribute the source along with the application stipulated under **TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION**

https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html

- Quake II source code: https://github.com/skullernet/q2pro
- Action Quake source code: https://github.com/aq2-tng/aq2-tng

Should it be discovered that assets included in this distribution are indeed unlicensed for use, the maintainers of this repository will make expedited and thorough adjustments to the distribution to remove said assets and replaced with appropriate content.  Please leave a message as a Github Issue containing links and refernces to the content, and we will respond as soon as we can.

## Requirements
* Latest q2pro built specifically for `action` for 64-bit Mac, 32- and 64-bit Windows, 32- and 64-bit Linux
* Latest gamex86.dll/.so/.dylib from aq2-tng (bot branch to include LTK) (and 32-bit equivalents for Windows and Linux)
* aq2config.cfg - Contains reasonable defaults for new players
* Several maps, but let's identify ones that do not have copyrighted or trademarked materials such as Coca*Cola signs (
    * Optionally, replace copyrighted/trademarked textures with 'safe' ones
    * One accepted/approved LTK file per included map, so that new players can fight against bots if they wish, and so that the bots aren't without any pathing
* Helper script that activates/deactivates content (Python?)
    * Essentially moves files around or renames directories (high def vs. original textures for instance)
* 'Official' releases via Steam installation done in `pkz` files for game content


## Directory structure
```
Action Quake/
    q2pro executable (Mac, Win, Lin)
    action/
        gamex86_64.dll (Windows 64-bit)
        gamei386.dll (Windows 32-bit)
        gamex86_64.so (Linux and Mac 64-bit)
        gamei386.so (Linux 32-bit)
        aq2config.cfg
        action.ini
        terrain/
            <one .ltk file per map included in this release>
        players/
            terror/
                <all terror skins, sounds and content>
            sas/
                <all terror skins, sounds and content>
        sound/
            click.wav
            female/
            male/
```

## Identified items that may need replaced
Any assets that came from Quake II
* sounds
    * hurt
    * falling damage
* textures
    * anything from eXuX needs replaced
* players
    * male model?
    * female model?
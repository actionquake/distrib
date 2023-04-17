AQtion v1.3 Release Notes
---
A big callout to all of the AQ2World Team for this massive update!  We couldn't have done it without you!

Distribution / Asset changes
- Main game asset changes:
  - All assets from Quake II Retail and Demo have been removed or replaced.  In most cases, the files that existed in this distribution weren't even needed, like enemy AI models.  Those that AQtion needed were replaced with high quality replacements.  
      - Assets affected are game .wal textures, a good deal of sound effects, models, and player skins.  If you own a retail copy of Quake II ([which we highly recommend picking up if you haven't played it!](https://store.steampowered.com/app/2320/Quake_II/)), you can copy the pak files over from `baseq2` into `action` to restore the original sounds, skins and textures.  For more details, see below under Game changes.
  - Rearranged where files live, structurally. This consolidates files better for general management.  Main game files are now located in `baseaq`, while downloads and custom paks/pkz file should still go into `action`
    - Consolidated all content into a single pkz file (`pak0.pkz`), configs moved to `pak1.pkz` in `baseaq`
  - Mac game libs are now a `.dylib` extension
  - Removed all Quake II retail player skins
  - Replaced several hundred old .wal textures
  - Replaced idle sound effects
  - Replaced elevator/platform sounds
  - Replaced 10-1 countdown announcer
  - Replaced footstep sound effects
    - Larger variety of footstep and hard landing sounds are now available with the toggle `cl_enhanced_footsteps`
  - Replaced damage sound effects (fall, hit, death sounds)
  - Replaced grenade bounce sound and explosion effects
  - Replaced smoke model and skin (bullets hitting wall effect)
  - Replaced medkit (did you know Action Quake used a medkit, if enabled?)
  - Replaced dozens of ambient map sounds
  - Added a bunch of new player skins
  - New gib and on-ground item models (big thanks to the Reaction 3 team!)

AQ2-TNG Game changes

- Added adjustable weapon sounds (via llsound) and menu options.  This is only enabled if the server has `llsound 1`.
  - [See this document snippet for config details](https://github.com/actionquake/aq2-tng/blob/aqtion/TNG-manual.txt#L189-L199)
- Added `irvision` to menu as bindable
- Added default binds for bot management (rebind-able)
  - F6 removes all bots
  - F7 adds 1 bot
  - F8 removes 1 bot
- Fixed bug where `gl_brightness` made darkmatch too bright.  Now forces `gl_brightness` to `0` if server has darkmatch enabled.
- Fixed a bug with `scr_scale` where the sniper scope would be off-center
- Teammate Indicators:
  - Enabled with `use_indicators` on the server, and `cl_indicators` on the client (1 for spec, 2 for teammates), arrows are drawn above players, but their head must be visible for the arrows to appear
- Gamestate Extrapolation:
    - Toggled with `use_xerp` on the server, and `cl_xerp` on the client (1 for auto xerp based on ping/antilag, 2 for FRAMETIME/2 xerp)
    - xerp will be automatically disabled if `sv_antilag_interp` is enabled.  
    - xerp will automatically add ping time to value if `sv_antilag` is disabled
    - this is a purely visual effect, hitboxes are unchanged, though depending on the amount of extrapolation, this may look strange
- IR Vision (server side):
  - Toggled with `new_irvision` on the server; teammates no longer highlight, only enemies
- CvarSync:
  - the game dll can now specify cvars the client should send to the server, this replaces the old and buggy setu system that abused userinfo
- Spectator Overlay:
  - using protocol 38 and an updated client allows for a new spechud using the Ghud system
  - also fixed `cl_spectatorhud` not working properly
- Sniper zoom compensation (server-side):
  - Reduced delay frames for higher ping players.  Remains 6 frames (600ms) for all players under 80ms ping.  Above 80ms and per every 80ms beyond, reduce delay frames by 1, up to a maximum of 3 reduced frames.  This can be enabled on the server via `zoom_comp`
- Attract mode (server-side):
  - Automatically maintains a minimum count of LTK bots at all times.  Reduces 1 LTK bot per real human player.  Meant to be used to get games started by having people join servers and having something to shoot at.  See the TNG Manual for more details.

Q2Pro Engine changes
- MAX_ENTITIES from 256 -> 1024
- MAX_FILE_HANDLES from 32 -> 1024
- Downloading `.pkz` files larger than 2GiB are supported now
- Loading `.pkz` files over 4GiB and ZIP64 archives are supported now
- `sv_max_packet_entities` default value is 128 (default Quake II client max) but can be set to 0 (unlimited), this mostly affects maps with large open areas
- .ogg support with commands (`ogg info|play|stop`)
- `remotemode` turns client into rcon-only mode, all commands issued by this client are considered forwarded as rcon
- Exec'ing config files after game dir change, autoexec.cfg is executed after default.cfg and config.cfg/q2config.cfg
- MVD seeking allows to percentage rather than just timespec (50% is halfway through, for example)
- Forces minimum version of Windows to 7
- Console buffer search, now you can search your command history
- Stereo sound supported
- Client-side gun view and offset settings (`cl_gun_fov`, `cl_gun_x`, `cl_gun_y`, `cl_gun_z`)
- `con_auto_chat` adjusts how to handle mistyped commands
  - `0` handle as regular command
  - `1` sends typed entry as chat
  - `2` sends type entry as team chat
- Fixed a crash when server names were too long
- Crouch prediction with `sv_fps` correction, it works great now
- Protocol 38 had the following changes:
  - Made ghud per client instead of global, and raised the elementlimit to 200
  - Added CvarSync to poll cvar values from the client as the gamedll needs
- Adjusted colorations in the Server Browser
  - Shows servers with antilag enabled, servers populated with bots, and so forth
- Support for Linux X11 and Wayland
  - Choose which one to use in Steam
- Enhancements to the server UI
  - Wider column to view mapname
  - Enabled colors based on ping, if the server has bots in it, and so forth

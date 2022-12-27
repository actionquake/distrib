## R1Q2/Q2Pro HTTP Downloads Guide

### Simple method

Upload all files you want to offer via HTTP downloading to your webspace.
e.g. If you want to share a custom maps, make sure you first make a mod dir and subdir maps. Upload all your custom maps to the maps directory.

set sv_downloadserver "http://yourWebSpace.com/"

### Filelists ( from R1q2 ChangeLog )

The HTTP client will also by default fetch a "filelist" for each mod and map you download. The first download you start will request the mod filelist and downloading a .bsp file will request the appropriate map filelist. The filelist should contain plain text path references to extra files that the Q2 client would not normally auto download - eg for a map you may wish to include the paths of PNG textures, for a mod you would reference every file your mod needs in order to run. This allows a client who has never played on your server before to download the entire mod via HTTP downloading and not miss any files as often happens with plain auto-downloading. 

The map filelists are read from 
- http://server/gamename/maps/mapname.filelist 
and the mod filelist from 
- http://server/gamename/gamename.filelist
and consists of newline-separated relative paths from the gamedir of files you wish the client to download - eg for maps/hells_corner.bsp you would create a **hells_corner.filelist** with any references to files the map needs, eg:
- textures/mymap/texture1.wal
- textures/mymap/texture1.png
- sound/mymap/door01.wav
and host it at http://server/gamename/maps/hells_corner.filelist. 

Filelists may only reference "safe" Quake II game content, other files such as .zip and other unknown extensions will be ignored. You may prefix a line with @ to make the check game-local - ie say your mod uses custom conchars.pcx and you specify pics/conchars.pcx in your filelist, it won't be downloaded as Q2 will see it already exists from the baseq2 pak files.

By specifying @pics/conchars.pcx, it will be checked only from pak files and disk files in the mod dir. If you have a lot of content that replaces the same names as used in baseq2 pak files, it is recommended you use pak file as detailed below.

Filelists may reference .pak files provided they will only be downloaded to the mod directory - ie the list entry should read "pak0.pak".

The file subsystem will reload when a .pak is downloaded to ensure correct ordering of files; any files in the HTTP queue which are also in a newly downloaded pak will be removed from the queue. 

Additionally, .paks will be downloaded as soon as they are queued and will block everything else until they are done. 

The @ prefix is redundant with pak files and will cause an error if used. Note that any files that were queued with the @ prefix with the same names as baseq2 files will be removed once a pak has finished downloading when the queue is revalidated. 

Thus, it isn't a good idea to mix both pak files and @-prefixed files. You may wish to use FileListFinder to generate a filelist-compatible list of specified files under a root directory (useful for map/mod authors).

###
This file should not be needed in the downloadserver in general
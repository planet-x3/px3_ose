Uncompressed assets
===================

All the uncompressed game artwork goes in this directory.

You can use `get_assets.sh` to bootstrap from an ordinary digital download of Planet X3.

Fonts and LUTs
--------------

The source code package comes with pixel fonts for various video modes and map flipping LUTs.
It is presumed that these are not covered by copyright and can be used freely.

Map list
--------

The file `maplist.bin` contains the map list for the game's intro menu, and some meta data.
It is a fixed-format 512-byte ASCII file that can be edited in a hex editor or text editor.
Note: Due to the fixed-format nature, you should switch the editor to "overwrite" mode.

Consider the map file numbers from 0 to 19 reserved for official maps.

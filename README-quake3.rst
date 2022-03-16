Setting up quake3
=================

Install *ioquake3* on Linux (also includes *ioquake3-server*)::

    apt-get install ioquake3

Install ``quake3-demo-data`` from somewhere, which contains::

    /usr/share/games/quake3-demo-data/demoq3/botfiles/fw_items.c
    /usr/share/games/quake3-demo-data/demoq3/botfiles/fw_weap.c
    /usr/share/games/quake3-demo-data/demoq3/botfiles/game.h
    /usr/share/games/quake3-demo-data/demoq3/botfiles/ichat.h
    /usr/share/games/quake3-demo-data/demoq3/botfiles/inv.h
    /usr/share/games/quake3-demo-data/demoq3/botfiles/items.c
    /usr/share/games/quake3-demo-data/demoq3/botfiles/match.c
    /usr/share/games/quake3-demo-data/demoq3/botfiles/match.h
    /usr/share/games/quake3-demo-data/demoq3/botfiles/script.c
    /usr/share/games/quake3-demo-data/demoq3/botfiles/teamplay.h
    /usr/share/games/quake3-demo-data/demoq3/botfiles/weapons.c
    /usr/share/games/quake3-demo-data/demoq3/gfx/misc/lightning3new.jpg
    /usr/share/games/quake3-demo-data/demoq3/gfx/misc/lightning3newnpm.jpg
    /usr/share/games/quake3-demo-data/demoq3/pak0.pk3
    /usr/share/games/quake3-demo-data/demoq3/scripts/lightningnew.shader
    /usr/share/games/quake3-demo-data/demoq3/vm/cgame.qvm
    /usr/share/games/quake3-demo-data/demoq3/vm/qagame.qvm
    /usr/share/games/quake3-demo-data/demoq3/vm/ui.qvm

Or, better yet, install ``quake3-data``, containing::

    /usr/share/games/quake3/baseq3/cgamex86_64.so
    /usr/share/games/quake3/baseq3/pak0.pk3
    /usr/share/games/quake3/baseq3/pak1.pk3
    /usr/share/games/quake3/baseq3/pak2.pk3
    /usr/share/games/quake3/baseq3/pak3.pk3
    /usr/share/games/quake3/baseq3/pak4.pk3
    /usr/share/games/quake3/baseq3/pak5.pk3
    /usr/share/games/quake3/baseq3/pak6.pk3
    /usr/share/games/quake3/baseq3/pak7.pk3
    /usr/share/games/quake3/baseq3/pak8.pk3
    /usr/share/games/quake3/baseq3/qagamex86_64.so
    /usr/share/games/quake3/baseq3/uix86_64.so
    /usr/share/games/quake3/missionpack/cgamex86_64.so
    /usr/share/games/quake3/missionpack/qagamex86_64.so
    /usr/share/games/quake3/missionpack/uix86_64.so

Create batch files for ``quake3-demo``::

    #!/bin/sh
    if [ -n "$1" -a "${1#+}" = "$1" ]; then
        echo "usage: $0 [+params...]" >&2
        exit 1
    fi
    exec /usr/lib/ioquake3/ioquake3 \
      +set vm_cgame 0 +set vm_game 0 +set vm_ui 0 \
      +set fs_basepath /usr/share/games/quake3-demo-data \
      +set com_homepath .q3ademo +set com_basegame demoq3 \
      +set sv_pure 0 \
      "$@"

Or, for ``quake3``::

    #!/bin/sh
    if [ -n "$1" -a "${1#+}" = "$1" ]; then
        echo "usage: $0 [+params...]" >&2
        exit 1
    fi
    exec /usr/lib/ioquake3/ioquake3 \
      +set vm_cgame 0 +set vm_game 0 +set vm_ui 0 \
      +set fs_basepath /usr/share/games/quake3 \
      +set com_homepath .q3a +set com_basegame baseq3 \
      "$@"


Using q3.make
-------------

If you've placed ``q3.make`` in your path, you can do::

    q3.make mymap.pk3

And it will do all necessary steps to build the map and zip it up for you.

If you have your own textures etc. (not in ``pak?.pk3``), you'll need to
include those too::

    q3.make mymap.pk3 INCLUDE='env/mymap textures/mymap scripts/mymap.shader'

Paths will be autodetected by reading file in ``~/.radiant``.

**BEWARE:** If you include ``mymap.shader`` in multiple maps, and leave
the same PK3 files accessible, you won't know which version you're
getting. Delete old PK3 files to be on the safe side.


Configuring quake3
------------------

Setting video settings through the console (``~``)::

    /r_mode -1
    /r_customheight 1080
    /r_customwidth 1920
    /vid_restart

If things are too dark (``~``)::

    /r_overbrightbits "0"
    /r_ignorehwgamma "1"
    /vid_restart

Skipping CD KEY prompt::

    echo $(for x in $(seq 16); do echo -n 2; done) >~/.q3a/baseq3/q3key


Running quake3
--------------

When you have a BSP file (and optionally an AAS)::

    quake3 +sv_pure 0 +devmap q3dm7sample

**NOTE:** You need ``+sv_pure`` _before_ the ``+devmap``.

When you've compiled the BSP and AAS into a PK3::

    quake3 +map q3dm7sample

Adding bots to the game::

    quake3 +map q3dm7sample +addbot grunt +addbot anarki


Debugging quake3
----------------

When you're running a ``+devmap``::

    /set r_showtris 1

See also: https://wiki.splashdamage.com/index.php/Console_commands


TODO
----

* Try to build packages for the pak files from the files found on the
  internet (1.32c)?

* Document where to best install the maps directory (the initial Game
  setup path: ``~/Documents/q3maps`` vs ``~/.q3a``). Also document how
  we can setup symlinks for easier coop work.

* Do something with these docs:
  https://www.tcmapping.com/q3map2-vis-hint/#how_to_see_the_result for HINT
  https://victorkarp.com/de/quake-3-mapping-tutorials/
  https://www.cs.rochester.edu/~brown/242/docs/RadiantTut.html
  https://github.com/id-Software/Quake-III-Arena/blob/dbe4ddb10315479fc00086f08e25d968b4b43c49/q3map/shaders.c#L64-L112

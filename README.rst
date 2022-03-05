wdoekes build of (TTimo) GtkRadiant for Ubuntu/Debian
=====================================================

Using Docker::

    ./Dockerfile.build

If the build succeeds, the built Debian packages are placed inside (a
subdirectory of) ``Dockerfile.out/``.

The files may look similar to these::

    -     15,101  gtkradiant_1.6.6-0wjd0+ubu20.04_amd64.buildinfo
    -      2,763  gtkradiant_1.6.6-0wjd0+ubu20.04_amd64.changes
    -  2,454,016  gtkradiant_1.6.6-0wjd0+ubu20.04_amd64.deb
    -      7,848  gtkradiant_1.6.6-0wjd0+ubu20.04.debian.tar.xz
    -      1,249  gtkradiant_1.6.6-0wjd0+ubu20.04.dsc
    - 48,235,829  gtkradiant_1.6.6.orig.tar.gz
    -    178,860  gtkradiant-dbgsym_1.6.6-0wjd0+ubu20.04_amd64.ddeb
    -  2,017,400  gtkradiant-game-q3pack_1.6.6-0wjd0+ubu20.04_all.deb

The ``gtkradiant*.orig.tar.gz`` contains source files from multiple
repositories. With ``SOURCE_VERSION`` files in the directories,
recording the exact versions.

The ``gtkradiant*.deb`` holds files in::

    - /usr/bin (radiant.bin, q3map2, ...)
    - /usr/lib/x86_64-linux-gnu/gtkradiant (plugins/modules)
    - /usr/share/doc/gtkradiant (docs)
    - /usr/share/gtkradiant (arch independent data files, images)

The ``gtkradiant-game-q3pack*.deb`` holds files in::

    - /usr/share/gtkradiant/installs/Q3Pack/game


Running GtkRadiant
------------------

Starting should be a matter of running ``radiant.bin``::

    $ dpkg -L gtkradiant | grep /usr/bin/
    /usr/bin/bspc
    /usr/bin/q3data
    /usr/bin/q3map2
    /usr/bin/q3map2_urt
    /usr/bin/radiant.bin

Game configuration will be stored in ``~/.radiant/1.6.6+20220124.97d3d879``::

    $ find ~/.radiant/1.6.6+20220124.97d3d879/ -type f | sort
    ~/.radiant/1.6.6+20220124.97d3d879/games/q3.game
    ~/.radiant/1.6.6+20220124.97d3d879/global.pref
    ~/.radiant/1.6.6+20220124.97d3d879/prtview.ini
    ~/.radiant/1.6.6+20220124.97d3d879/q3.game/local.pref
    ~/.radiant/1.6.6+20220124.97d3d879/radiant.log

You may need to copy these configuration files when switching versions.


Other
-----

See `README-quake3.rst`_ for Quake3 specific setup.


TODO
----

* Document where to best install the maps directory (the initial Game
  setup path: ``Documents/radiant-quake3`` vs ``~/.q3a``).
* Decide how to name the orig.tar.gz file. And consider doing a reproducible tar.gz
  (like: --numeric-owner --owner=0 --group=0 --mtime='1970-01-01 00:00:00' --no-recursion --null --files-from - )
* Rename ``radiant.bin`` to ``radiant``? or ``gtkradiant``?
* Document q3-make-bsp stuff.
* Add other gamepacks as DEB files.
* Remove XXX/FIXMEs here.
* Try to get some patches merged back into TTimo repo.
* Check dbgsym files. And enable -g debug symbols in scons build?
* https://www.tcmapping.com/q3map2-vis-hint/#how_to_see_the_result for HINT
* https://victorkarp.com/de/quake-3-mapping-tutorials/
* https://www.cs.rochester.edu/~brown/242/docs/RadiantTut.html
* Shader flags from the horse's mouth:
  https://github.com/id-Software/Quake-III-Arena/blob/dbe4ddb10315479fc00086f08e25d968b4b43c49/q3map/shaders.c#L64-L112

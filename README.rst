wdoekes build of (TTimo) GtkRadiant for Ubuntu/Debian
=====================================================

Radiant is the open source cross platform level editor for idTech games
like Quake III Arena.

There are at least three competing versions out there:

- ☑ `GtkRadiant build <https://github.com/wdoekes/gtkradiant-deb>`_ 1.6
  (a continuation of *GtkRadiant 1.4*, maintained by *TTimo*);
- ☐ `NetRadiant build <https://github.com/wdoekes/netradiant-deb>`_ 1.5
  a continuation of the *GtkRadiant 1.5*, maintained by *Xonotic*);
- ☐ `NetRadiant-custom build <https://github.com/wdoekes/nrcradiant-deb>`_
  1.5 (an early fork of *NetRadiant*, maintained by *Garux*).

(There are more versions, including `DarkRadiant
<https://salsa.debian.org/games-team/darkradiant>`_ which actually ships
in the *Ubuntu* universe.)

This repository contains build tools to build Debian/Ubuntu packages for
`GtkRadiant <https://github.com/TTimo/GtkRadiant>`_ along with the
*q3map2* compiler and *bspc* bot file builder.

In the `releases section <../../releases>`_, you might find some
precompiled debian packages... if you're lucky. But if there aren't any,
building for your specific Debian derivative should be a breeze.


Building NetRadiant for your distro
-----------------------------------

Using Docker::

    ./Dockerfile.build [ubuntu/focal]

If the build succeeds, the built Debian packages are placed inside (a
subdirectory of) ``Dockerfile.out/``.

The files may look similar to these::

    -     15,234  gtkradiant_1.6.6+20220124+2-0wjd1+ubu20.04_amd64.buildinfo
    -      3,044  gtkradiant_1.6.6+20220124+2-0wjd1+ubu20.04_amd64.changes
    -  2,463,052  gtkradiant_1.6.6+20220124+2-0wjd1+ubu20.04_amd64.deb
    -     17,900  gtkradiant_1.6.6+20220124+2-0wjd1+ubu20.04.debian.tar.xz
    -      1,298  gtkradiant_1.6.6+20220124+2-0wjd1+ubu20.04.dsc
    - 47,677,388  gtkradiant_1.6.6+20220124+2.orig.tar.gz
    - 12,048,528  gtkradiant-dbgsym_1.6.6+20220124+2-0wjd1+ubu20.04_amd64.ddeb
    -  2,018,416  gtkradiant-game-quake3_1.6.6+20220124+2-0wjd1+ubu20.04_all.deb

The ``gtkradiant*.orig.tar.gz`` contains source files from multiple
repositories. With ``SOURCE_VERSION`` files in the directories,
recording the exact versions.

The ``gtkradiant*.deb`` holds files in::

    - /usr/bin (gtkradiant, q3map2, ...)
    - /usr/lib/x86_64-linux-gnu/gtkradiant (plugins/modules)
    - /usr/share/doc/gtkradiant (docs)
    - /usr/share/gtkradiant (arch independent data files, images)
    - /usr/share/locale (translations)

The ``gtkradiant-game-quake3*.deb`` holds files in::

    - /usr/share/gtkradiant/installs/Q3Pack/game


Running GtkRadiant
------------------

Starting should be a matter of running ``gtkradiant``::

    $ dpkg -L gtkradiant | grep /usr/bin/
    /usr/bin/bspc
    /usr/bin/gtkradiant
    /usr/bin/q3data
    /usr/bin/q3map2
    /usr/bin/q3map2_urt

Game configuration will be stored in ``~/.radiant/1.6.6+20220124+2``::

    $ find ~/.radiant/1.6.6+20220124+2/ -type f | sort
    ~/.radiant/1.6.6+20220124+2/games/q3.game
    ~/.radiant/1.6.6+20220124+2/global.pref
    ~/.radiant/1.6.6+20220124+2/prtview.ini
    ~/.radiant/1.6.6+20220124+2/q3.game/local.pref
    ~/.radiant/1.6.6+20220124+2/radiant.log

You may need to copy these configuration files when switching versions.


Other
-----

See `<README-quake3.rst>`_ for Quake3 specific setup.


BUGS/TODO
---------

* See if we want to get some patches merged back into the TTimo repo at
  https://github.com/TTimo/GtkRadiant

* Add other gamepacks as DEB files. Alter/update/fix README-quake3.rst.

* Maybe fix (re)generating ``radiant.pot`` automatically, and check what
  kind of warnings ``msgfmt`` is throwing when creating ``po/de.po``.

* The ``"entitypath"`` in ``default_project.proj`` points to a non-existent
  path, but it is not used either. ``entities.def`` is loaded in
  ``radiant/eclass.cpp``::

    // read in all scripts/*.<extension>
    pFiles = vfsGetFileList( "scripts", pTable->m_pfnGetExtension() );

  The Q3Path ``default_project.proj`` points to::

    <key name="entitypath" value="$TEMPLATEtoolspath$TEMPLATEbasedir/scripts/entities.def"/>

  That would become::

     /usr/share/gtkradiant/installs/Q3Pack/install/baseq3/scripts/entities.def

  That file does not exist in that location, but *randiant.bin* has no
  issue finding ``entities.def`` in the correct location. It does so by scanning::

    <enginepath_linux>/<basegame>/scripts/*.def

  I suspect "entitypath" could be removed altogether as it only appears
  to be referenced in ``tools/quake2/extra/qe4/qe3.c``.

* Order of paths checked (not a bug, but a listing)::

    (look for config)
    ~/.radiant/1.6.6+20220124+2/games (config)

    (look for modules)
    /usr/lib/x86_64-linux-gnu/gtkradiant/modules/ (needed)
    /usr/lib/x86_64-linux-gnu/gtkradiant/plugins/ (empty)
    /usr/share/gtkradiant/installs/Q3Pack/game/modules/ (optional)
    /usr/share/gtkradiant/installs/Q3Pack/game/plugins/ (optional)

    (look for pk3s)
    /usr/share/gtkradiant/base
    ~/.q3a/baseq3
    ~/Documents/q3maps/baseq3

    (look for scripts/scripts/textures)
    /usr/share/gtkradiant/base/{scripts,sprites,textures}
    ~/.q3a/baseq3/{scripts,sprites,textures}
    ~/Documents/q3maps/baseq3/{scripts,sprites,textures}

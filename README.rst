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
    - 11,234,780  gtkradiant-dbgsym_1.6.6-0wjd0+ubu20.04_amd64.ddeb
    -  2,017,400  gtkradiant-game-q3pack_1.6.6-0wjd0+ubu20.04_all.deb

The ``gtkradiant*.orig.tar.gz`` contains source files from multiple
repositories. With ``SOURCE_VERSION`` files in the directories,
recording the exact versions.

The ``gtkradiant*.deb`` holds files in::

    - /usr/bin (radiant.bin, q3map2, ...)
    - /usr/lib/x86_64-linux-gnu/gtkradiant (plugins/modules)
    - /usr/share/doc/gtkradiant (docs)
    - /usr/share/gtkradiant (arch independent data files, images)
    - /usr/share/locale (translations)

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

See `<README-quake3.rst>`_ for Quake3 specific setup.


BUGS
----

* These errors when clicking caulkify::

    BobToolz::ERROR->Failed To Load Exclusion List: /usr/lib/x86_64-linux-gnu/gtkradiant/modules/bt/bt-el1.txt
    BobToolz::ERROR->Failed To Load Exclusion List: /usr/lib/x86_64-linux-gnu/gtkradiant/modules/bt/bt-el2.txt

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


FUTURE WORK
-----------

* See if we want to get some patches merged back into the TTimo repo at
  https://github.com/TTimo/GtkRadiant

* Add other gamepacks as DEB files. Alter/update/fix README-quake3.rst.

* The German language file in ``po/de.po`` appears to work, assuming you
  have generated the German locale (``locale-gen de_DE.UTF-8``) and
  running with ``LC_ALL=de_DE.UTF-8 radiant.bin``. However, ``msgfmt``
  throws some warnings, and (worse) the application starts with odd
  looking color schemes. (If we're working on this, we may want to see
  if we can regenerate ``radiant.pot`` automatically too.)

* Decide if we want to rename the binary from ``radiant.bin`` to
  ``radiant`` or ``gtkradiant``.

* Order of paths checked (not a bug, but a listing)::

    (look for config)
    ~/.radiant/1.6.6+20220124.97d3d879/games (config)

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

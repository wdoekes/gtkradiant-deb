ARG osdistro=ubuntu
ARG oscodename=focal

FROM $osdistro:$oscodename
LABEL maintainer="Walter Doekes <wjdoekes+gtkradiant@osso.nl>"
LABEL dockerfile-vcs=https://github.com/wdoekes/gtkradiant-deb

ARG DEBIAN_FRONTEND=noninteractive

# This time no "keeping the build small". We only use this container for
# building/testing and not for running, so we can keep files like apt
# cache. We do this before copying anything and before getting lots of
# ARGs from the user. That keeps this bit cached.
RUN echo 'APT::Install-Recommends "0";' >/etc/apt/apt.conf.d/01norecommends
RUN apt-get update -q
RUN apt-get install -y apt-utils
RUN apt-get dist-upgrade -y
RUN apt-get install -y \
    bzip2 ca-certificates curl git \
    build-essential dh-autoreconf devscripts dpkg-dev equivs quilt

# Set up build env
RUN printf "%s\n" \
    QUILT_PATCHES=debian/patches \
    QUILT_NO_DIFF_INDEX=1 \
    QUILT_NO_DIFF_TIMESTAMPS=1 \
    'QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"' \
    'QUILT_DIFF_OPTS="--show-c-function"' \
    >~/.quiltrc

# Apt-get prerequisites according to control file.
COPY control /build/debian/control
RUN mk-build-deps --install --remove --tool "apt-get -y" /build/debian/control

# ubuntu, ubu, focal, gtkradiant, 1.6.6, '', 0wjd0
ARG osdistro
ARG osdistshort
ARG oscodename
ARG upname
ARG upversion
ARG debepoch=
ARG debversion

#ARG upsrc_md5=610301fca946d515251c30a4e26bd6a0

# Copy debian dir, check version
RUN mkdir -p /build/debian
COPY ./changelog /build/debian/changelog
RUN . /etc/os-release && fullversion="${upversion}-${debversion}+${osdistshort}${VERSION_ID}" && \
    expected="${upname} (${debepoch}${fullversion}) ${oscodename}; urgency=medium" && \
    head -n1 /build/debian/changelog && \
    if test "$(head -n1 /build/debian/changelog)" != "${expected}"; \
    then echo "${expected}  <-- mismatch" >&2; false; fi

# Set up upstream source, move debian dir and jump into dir.
# We want the current GtkRadiant build, but we do not need everything in the .git folder.
COPY ./GtkRadiant/ /build/GtkRadiant
WORKDIR /build/GtkRadiant
# Check that the version is still $upversion+X.
# (Note that RADIANT_MAJOR_VERSION and RADIANT_MINOR_VERSION in version.h
# refer to MINOR and MICRO version respectively, while MAJOR is 1.)
RUN if ! test -f include/version.h; then \
        grep -xF "${upversion%%+*}" include/version.default; \
    else \
        # BUG: in 1.6.6 version.h is committed and include/version.default
        # and include/version.default is NOT updated.
        grep -xF '#define RADIANT_VERSION "'${upversion%%+*}'"' include/version.h; \
    fi
# Update version sources to include our version
RUN echo 'Custom build by wdoekes' > include/aboutmsg.default
RUN echo "$upversion" > include/version.default
RUN python2 makeversion.py 

# Skip updating GIT/SVN repo's *again*, because we do so in
# Dockerfile.build already.
RUN if test -f config.py; then \
        sed -i -e "s/cmd = [[] \('git', 'pull'\|'svn', 'update'\)/cmd = [ 'echo', 'skipping:', \1/" config.py; \
    fi

# Fix (TTimo) bspc path, clean it, make SOURCE_VERSION, check for checksum patch:
RUN cd tools/bspc && \
    git clean -dfx && \
    find . -name '.git' | \
      xargs --no-run-if-empty -IX env DIR='X' sh -c 'DIR=${DIR%/.git} && git -C "$DIR" show >"$DIR/SOURCE_VERSION"' && \
    git branch --contains 8aa16e1986a1ac93f5992e144552eccab27035c1 | grep -xF '* master'

# Make clean, reproducible tar, with 1970 timestamps, sorted, etc..
RUN git clean -dxf \
      --exclude=debian/ \
      --exclude=install/installs/ \
      --exclude=tools/bspc/ && \
    # Add versions to files found in ./install/installs.
    find . -type d -name '.git' | \
      xargs -IX env DIR='X' sh -c 'DIR=${DIR%/.git} && git -C "$DIR" show >"$DIR/SOURCE_VERSION"' && \
    find . -type d -name '.svn' | \
      xargs -IX env DIR='X' sh -c 'DIR=${DIR%/.svn} && svn info "$DIR" >"$DIR/SOURCE_VERSION"' && \
    # (reproducible tar, with 1970 timestamps, sorted, etc..)
    cd .. && \
    find GtkRadiant '!' '(' \
      -type d -o -name .gitignore -o -name .gitmodules -o -path '*/.git/*' -o -path '*/.svn/*' \
      -o -name '*.srctrl*' -o -name '*.rej' -o -name '*.orig' -o -name '*.o' -o -name '*.pyc' ')' \
      -print0 | LC_ALL=C sort -z | tar -cf ${upname}_${upversion}.orig.tar \
      --numeric-owner --owner=0 --group=0 --mtime='1970-01-01 00:00:00' \
      --no-recursion --null --files-from - && \
    gzip --no-name ${upname}_${upversion}.orig.tar

# Make new debian dir and add everything this time.
RUN mkdir debian
COPY changelog compat control rules gtkradiant* debian/
COPY patches debian/patches
COPY source debian/source

# Build (no source pkg, so -b and manual quilt push)
#RUN quilt push -a
RUN DEB_BUILD_OPTIONS=parallel=6 dpkg-buildpackage -us -uc

# TODO: for bonus points, we could run quick tests here;
# for starters dpkg -i tests?

# Write output files (store build args in ENV first).
ENV oscodename=$oscodename osdistshort=$osdistshort \
    upname=$upname upversion=$upversion debversion=$debversion
RUN . /etc/os-release && fullversion=${upversion}-${debversion}+${osdistshort}${VERSION_ID} && \
    mkdir -p /dist/${upname}_${fullversion} && \
    mv /build/${upname}_${upversion}.orig.tar.gz /dist/${upname}_${fullversion}/ && \
    mv /build/*${fullversion}* /dist/${upname}_${fullversion}/ && \
    cd / && find dist/${upname}_${fullversion} -type f >&2

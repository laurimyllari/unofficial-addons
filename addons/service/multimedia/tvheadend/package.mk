################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
#
#  OpenELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  OpenELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="tvheadend"
PKG_VERSION="4.1.361"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/laurimyllari/tvheadend/tree/master-atsc-epg"
PKG_URL="https://github.com/laurimyllari/tvheadend/archive/master-atsc-epg.zip"
PKG_DEPENDS_TARGET="toolchain libressl curl"
PKG_PRIORITY="optional"
PKG_SECTION="service/multimedia"
PKG_SHORTDESC="tvheadend (Version: $PKG_VERSION): a TV streaming server for Linux supporting DVB-S, DVB-S2, DVB-C, DVB-T, ATSC, IPTV, and Analog video (V4L) as input sources."
PKG_LONGDESC="Tvheadend (Version: $PKG_VERSION) is a TV streaming server for Linux supporting DVB-S, DVB-S2, DVB-C, DVB-T, ATSC, IPTV, and Analog video (V4L) as input sources. It also comes with a powerful and easy to use web interface both used for configuration and day-to-day operations, such as searching the EPG and scheduling recordings. Even so, the most notable feature of Tvheadend is how easy it is to set up: Install it, navigate to the web user interface, drill into the TV adapters tab, select your current location and Tvheadend will start scanning channels and present them to you in just a few minutes. If installing as an Addon a reboot is needed"
PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="xbmc.service"
PKG_ADDON_PROVIDES=""
PKG_AUTORECONF="no"
PKG_ADDON_REPOVERSION="6.0"

if [ "$TARGET_ARCH" == "arm" ] ; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libdvbcsa"
fi

unpack() {
  unzip $SOURCES/$PKG_NAME/master-atsc-epg.zip -d $BUILD/$PKG_NAME
  mv $BUILD/$PKG_NAME/$PKG_NAME-master-atsc-epg $BUILD/$PKG_NAME-$PKG_VERSION
}

pre_build_target() {
  mkdir -p $PKG_BUILD/.$TARGET_NAME
  cp -RP $PKG_BUILD/* $PKG_BUILD/.$TARGET_NAME
  export CROSS_COMPILE=$TARGET_PREFIX
  if [ "$TARGET_ARCH" == "arm" ] ; then
    DVBCSA="--enable-dvbcsa"
  else
    # TODO force dvbcsa on all projects
    DVBCSA="--disable-dvbcsa"
  fi
}

configure_target() {
  ./configure --prefix=/usr \
            --arch=$TARGET_ARCH \
            --cpu=$TARGET_CPU \
            --cc=$TARGET_CC \
            --enable-hdhomerun_client \
            --enable-hdhomerun_static \
            --disable-avahi \
            --disable-libav \
            --enable-inotify \
            --enable-epoll \
            --disable-uriparser \
            --enable-tvhcsa \
            --enable-bundle \
            $DVBCSA \
            --disable-dbus_1 \
            --python=$ROOT/$TOOLCHAIN/bin/python
}

post_make_target() {
  $CC -O -fbuiltin -fomit-frame-pointer -fPIC -shared -o capmt_ca.so src/extra/capmt_ca.c -ldl
}

makeinstall_target() {
  : # nothing to do here
}

addon() {
  mkdir -p $ADDON_BUILD/$PKG_ADDON_ID/bin
  cp -P $PKG_BUILD/.$TARGET_NAME/build.linux/tvheadend $ADDON_BUILD/$PKG_ADDON_ID/bin
  cp -P $PKG_BUILD/.$TARGET_NAME/capmt_ca.so $ADDON_BUILD/$PKG_ADDON_ID/bin
}

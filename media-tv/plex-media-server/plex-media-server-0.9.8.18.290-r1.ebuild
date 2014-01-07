# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit unpacker user

DESCRIPTION="PLEX media server"
HOMEPAGE="https://plex.tv/"

MY_PN="plexmediaserver"
MY_REV="11b7fdd"

SRC_URI=" x86? ( http://downloads.plexapp.com/${PN}/${PV}-${MY_REV}/${MY_PN}_${PV}-${MY_REV}_i386.deb
				https://dl.dropboxusercontent.com/u/9454972/distfiles/${MY_PN}_${PV}-${MY_REV}_i386.deb )
		amd64? ( http://downloads.plexapp.com/${PN}/${PV}-${MY_REV}/${MY_PN}_${PV}-${MY_REV}_amd64.deb
				https://dl.dropboxusercontent.com/u/9454972/distfiles/${MY_PN}_${PV}-${MY_REV}_amd64.deb )"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="net-dns/avahi"

QA_PRESTRIPPED="usr/lib/plexmediaserver/libavcodec.so.54
usr/lib/plexmediaserver/Plex.Media.Server
usr/lib/plexmediaserver/libavutil.so.52
usr/lib/plexmediaserver/libavformat.so.54
usr/lib/plexmediaserver/Plex.DLNA.Server
usr/lib/plexmediaserver/libfreeimage.so.3
usr/lib/plexmediaserver/libswscale.so.2
usr/lib/plexmediaserver/Resources/Plex.New.Transcoder
usr/lib/plexmediaserver/Resources/Plex.Transcoder
usr/lib/plexmediaserver/Plex.Media.Scanner"

QA_TEXTRELS="usr/lib/plexmediaserver/libavcodec.so.54
usr/lib/plexmediaserver/libavutil.so.52
usr/lib/plexmediaserver/libavformat.so.54
usr/lib/plexmediaserver/libswscale.so.2"

S="${WORKDIR}"

src_prepare(){
	#ubuntu's trash
	rm -rf etc/apt
	rm etc/init.d/plexmediaserver
	#fdo
	sed 's|Audio;Music;Video;Player;Media;|AudioVideo;Player;|;s|x-www-browser|xdg-open|' \
		-i usr/share/applications/plexmediamanager.desktop
}

src_install(){
	cp -R {usr,etc} "${D}"
	#port for openrc
	doinitd "${FILESDIR}/pms"
}

pkg_preinst() {
	enewgroup plex
	enewuser plex -1 -1 -1 plex
}

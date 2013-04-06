# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/sonata/sonata-1.6.2.1.ebuild,v 1.9 2011/10/29 09:45:35 angelos Exp $

EAPI="3"
PYTHON_DEPEND="2:2.6"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.[45] 3.* *-jython"

inherit distutils bzr

DESCRIPTION="an elegant GTK+ music client for the Music Player Daemon (MPD)."
HOMEPAGE="http://sonata.berlios.de/"
SRC_URI="http://codingteam.net/project/${PN}/download/file/${P}.tar.bz2"
EBZR_REPO_URI="lp:~l3on/sonata/sonata-plugins"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="dbus lyrics taglib +trayicon +libnotify"

RDEPEND=">=dev-python/pygtk-2.12
	|| ( x11-libs/gdk-pixbuf:2[jpeg] x11-libs/gtk+:2[jpeg] )
	>=dev-python/python-mpd-0.2.1
	dbus? ( dev-python/dbus-python )
	lyrics? ( dev-python/zsi )
	taglib? ( >=dev-python/tagpy-0.93 )
	trayicon? ( dev-python/egg-python )
	libnotify? ( dev-python/notify-python )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS="CHANGELOG README TODO TRANSLATORS"

src_prepare(){
	unpack ${A}
	if use libnotify;then
	  bzr_src_prepare
	  mv notify.py ${PN}-${PV}/sonata/plugins/
	fi
}
src_compile(){
	cd ${PN}-${PV}
	distutils_src_compile
}
src_install() {
	cd ${PN}-${PV}
	distutils_src_install
	rm -rf "${D}"/usr/share/sonata
}

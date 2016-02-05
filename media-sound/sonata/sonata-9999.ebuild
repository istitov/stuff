# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
PYTHON_COMPAT=( python{3_2,3_3} )

inherit distutils-r1 python-r1 git-r3

DESCRIPTION="an elegant GTK 3 client for the Music Player Daemon"
HOMEPAGE="https://github.com/multani/sonata"
EGIT_REPO_URI="git://github.com/multani/sonata.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="dbus mpd taglib"

LANGS="da it ko sk tr nl ca sl be zh_CN ru et sv pt_BR cs el_GR de fi ar pl uk ja es zh_TW fr"
for X in ${LANGS} ; do
	IUSE+=" linguas_${X}"
done
RDEPEND=">=dev-python/python-mpd-0.4.6
	>=dev-python/pygobject-3.4.2
	>=x11-libs/gtk+-3.4
	mpd? ( >=media-sound/mpd-0.15 )
	dbus? ( dev-python/dbus-python )
	taglib? ( >=dev-python/tagpy-2013.1 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS="CHANGELOG README.rst TODO TRANSLATORS"

src_prepare() {
	local lang
	for lang in ${LANGS}; do
		if ! use linguas_${lang}; then
			rm po/${lang}.po || die "failed to remove nls"
		fi
	done
}

src_install() {
	distutils-r1_src_install
	rm -rf "${D}"/usr/share/sonata
}

pkg_postinst() {
	elog ""
	elog "In order to work correctly Sonata,"
	elog "you will need PyGObject 3.7.4 or more,"
	elog "earlier versions may also work... but it's not recommended"
}

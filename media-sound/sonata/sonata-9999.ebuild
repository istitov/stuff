# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
PYTHON_COMPAT=( python3_{6,7,8,9} )

inherit distutils-r1 python-r1 git-r3

DESCRIPTION="an elegant GTK 3 client for the Music Player Daemon"
HOMEPAGE="https://github.com/multani/sonata"
EGIT_REPO_URI="https://github.com/multani/sonata.git"
#EGIT_REPO_URI="git://github.com/multani/sonata.git"
#EGIT_BRANCH="fix/57-withdrawn"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dbus mpd taglib"

LANGS="ar be ca cs da de el es et fi fr it ja ko nl pl pt-BR ru sk sl sv tr uk zh-CN zh-TW"
#el-GR replaced by el
for X in ${LANGS} ; do
	IUSE+=" l10n_${X}"
done
RDEPEND=">=dev-python/python-mpd-0.4.6
	>=dev-python/pygobject-3.4.2
	>=x11-libs/gtk+-3.4
	mpd? ( >=media-sound/mpd-0.15 )
	dbus? ( dev-python/dbus-python )
	taglib? ( >=dev-python/tagpy-0.93 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS="CHANGELOG README.rst TODO TRANSLATORS"

src_prepare() {
	local lang
		for lang in ${LANGS}; do
			if ! use l10n_${lang}; then
				rm po/${lang/-/_}.po || die "failed to remove nls"
			fi
		done
}

src_install() {
	distutils-r1_src_install
	rm -rf "${D}"/usr/share/sonata
	insinto /usr/share/pixmaps
	newins sonata/pixmaps/sonata-large.png sonata.png
}

pkg_postinst() {
	elog ""
	elog "In order to work correctly Sonata,"
	elog "you will need PyGObject 3.7.4 or more,"
	elog "earlier versions may also work... but it's not recommended"
}

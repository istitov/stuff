# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
inherit desktop distutils-r1 xdg git-r3

DESCRIPTION="Elegant GTK+ 3 client for the Music Player Daemon (MPD)"
HOMEPAGE="https://www.nongnu.org/sonata/"
EGIT_REPO_URI="https://github.com/multani/sonata.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="dbus mpd taglib"

LANGS="ar be ca cs da de el-GR es et fi fr hi it ja ko nl pl pt-BR ru sk sl sv tr uk zh-CN zh-TW"
for X in ${LANGS} ; do
	IUSE+=" l10n_${X}"
done

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		dev-python/python-mpd2[${PYTHON_USEDEP}]
		dbus? ( dev-python/dbus-python[${PYTHON_USEDEP}] )
		taglib? ( dev-python/tagpy[${PYTHON_USEDEP}] )
	')
"

DEPEND="${RDEPEND}
	mpd? ( media-sound/mpd )
	x11-libs/gtk+:3"

BDEPEND="virtual/pkgconfig"

DOCS="CHANGELOG README.rst TODO TRANSLATORS"

PATCHES=(
	"${FILESDIR}/hot_fix_version_PEP.patch"
)

distutils_enable_tests unittest

src_prepare() {
	local lang
		for lang in ${LANGS}; do
			if ! use l10n_${lang}; then
				rm po/${lang/-/_}.po || die "failed to remove nls"
			fi
		done
	default
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

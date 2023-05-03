# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
inherit desktop distutils-r1 xdg

DESCRIPTION="Elegant GTK+ 3 client for the Music Player Daemon (MPD)"
HOMEPAGE="https://www.nongnu.org/sonata/"
SRC_URI="https://github.com/multani/sonata/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE="dbus mpd taglib"


LANGS="ar be ca cs da de el-GR es et fi fr it ja ko nl pl pt-BR ru sk sl sv tr uk zh-CN zh-TW"
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

distutils_enable_tests unittest

DOCS="CHANGELOG README.rst TODO TRANSLATORS"

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
	doicon -s 128 sonata/pixmaps/sonata.png
	rm -r "${ED}"/usr/share/sonata || die
}


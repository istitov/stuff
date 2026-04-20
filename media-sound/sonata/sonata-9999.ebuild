# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..14} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
inherit desktop distutils-r1 git-r3 xdg

DESCRIPTION="Elegant GTK+ 3 client for the Music Player Daemon (MPD)"
HOMEPAGE="https://www.nongnu.org/sonata/"
EGIT_REPO_URI="https://github.com/multani/sonata.git"

LICENSE="GPL-3"
SLOT="0"
IUSE="dbus mpd taglib"

LANGS_MAP=(
	ar:ar be:be ca:ca cs:cs da:da de:de el_GR:el es:es et:et fi:fi
	fr:fr hi:hi it:it ja:ja ko:ko nl:nl pl:pl pt_BR:pt-BR ru:ru sk:sk
	sl:sl sv:sv tr:tr uk:uk zh_CN:zh-CN zh_TW:zh-TW
)
for X in "${LANGS_MAP[@]}" ; do
	IUSE+=" l10n_${X#*:}"
done
unset X

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		dev-python/python-mpd2[${PYTHON_USEDEP}]
		dbus? ( dev-python/dbus-python[${PYTHON_USEDEP}] )
		taglib? ( dev-python/tagpy[${PYTHON_USEDEP}] )
	')
"
DEPEND="
	${RDEPEND}
	mpd? ( media-sound/mpd )
	x11-libs/gtk+:3
"
BDEPEND="virtual/pkgconfig"

distutils_enable_tests unittest

DOCS="CHANGELOG README.rst TODO TRANSLATORS"

src_prepare() {
	default

	# Upstream's version.py calls `git describe --abbrev=4`, which on
	# any non-tag commit returns something like `1.7.0-22-gabcd` — not
	# a PEP 440 version, so setuptools refuses to build a wheel. Force
	# the script down the default-version path and pin it to a PEP 440
	# compliant string.
	sed -i \
		-e 's|^default_version = .*|default_version = "v0.0.0.dev0"|' \
		-e '/^ *version = Popen(/,/\.decode(.utf-8.)$/c\            raise OSError' \
		sonata/version.py || die

	local entry file flag
	for entry in "${LANGS_MAP[@]}" ; do
		file="${entry%%:*}"
		flag="${entry#*:}"
		use "l10n_${flag}" || rm "po/${file}.po" || die
	done
}

src_install() {
	distutils-r1_src_install
	doicon -s 128 sonata/pixmaps/sonata.png
	rm -r "${ED}"/usr/share/sonata || die
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit autotools git-r3 python-single-r1

DESCRIPTION="An implementation of the MPRIS 2 interface as a client for MPD"
HOMEPAGE="https://github.com/eonpatapon/mpDris2"
EGIT_REPO_URI="https://github.com/eonpatapon/mpDris2.git"

LICENSE="GPL-3"
SLOT="0"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		>=dev-python/dbus-python-0.80[${PYTHON_USEDEP}]
		>=dev-python/pygobject-2.14:3[${PYTHON_USEDEP}]
		>=dev-python/python-mpd2-3.0.5[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/intltool
	sys-devel/gettext
"

DOCS=( AUTHORS NEWS README.md )

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default
	eautoreconf
}

pkg_postinst() {
	elog "Translations can be selected via the LINGUAS environment variable."
	elog "See https://wiki.gentoo.org/wiki/Localization/Guide"
}

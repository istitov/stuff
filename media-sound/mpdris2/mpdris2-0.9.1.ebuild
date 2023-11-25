# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9,10,11} )

inherit python-r1 autotools

DESCRIPTION="An implementation of the MPRIS 2 interface as a client for MPD"
HOMEPAGE="https://github.com/eonpatapon/mpDris2"
SRC_URI="https://github.com/eonpatapon/mpDris2/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 x86"
S="${WORKDIR}/mpDris2-${PV}"

DEPEND="
	>=dev-python/dbus-python-0.80[${PYTHON_USEDEP}]
	>=dev-python/pygobject-2.14[${PYTHON_USEDEP}]
	>=dev-python/python-mpd2-3.0.5[${PYTHON_USEDEP}]
"

DOCS="AUTHORS COPYING INSTALL NEWS README README.md"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	emake install DESTDIR="${D}" || die "Failed to install"
}

pkg_postinst() {
	elog ""
	elog "At the moment there are several translations besides english(fr nl)."
	elog "For activate them during installation,"
	elog "you need to add them to the LINGUAS variable."
	elog "See the documentation for more details"
	elog "https://wiki.gentoo.org/wiki/Localization/Guide/en#LINGUAS"
}
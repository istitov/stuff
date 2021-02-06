# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils

DESCRIPTION="DeaDBeeF filebrowser plugin "
HOMEPAGE="https://sourceforge.net/projects/deadbeef-fb/"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV}_src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk2 gtk3"

DEPEND_COMMON="
	gtk2? ( media-sound/deadbeef[gtk2] )
	gtk3? ( media-sound/deadbeef[gtk3] )"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

S="${WORKDIR}/deadbeef-devel"

src_configure() {
	econf --disable-static \
		$(use_enable gtk3) \
		$(use_enable gtk2)
}

src_install() {
	emake DESTDIR="${D}" install
	find "${D}" -name "${PN}-${PV}" -exec rm -rf {} +
}

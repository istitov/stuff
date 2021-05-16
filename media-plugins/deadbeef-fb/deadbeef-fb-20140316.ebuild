# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils

DESCRIPTION="DeaDBeeF filebrowser plugin "
HOMEPAGE="https://sourceforge.net/projects/deadbeef-fb/"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV}_src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
#~amd64 ~x86
IUSE=""

DEPEND_COMMON="
	media-sound/deadbeef
"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

S="${WORKDIR}/deadbeef-devel"

src_configure() {
	sed -i "s/errno/errorNum/g" utils.c
	sed -i "s/gtk_css_provider_get_default/gtk_css_provider_new/g" utils.c
	econf --disable-static \
		--enable-gtk3
		--disable-gtk2
}

src_install() {
	emake DESTDIR="${D}" install
	find "${D}" -name "${PN}-${PV}" -exec rm -rf {} +
}

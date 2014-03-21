# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/vsfm/vsfm-0.5.23.ebuild,v 0.1 2013/11/19 10:24:12 brothermechanic Exp $

EAPI=5

inherit eutils

DESCRIPTION="A Visual Structure from Motion System"
HOMEPAGE="http://ccwu.me/vsfm/"
SRC_URI="http://ccwu.me/vsfm/download/VisualSFM_linux_64bit.zip"

LICENSE="VisualSFM"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	media-libs/devil
	media-libs/atlas-c++
	sci-libs/cminpack
	virtual/fortran
	sci-libs/parmetis
	"
RDEPEND="${DEPEND}"

PDEPEND="
	media-libs/graclus
	media-libs/pba
	media-gfx/cmvs
	media-gfx/siftgpu"

S="${WORKDIR}/vsfm"

src_install() {
	dobin "${S}"/bin/VisualSFM
	mkdir -p "${D}"/usr/bin/log
	chmod 777 "${D}"/usr/bin/log
	newicon "${FILESDIR}"/"${PN}".png "${PN}".png
	make_desktop_entry VisualSFM Graphics
}

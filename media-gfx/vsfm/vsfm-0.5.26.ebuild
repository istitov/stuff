# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="A Visual Structure from Motion System"
HOMEPAGE="http://ccwu.me/vsfm/"
SRC_URI="http://ccwu.me/vsfm/download/VisualSFM_linux_64bit.zip -> ${P}.zip"

LICENSE="VisualSFM"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	media-libs/atlas-c++
	sci-libs/cminpack
	virtual/fortran
	sci-libs/parmetis
	"
RDEPEND="${DEPEND}"

PDEPEND="
	media-libs/graclus
	media-libs/pba
	media-gfx/pmvs
	media-gfx/siftgpu
	media-gfx/PoissonRecon"

S="${WORKDIR}/vsfm"

src_install() {
	dobin "${S}"/bin/VisualSFM
	mkdir -p "${D}"/usr/bin/log
	chmod 777 "${D}"/usr/bin/log
	newicon "${FILESDIR}"/"${PN}".png "${PN}".png
	make_desktop_entry VisualSFM Graphics
}

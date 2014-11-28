# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/PoissonRecon/PoissonRecon-6-13.ebuild,v 0.1 2014/11/20 17:40:12 brothermechanic Exp $

EAPI=5

inherit eutils

DESCRIPTION="Screened Poisson Surface Reconstruction"
HOMEPAGE="http://www.cs.jhu.edu/~misha/Code/PoissonRecon"
SRC_URI="http://www.cs.jhu.edu/~misha/Code/PoissonRecon/Version6.13/PoissonRecon.zip"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	sci-libs/clapack
	dev-libs/libf2c
	dev-libs/boost
	sci-libs/gsl
	virtual/blas
	virtual/jpeg"
RDEPEND="${DEPEND}"

S="${WORKDIR}/PoissonRecon"

src_install() {
	dobin "${S}"/Bin/Linux/{PoissonRecon,SurfaceTrimmer}
}

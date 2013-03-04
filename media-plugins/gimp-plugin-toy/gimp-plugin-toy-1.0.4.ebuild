# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="This gimp plug-in creates a toy effect"
HOMEPAGE="http://registry.gimp.org/node/25803"
SRC_URI="http://registry.gimp.org/files/${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="media-gfx/gimp"
RDEPEND="${DEPEND}
	virtual/pkgconfig"




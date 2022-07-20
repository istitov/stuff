# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="neat and simple webcam grabbing app"
HOMEPAGE="http://www.sanslogic.co.uk/fswebcam/"
SRC_URI="http://www.sanslogic.co.uk/fswebcam/files/${PN}-${PV}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86 "
IUSE=""

DEPEND="media-libs/gd[truetype,png,jpeg]"
RDEPEND="${DEPEND}"

# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="neat and simple webcam grabbing app"
HOMEPAGE="http://www.sanslogic.co.uk/fswebcam/
https://github.com/fsphil/fswebcam/"
SRC_URI="https://github.com/fsphil/${PN}/archive/refs/tags/${PV}.tar.gz  -> ${P}.gh.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86 "

DEPEND="media-libs/gd[truetype,png,jpeg]"
RDEPEND="${DEPEND}"

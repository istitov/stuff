# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Neat and simple webcam grabbing app"
HOMEPAGE="https://www.sanslogic.co.uk/fswebcam/
	https://codeberg.org/fsphil/fswebcam"
# The repository moved to Codeberg; GitHub keeps serving this tag's archive,
# which the Manifest pins.
SRC_URI="https://github.com/fsphil/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

DEPEND="media-libs/gd[truetype,png,jpeg]"
RDEPEND="${DEPEND}"

PATCHES=(
	# Upstream 90a2922a (2023): the V4L1 source closed itself on a failed
	# buffer allocation, then its caller closed it again.
	"${FILESDIR}"/${P}-v4l1-double-free.patch
)

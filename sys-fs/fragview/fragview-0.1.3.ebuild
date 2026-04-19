# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Disk fragmentation visualizer based on FIEMAP and FIBMAP ioctls"
HOMEPAGE="https://github.com/i-rinat/fragview"
SRC_URI="https://github.com/i-rinat/${PN}/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-cpp/glibmm:2
	dev-cpp/gtkmm:3.0
	dev-db/sqlite:3
	dev-libs/boost
"
RDEPEND="${DEPEND}"

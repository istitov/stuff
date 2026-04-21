# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="JACK output plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/tokiclover/deadbeef-plugins-jack"
SRC_URI="https://github.com/tokiclover/deadbeef-plugins-jack/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/deadbeef-plugins-jack-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	media-sound/deadbeef
	virtual/jack
"
RDEPEND="${DEPEND}"

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe *.so
}

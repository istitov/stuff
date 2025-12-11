# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=7

DESCRIPTION="Simple keyboard layout indicator"
HOMEPAGE="https://github.com/polachok/skb"
EGIT_COMMIT="3ab2012a73b66010be9ba0b16b0dfe7f03950937"
SRC_URI="https://github.com/polachok/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${EGIT_COMMIT}"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
RESTRICT="mirror"

DEPEND_COMMON=""
RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"

src_install() {
	insinto /usr/bin/
	dobin skb || die
}

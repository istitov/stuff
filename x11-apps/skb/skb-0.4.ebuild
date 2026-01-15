# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=7

DESCRIPTION="Simple keyboard layout indicator"
HOMEPAGE="https://github.com/polachok/skb"
EGIT_COMMIT="1497a78b34faf1967e6dfaf2662fc3a75b342a3e"
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

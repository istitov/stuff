# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Simple keyboard layout indicator"
HOMEPAGE="https://github.com/polachok/skb"
EGIT_COMMIT="1497a78b34faf1967e6dfaf2662fc3a75b342a3e"
SRC_URI="https://github.com/polachok/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	# Drop the strip invocations from Makefile so Portage's debug
	# machinery stays in control.
	sed -i '/@strip/d' Makefile || die
}

src_compile() {
	emake CC="$(tc-getCC)" LD="$(tc-getCC)" \
		CFLAGS="${CFLAGS} -I. -DVERSION=\"\\\"${PV}\\\"\"" \
		LDFLAGS="${LDFLAGS} -lX11"
}

src_install() {
	dobin skb
	dodoc README
}

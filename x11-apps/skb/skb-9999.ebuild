# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="Simple keyboard layout indicator"
HOMEPAGE="https://github.com/polachok/skb"
EGIT_REPO_URI="https://github.com/polachok/${PN}.git"

LICENSE="GPL-2"
SLOT="0"

RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	# Drop the strip invocations from Makefile so Portage's debug
	# machinery stays in control.
	sed -i '/@strip/d' Makefile || die

	# xkb.c uses eprint() without a declaration; GCC 14+ defaults to
	# -std=c23 where implicit function declarations are errors.
	sed -i '1i extern void eprint(const char *errstr, ...);' xkb.c || die
}

src_compile() {
	emake CC="$(tc-getCC)" LD="$(tc-getCC)" \
		CFLAGS="${CFLAGS} -I. -DVERSION=\"\\\"${PV}\\\"\"" \
		LDFLAGS="${LDFLAGS} -lX11"
}

src_install() {
	dobin skb xskb
	dodoc README
}

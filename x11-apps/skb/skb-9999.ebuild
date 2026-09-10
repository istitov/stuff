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

PATCHES=( "${FILESDIR}/${PN}-9999-format-security.patch" )

src_prepare() {
	default
	# Let Portage control stripping.
	sed -i '/@strip/d' Makefile || die

	# GCC 14+ rejects xkb.c's implicit eprint declaration under C23.
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

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit git-r3

DESCRIPTION="Simple keyboard layout indicator"
HOMEPAGE="https://github.com/polachok/skb"
EGIT_REPO_URI="https://github.com/polachok/${PN}.git"

LICENSE="GPL-2"

SLOT="0"
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

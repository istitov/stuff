# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Command line interface to manage hierarchical todos"
HOMEPAGE="http://code.meskio.net/tudu
	https://github.com/meskio/tudu/"
SRC_URI="https://github.com/meskio/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="sys-libs/ncurses:="
RDEPEND="${DEPEND}"

src_compile()
{
	emake DESTDIR="/usr" ETC_DIR="/etc" || die " emake failed"
}

src_install()
{
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS README ChangeLog CONTRIBUTORS || die
}

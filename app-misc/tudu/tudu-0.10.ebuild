# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit flag-o-matic

DESCRIPTION="Command line interface to manage hierarchical todos"
HOMEPAGE="http://code.meskio.net/tudu"
SRC_URI="http://code.meskio.net/tudu/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-libs/ncurses:=[unicode]"
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

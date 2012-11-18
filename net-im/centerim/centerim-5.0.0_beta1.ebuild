# Distributed under the terms of the GNU General Public License v2

EAPI=4
inherit eutils

DESCRIPTION="CenterIM is a ncurses ICQ/Yahoo!/AIM/IRC/MSN/Jabber/GaduGadu/RSS/LiveJournal Client"
HOMEPAGE="http://www.centerim.org"
MY_PV=${PV/_*}
SRC_URI="http://www.centerim.org/download/cim5/centerim5-5.0.0beta1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="net-im/pidgin
>=sys-libs/ncurses-5.2
"
RDEPEND="${DEPEND}"
S="${WORKDIR}/centerim5-5.0.0beta1"

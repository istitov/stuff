# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit games qt4-r2

DESCRIPTION="Dwarf (The)rapist for Dwarf Fortress."
HOMEPAGE="https://github.com/splintermind/Dwarf-Therapist/"

if [[ ${PV} == 9999* ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/splintermind/Dwarf-Therapist.git"
else
	SRC_URI="https://github.com/splintermind/Dwarf-Therapist/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="doc"
S="${WORKDIR}/Dwarf-Therapist-${PV}"

DEPEND="
dev-qt/qtcore:4
"
RDEPEND="${DEPEND}"

src_configure() {
	qmake PREFIX="./2"
}
src_install() {
	emake install || die "Install failed"
	dodoc README.rst
	dodoc CHANGELOG.txt
	dodoc BUILDING.rst
	dodoc LICENSE.txt
}

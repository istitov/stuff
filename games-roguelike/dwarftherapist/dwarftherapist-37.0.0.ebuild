# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit qt4-r2

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
IUSE="-qt4 qt5 -doc"
S="${WORKDIR}/Dwarf-Therapist-${PV}"

DEPEND="
qt4? ( dev-qt/qtcore:4 )
qt5? ( dev-qt/qtcore:5 )
"
RDEPEND="${DEPEND}"

pkg_setup() {
	if use qt4 && use qt5 ; then
		ewarn "You can not have USE='qt4 qt5'. Assuming qt5 is more important."
	fi
}
src_configure() {
	if use qt5; then
	qmake -qt=5 \"PREFIX="${D}"\"
	else
	qmake -qt=4 \"PREFIX="${D}"\"
	fi
}
src_install() {
	emake install || die "Install failed"
	dodoc README.rst
	dodoc CHANGELOG.txt
	dodoc BUILDING.rst
	dodoc LICENSE.txt
}

# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="Dwarf (The)rapist for Dwarf Fortress."
HOMEPAGE="https://github.com/Dwarf-Therapist/Dwarf-Therapist"

if [[ ${PV} == 9999* ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Dwarf-Therapist/Dwarf-Therapist.git"
else
	SRC_URI="https://github.com/Dwarf-Therapist/Dwarf-Therapist/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
USE="-doc"
IUSE="doc"

S="${WORKDIR}/Dwarf-Therapist-${PV}"

DEPEND="dev-qt/qtcore:5
	dev-qt/qtdeclarative:5"

RDEPEND="${DEPEND}"

#pkg_setup() {}
src_prepare() {
	cmake_src_prepare
}

src_configure() {
#	emake \"PREFIX="${D}"\"
	cmake_src_configure
}

src_install() {
	cmake_src_install || die "Install failed"
	dodoc README.rst
	dodoc CHANGELOG.txt
	dodoc LICENSE.txt
}

pkg_postinst() {
	xdg_icon_cache_update
}

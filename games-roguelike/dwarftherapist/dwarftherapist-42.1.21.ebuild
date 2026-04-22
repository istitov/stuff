# Copyright 1999-2026 Gentoo Authors
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

S="${WORKDIR}/Dwarf-Therapist-${PV}"
LICENSE="MIT"
SLOT="0"

DEPEND="
	dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
"

RDEPEND="${DEPEND}"

pkg_postinst() {
	xdg_icon_cache_update
}

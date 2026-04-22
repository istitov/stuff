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
IUSE="qt5 +qt6"
REQUIRED_USE="^^ ( qt5 qt6 )"

DEPEND="
	qt5? (
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtdeclarative:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
	)
	qt6? (
		dev-qt/qt5compat:6
		dev-qt/qtbase:6[concurrent,gui,network,widgets]
		dev-qt/qtdeclarative:6
	)
"

RDEPEND="${DEPEND}"

src_prepare() {
	if use qt6; then
		# Upstream still uses Qt5; with USE=qt6 we apply a local port.
		# Upstream ships many source files with CRLF line endings; normalise
		# to LF so the Qt6 patch applies cleanly.
		find src CMakeLists.txt -type f \
			\( -name '*.cpp' -o -name '*.h' -o -name '*.hpp' -o -name '*.ui' -o -name 'CMakeLists.txt' \) \
			-exec sed -i 's/\r$//' {} + || die
		zcat "${FILESDIR}"/dwarftherapist-42.1.21-qt6.patch.gz > "${T}"/qt6.patch || die
		eapply "${T}"/qt6.patch
	fi
	cmake_src_prepare
}

pkg_postinst() {
	xdg_icon_cache_update
}

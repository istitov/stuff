# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="Dwarf (The)rapist for Dwarf Fortress"
HOMEPAGE="https://github.com/Dwarf-Therapist/Dwarf-Therapist"

if [[ ${PV} == 9999* ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Dwarf-Therapist/Dwarf-Therapist.git"
else
	SRC_URI="https://github.com/Dwarf-Therapist/Dwarf-Therapist/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~x86"
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
	# PAGE_SIZE only sizes the buffer for hashing the game binary and is not
	# defined off x86 (e.g. arm64); any chunk works, so use x86's 4096.
	# verified 2026-09-26
	sed -i 's/\bPAGE_SIZE\b/4096/g' src/dfinstancelinux.cpp || die
	grep -q PAGE_SIZE src/dfinstancelinux.cpp && die "PAGE_SIZE left in dfinstancelinux.cpp"

	if use qt6; then
		# Normalize upstream CRLF sources before applying the local Qt6 port.
		find src CMakeLists.txt -type f \
			\( -name '*.cpp' -o -name '*.h' -o -name '*.hpp' -o -name '*.ui' -o -name 'CMakeLists.txt' \) \
			-exec sed -i 's/\r$//' {} + || die
		xzcat "${FILESDIR}"/dwarftherapist-42.1.21-qt6.patch.xz > "${T}"/qt6.patch || die
		eapply "${T}"/qt6.patch
	fi
	cmake_src_prepare
}

pkg_postinst() {
	xdg_icon_cache_update
}

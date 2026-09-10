# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit cmake python-any-r1

DESCRIPTION="HSA runtime debug agent that dumps GPU state when a kernel faults"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocr-debug-agent"
# HSA_TOOLS_LIB loads GPU-fault diagnostics through amd-dbgapi, also used by
# gdb; hence dev-debug. Post-7.2.4 sources use therock-* tags.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
# Slot by ROCm release; the soname retains upstream's project major 2.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

# elfutils supplies both libdw and libelf; amd-dbgapi maps to the required
# rocdbgapi dependency. # verified 2026-08-30
RDEPEND="
	dev-libs/elfutils
	dev-libs/rocdbgapi:${SLOT}
	dev-libs/rocr-runtime:${SLOT}
"
DEPEND="${RDEPEND}"
# Only the test harness requires a Python interpreter at build time.
BDEPEND="
	test? (
		${PYTHON_DEPS}
		dev-util/hip:${SLOT}
	)
"

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	# External-header deprecations must not become fatal; guard sed's anchor.
	# verified 2026-08-30
	grep -q -- '-Werror' CMakeLists.txt ||
		die "-Werror gone from CMakeLists.txt; upstream likely dropped it, so drop this sed"
	sed -e 's/ -Werror//' -i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_TESTS=$(usex test)
	)
	cmake_src_configure
}

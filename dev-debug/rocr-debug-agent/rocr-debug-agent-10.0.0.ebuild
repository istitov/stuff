# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit cmake python-any-r1

DESCRIPTION="HSA runtime debug agent that dumps GPU state when a kernel faults"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocr-debug-agent"
# New package; ::gentoo carries no part of this. Loaded into an application via
# HSA_TOOLS_LIB=librocm-debug-agent.so.2, it prints wavefront state, the
# faulting instruction and a disassembly when the GPU traps -- the same
# amd-dbgapi surface dev-debug/gdb already uses through dev-libs/rocdbgapi, so
# it belongs next to gdb rather than in dev-libs.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the rocr-debug-agent.tar.gz asset on the rocm-systems
# therock-<major.minor> release, the same shape dev-libs/rocdbgapi uses.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
# Versioned by the ROCm release, not upstream's own project(VERSION 2.1.0),
# matching the rest of the stack. The soname still carries the real 2.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

# elfutils covers both of upstream's separate lookups: libdw (elfutils/libdw.h,
# -ldw) and libelf (libelf.h, -lelf). amd-dbgapi is dev-libs/rocdbgapi, which is
# the one hard ROCm dependency -- it is find_package(... REQUIRED) rather than
# QUIET-with-fallback like the others. verified 2026-08-30.
RDEPEND="
	dev-libs/elfutils
	dev-libs/rocdbgapi:${SLOT}
	dev-libs/rocr-runtime:${SLOT}
"
DEPEND="${RDEPEND}"
# The test harness drives the built agent from a Python script
# (find_package(Python3 REQUIRED COMPONENTS Interpreter) in test/CMakeLists.txt),
# so the interpreter is a build-time dependency of the tests only.
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
	# -Werror on a library built against three external header sets is a
	# recipe for a build that fails on an unrelated deprecation. Anchor is
	# asserted first: `sed` exits 0 on no-match, so if upstream drops -Werror
	# this would silently become a no-op and the intent would be lost.
	# verified 2026-08-30 -- present as
	# target_compile_options(... -Werror -Wall ...).
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

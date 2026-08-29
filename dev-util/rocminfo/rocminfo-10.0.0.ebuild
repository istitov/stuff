# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
inherit cmake python-r1

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/ROCm/rocminfo/"
	inherit git-r3
else
	# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
	# per-component assets ship under therock-<major.minor> tags now. ROCm 10.0
	# is the renumbering of the 7.13 -> 7.14 line (2026-08-27).
	SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/rocminfo"
fi

DESCRIPTION="ROCm Application for Reporting System Info"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocminfo"
LICENSE="UoI-NCSA"
SLOT="0/$(ver_cut 1-2)"

RDEPEND="dev-libs/rocr-runtime:${SLOT}
	${PYTHON_DEPS}"
DEPEND="${RDEPEND}"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	# `sed` exits 0 on no-match, so `|| die` cannot catch a stale anchor.
	# Assert both first. verified 2026-08-29 against therock-10.0.
	grep -q 'CPACK_RESOURCE_FILE_LICENSE' CMakeLists.txt ||
		die "CPACK_RESOURCE_FILE_LICENSE anchor moved"
	sed -e "/CPACK_RESOURCE_FILE_LICENSE/d" -i CMakeLists.txt || die

	grep -q 'num_change_since_prev_pkg(' cmake_modules/utils.cmake ||
		die "num_change_since_prev_pkg anchor moved"
	sed -e "/num_change_since_prev_pkg(/cset(NUM_COMMITS 0)" \
		-i cmake_modules/utils.cmake || die # Fix QA issue on "git not found"
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=( -DROCRTST_BLD_TYPE=Release )
	cmake_src_configure
}

src_install() {
	cmake_src_install
	rm "${ED}/usr/bin/rocm_agent_enumerator" || die
	python_foreach_impl python_doexe rocm_agent_enumerator "${BUILD_DIR}"/rocm_agent_enumerator
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Library that provides ROCm release version and install path information"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocm-core"
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28). Everything
# since ships under therock-<major.minor> tags on the same two monorepos, with
# the same per-component tarball assets -- so only the tag changes, not the
# fetch model. ROCm 10.0 is the renumbering of the 7.13 -> 7.14 line announced
# 2026-08-27, not a jump of three majors. verified 2026-08-28: therock-10.0
# carries rocm-core.tar.gz among its 31 assets.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/rocm-core"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

src_configure() {
	local mycmakeargs=( -DROCM_VERSION=${PV} )
	cmake_src_configure
}

src_install() {
	cmake_src_install
	# too broad for standard directory
	rm "${ED}"/usr/.info/version || die
}

RDEPEND="!<dev-util/hip-7.0"

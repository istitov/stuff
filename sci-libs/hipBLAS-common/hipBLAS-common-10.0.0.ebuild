# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake
DESCRIPTION="Common files shared by hipBLAS and hipBLASLt"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipblas-common"
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
# per-component assets ship under therock-<major.minor> tags now. ROCm 10.0 is
# the renumbering of the 7.13 -> 7.14 line (2026-08-27), not a jump of three
# majors. Only the tag changes -- the asset name is version-independent.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/hipblas-common.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/hipblas-common"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

BDEPEND="dev-build/rocm-cmake"

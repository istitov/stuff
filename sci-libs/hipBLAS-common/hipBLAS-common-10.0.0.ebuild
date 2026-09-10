# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake
DESCRIPTION="Common files shared by hipBLAS and hipBLASLt"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipblas-common"
# Component assets moved from rocm-* to therock-* tags after 7.2.4; ROCm 10
# renumbers the 7.13/7.14 line. Asset names remain version-independent.
# Verified 2026-08-27.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/hipblas-common.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/hipblas-common"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

BDEPEND="dev-build/rocm-cmake:${SLOT}"

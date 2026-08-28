# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="ROCclr runtime implementation for non-AMD HIP platforms, like NVIDIA"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/hipother"
# AMD retired the rocm-* line at rocm-7.2.4 (2026-05-28); every ROCm repo has
# published under therock-<major.minor> since. ROCm 10.0 is the renumbering of
# the 7.13 -> 7.14 line (2026-08-27), not a jump of three majors.
# verified 2026-08-28.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/hipother"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

src_install() {
	insinto /usr/include
	doins -r hipnv/include/hip
}

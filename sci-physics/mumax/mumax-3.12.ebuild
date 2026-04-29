# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="GPU-accelerated micromagnetic simulator"
HOMEPAGE="http://mumax.github.io/"
SRC_URI="https://github.com/${PN}/3/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/3-${PV}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=dev-util/nvidia-cuda-toolkit-7.5.18-r2"
RDEPEND="${DEPEND}"

src_prepare() {
	default

	# CUDA 13 promoted cuCtxCreate to cuCtxCreate_v4, which takes an
	# extra CUctxCreateParams* second arg. The legacy 3-arg
	# cuCtxCreate_v2 is gated behind __CUDA_API_VERSION_INTERNAL and
	# isn't reachable from cgo. Detect the new typedef in the
	# installed cuda.h and pass NULL for the new arg only then; on
	# CUDA 12 the original 3-arg signature works unchanged.
	if grep -q '\bCUctxCreateParams\b' \
			"${ESYSROOT}"/opt/cuda/include/cuda.h 2>/dev/null; then
		eapply "${FILESDIR}/mumax-cuda13-cuCtxCreate.patch"
	fi
}

src_compile() {
	ego build -o mumax3 ./cmd/mumax3
}

src_install() {
	dobin mumax3
	einstalldocs
}

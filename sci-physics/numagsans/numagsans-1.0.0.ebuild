# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake cuda

DESCRIPTION="GPU-accelerated magnetic small-angle neutron scattering simulator"
HOMEPAGE="https://github.com/AdamsMP92/NuMagSANS"
SRC_URI="https://github.com/AdamsMP92/NuMagSANS/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/NuMagSANS-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="dev-util/nvidia-cuda-toolkit:="
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-check-arguments.patch"
	"${FILESDIR}/${P}-require-cuda.patch"
)

src_prepare() {
	cuda_src_prepare
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_CUDA_FLAGS="${NVCCFLAGS}"
	)

	if [[ -n ${CUDAARCHS} ]]; then
		mycmakeargs+=( -DCMAKE_CUDA_ARCHITECTURES="${CUDAARCHS}" )
	fi

	cuda_add_sandbox
	addpredict /dev/char/
	cmake_src_configure
}

src_test() {
	local output

	output=$("${BUILD_DIR}/NuMagSANS" 2>&1) &&
		die "NuMagSANS accepted a missing input file"
	[[ ${output} == "Usage: NuMagSANS <input-file>" ]] ||
		die "unexpected usage output: ${output}"
}

src_install() {
	dobin "${BUILD_DIR}/NuMagSANS"
	einstalldocs

	docompress -x /usr/share/doc/${PF}/examples
	docinto examples
	dodoc NuMagSANSInput.conf
	dodoc -r RealSpaceData
}

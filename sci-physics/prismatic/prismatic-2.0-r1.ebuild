# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Prismatic Software for STEM Simulation"
HOMEPAGE="https://prism-em.com"
SRC_URI="https://github.com/prism-em/prismatic/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="double-precision gpu gui qt5 +qt6"

REQUIRED_USE="gui? ( ^^ ( qt5 qt6 ) )"

RDEPEND="
	dev-libs/boost:=
	sci-libs/fftw:3.0=[threads]
	sci-libs/hdf5:=[cxx]
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
	qt6? ( dev-qt/qtbase:6[gui,widgets] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	gpu? ( dev-util/nvidia-cuda-toolkit )
"

PATCHES=(
	"${FILESDIR}/${P}-cxx17-standard.patch"
	"${FILESDIR}/${P}-boost-bessel-qualify.patch"
	"${FILESDIR}/${P}-complex-literal.patch"
)

src_prepare() {
	cmake_src_prepare
	use qt6 && eapply "${FILESDIR}/${P}-qt6-port.patch"

	# CUDA 13 dropped sm_60 support; bump the hard-coded -arch=sm_60
	# in CMakeLists.txt to sm_75 only when building against CUDA >= 13.
	# CUDA 12 still accepts sm_60, so leave it alone there.
	if use gpu; then
		local cuda_ver=$(awk '/^#define CUDA_VERSION/ {print $3; exit}' \
			"${ESYSROOT}"/opt/cuda/include/cuda.h 2>/dev/null)
		if [[ -n ${cuda_ver} && ${cuda_ver} -ge 13000 ]]; then
			sed -i -e 's/-arch=sm_60 /-arch=sm_75 /' \
				CMakeLists.txt || die
		fi
	fi
}

src_configure() {
	local mycmakeargs=(
		-DPRISMATIC_ENABLE_CLI=1
		-DPRISMATIC_ENABLE_GUI=$(usex gui 1 0)
		-DPRISMATIC_ENABLE_GPU=$(usex gpu 1 0)
		-DPRISMATIC_ENABLE_DOUBLE_PRECISION=$(usex double-precision 1 0)
	)
	cmake_src_configure
}

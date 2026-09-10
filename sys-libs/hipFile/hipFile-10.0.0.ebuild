# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake linux-info rocm

DESCRIPTION="Direct-to-GPU storage I/O for the ROCm platform (AMD Infinity Storage)"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/hipfile"
# hipFile provides direct storage-to-GPU DMA with a POSIX fallback. It belongs
# in sys-libs as storage plumbing; ::gentoo has no package.
# ROCm 10 moved its source to hipfile.tar.gz on the rocm-systems therock-X.Y tag.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/hipfile.tar.gz -> hipfile-${PV}.tar.gz"
S="${WORKDIR}/hipfile"

LICENSE="MIT"
# Slot by ROCm release, matching the stack; upstream's 0.4.0 soname remains 0.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="examples tools"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

# Runtime links verified with objdump on libhipfile.so.0.4.0. libmount is used
# for mount-point inspection but absent from upstream CMake; rocr-runtime is a
# required configure check without a NEEDED entry. verified 2026-08-31
RDEPEND="
	dev-libs/rocprofiler-register:${SLOT}
	dev-util/hip:${SLOT}
	sys-apps/util-linux
"
DEPEND="
	${RDEPEND}
	dev-libs/rocr-runtime:${SLOT}
"

# Early-access preview; recheck on each bump. Direct DMA needs PCI_P2PDMA and a
# filesystem directly on the device; mapped/stacked storage forces POSIX mode.
# Only the kernel option is checkable. On haarmek with LVM and no P2PDMA,
# hipFileRead returned -999 instead of unsupported/fallback. verified 2026-08-31
CONFIG_CHECK="~PCI_P2PDMA"

pkg_setup() {
	linux-info_pkg_setup
}

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		# This first-class HIP project needs CMAKE_HIP_ARCHITECTURES, not
		# GPU_TARGETS; a wrong default links successfully but fails at runtime.
		-DCMAKE_HIP_ARCHITECTURES="$(get_amdgpu_flags)"
		# Upstream reads ROCM_PATH/.info/version, absent from split Gentoo installs;
		# provide both the real prefix and version. The cmake eclass has already
		# fixed CMAKE_INSTALL_PREFIX, so ROCM_PATH cannot override it.
		-DROCM_PATH="${EPREFIX}/usr"
		-DROCM_VERSION="${PV}"
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DHIPFILE_ROCPROFILER_REGISTER=ON
		-DAIS_INSTALL_EXAMPLES=$(usex examples)
		-DAIS_INSTALL_TOOLS=$(usex tools)
		-DAIS_INSTALL_TESTS=OFF
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	# A wrong HIP architecture still links; assert every requested target is
	# embedded before install. Same trap as media-libs/rocJPEG.
	local lib t
	lib=$(find "${BUILD_DIR}" -name 'libhipfile.so.*.*' -print -quit)
	[[ -n ${lib} ]] || die "libhipfile.so was not built"
	for t in ${AMDGPU_TARGETS}; do
		strings "${lib}" | grep -q "amdgcn-amd-amdhsa--${t}" ||
			die "libhipfile.so carries no device code for ${t}; CMAKE_HIP_ARCHITECTURES did not take effect"
	done

	cmake_src_install
}

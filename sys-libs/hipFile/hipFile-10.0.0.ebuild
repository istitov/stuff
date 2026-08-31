# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake linux-info rocm

DESCRIPTION="Direct-to-GPU storage I/O for the ROCm platform (AMD Infinity Storage)"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/hipfile"
# New package; ::gentoo carries no hipFile. It is AMD's answer to NVIDIA's
# GPUDirect Storage: file data is DMA'd straight into GPU memory instead of
# being staged through a host bounce buffer, with a transparent POSIX fallback
# when the direct path is unavailable. sys-libs rather than sci-libs -- it is
# storage I/O plumbing, not a math or science library.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the hipfile.tar.gz asset on the rocm-systems
# therock-<major.minor> release.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/hipfile.tar.gz -> hipfile-${PV}.tar.gz"
S="${WORKDIR}/hipfile"

LICENSE="MIT"
# Versioned by the ROCm release rather than upstream's AIS_LIBRARY_VERSION
# (0.4.0 here), matching the rest of the stack. The soname keeps the real 0.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="examples tools"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

# Split by what the built library actually links, not by what CMake asks for.
# objdump -p on libhipfile.so.0.4.0 reports libamdhip64.so.7,
# librocprofiler-register.so.0 and libmount.so.1 -- the last one is util-linux,
# pulled in for mount-point inspection (hipFile has to work out whether a file
# lives on a filesystem that supports the direct-to-GPU path) and is NOT named
# anywhere in upstream's CMake, so it would have been missed by reading the
# build files alone.
#
# dev-libs/rocr-runtime is find_package(hsa-runtime64 CONFIG REQUIRED) at
# configure time but does NOT appear as NEEDED, so it is build-time only.
# verified 2026-08-31.
RDEPEND="
	dev-libs/rocprofiler-register:${SLOT}
	dev-util/hip:${SLOT}
	sys-apps/util-linux
"
DEPEND="
	${RDEPEND}
	dev-libs/rocr-runtime:${SLOT}
"

# Upstream's README carries a CAUTION: "This release is an *early-access*
# software technology preview. Running production workloads is *not*
# recommended." Packaged anyway -- it builds and installs cleanly and the
# direct-I/O path degrades to POSIX by design -- but do not treat it as
# load-bearing. Re-read that banner on every bump. verified 2026-08-31.
#
# THE DIRECT PATH HAS REAL HOST REQUIREMENTS, and neither is something this
# ebuild can satisfy:
#
#   1. CONFIG_PCI_P2PDMA, checked below. docs/install/install.rst asks for "a
#      Linux kernel that exposes the peer-to-peer DMA (P2PDMA) paths hipFile
#      expects for peer transfers on AMD builds".
#   2. A filesystem sitting DIRECTLY on the device partition.
#      docs/troubleshooting/limitations.rst: "Any interposing block layer
#      between the filesystem and the device breaks the direct path and forces
#      a fallback to compatibility (POSIX) mode", listing LVM/device-mapper,
#      multipath, dm-crypt, MD RAID and loopback.
#
# Where the direct path is unavailable the library is still usable through its
# POSIX fallback, so this is a capability note rather than a reason not to
# install. Observed on haarmek 2026-08-31 (no P2PDMA, root and data both on
# LVM): hipFileDriverOpen, hipFileHandleRegister and hipFileBufRegister all
# return success, and only hipFileRead fails -- with -999, which maps to no
# hipFileOpError_t value at all ("Unknown hipFile error"). Returning an
# unmapped code instead of hipFileIONotSupported, or transparently falling
# back, looks like an upstream bug worth re-testing on a bump.
CONFIG_CHECK="~PCI_P2PDMA"

pkg_setup() {
	linux-info_pkg_setup
}

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		# hipFile uses CMake's FIRST-CLASS HIP language
		# (project(... LANGUAGES C CXX HIP)), not the hip::device INTERFACE
		# target, so the architecture knob is CMAKE_HIP_ARCHITECTURES rather
		# than GPU_TARGETS. It compiles real device code -- see
		# src/amd_detail/backend/memcpy-kernel.hip -- so leaving this unset
		# would let CMake pick its own default and silently produce a library
		# whose kernels cannot run on this GPU. src_install asserts the result.
		-DCMAKE_HIP_ARCHITECTURES="$(get_amdgpu_flags)"
		# Both REQUIRED, and neither is cosmetic. Upstream derives ROCM_VERSION
		# by reading ${ROCM_PATH}/.info/version, a file only a bundled /opt/rocm
		# install has; without it CMake dies in AISInstall.cmake with
		# "ROCM_VERSION='' does not match the expected MAJOR.MINOR[.PATCH]
		# form". ROCM_PATH itself defaults to /opt/rocm and is used as a
		# find_package hint; pointing it at the real prefix is correct here and
		# safe -- its only other use, forcing CMAKE_INSTALL_PREFIX, is guarded
		# by CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT, which the cmake
		# eclass has already falsified. verified 2026-08-31.
		-DROCM_PATH="${EPREFIX}/usr"
		-DROCM_VERSION="${PV}"
		# Plain `set(... CACHE STRING ...)` with no FORCE upstream, so -D wins.
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
	# Assert that device code for every requested target really landed in the
	# library. A HIP-language build that picks the wrong architecture still
	# links and installs; the only symptom is a kernel launch failing at
	# runtime. Same class of trap as media-libs/rocJPEG.
	local lib t
	lib=$(find "${BUILD_DIR}" -name 'libhipfile.so.*.*' -print -quit)
	[[ -n ${lib} ]] || die "libhipfile.so was not built"
	for t in ${AMDGPU_TARGETS}; do
		strings "${lib}" | grep -q "amdgcn-amd-amdhsa--${t}" ||
			die "libhipfile.so carries no device code for ${t}; CMAKE_HIP_ARCHITECTURES did not take effect"
	done

	cmake_src_install
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

# Prebuilt HRX runtime with the amdxdna (Ryzen AI NPU) driver. The version is
# libhrx's own (0.1.0) plus the release date. FastFlowLM pins one exact
# release in hrx-integration/hrx-release.env, so move this package only with
# that file. Since FastFlowLM 1.0.11 the pin is the standalone runtime archive
# of the FastFlow SDK, not a jtuyls/hrx release; only libhrx, its headers and
# its CMake package are taken from it. verified 2026-10-29
# The tag ends in the SDK's build counter for that day (0003); read it
# from hrx-release.env on each bump.
MY_TAG="fastflow-sdk-v0.1.0.dev${PV#*_p}0003"
MY_PN="fastflow-sdk-linux-x86_64"

DESCRIPTION="Prebuilt HRX runtime with the amdxdna driver for AMD Ryzen AI NPUs"
HOMEPAGE="
	https://github.com/ROCm/FastFlow-SDK
	https://github.com/ROCm/hrx-system
"
SRC_URI="
	https://github.com/ROCm/FastFlow-SDK/releases/download/${MY_TAG}/${MY_PN}.tar.zst
		-> ${P}.tar.zst
"
S="${WORKDIR}/${MY_PN}"

# HRX is Apache-2.0 with the LLVM exception; the statically linked flatcc
# runtime is Apache-2.0 with MIT parts.
LICENSE="Apache-2.0-with-LLVM-exceptions Apache-2.0 MIT"
SLOT="0"
KEYWORDS="-* ~amd64"

# The library opens /dev/accel/accel* itself: it needs the amdxdna kernel
# driver and firmware, not XRT. It links only glibc and the GCC runtime,
# and unlike earlier releases ships its debug info, so it is left to
# Portage's stripping. verified 2026-10-29
RDEPEND="dev-libs/xdna-driver"
BDEPEND="$(unpacker_src_uri_depends)"

QA_PREBUILT="opt/hrx-amdxdna/*"

src_unpack() {
	unpacker_src_unpack
}

src_install() {
	# Kept under /opt, not /usr: the package ships libhrx.so.0, the name a
	# source build of hrx-system would install. Consumers find it through
	# the CMake package (hrx_DIR or CMAKE_PREFIX_PATH).
	local dest="/opt/hrx-amdxdna"

	insinto "${dest}"
	doins -r include
	insinto "${dest}/lib"
	doins -r lib/cmake

	exeinto "${dest}/lib"
	doexe lib/libhrx.so.0.1.0
	dosym libhrx.so.0.1.0 "${dest}/lib/libhrx.so.0"
	dosym libhrx.so.0 "${dest}/lib/libhrx.so"

	docinto licenses
	dodoc licenses/{hrx-LICENSE,fastflow-sdk-LICENSE}
}

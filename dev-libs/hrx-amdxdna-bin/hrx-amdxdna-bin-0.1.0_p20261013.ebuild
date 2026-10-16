# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

# Prebuilt HRX runtime with the amdxdna (Ryzen AI NPU) driver, from the fork
# of ROCm/hrx-system that carries that driver; upstream has none yet. The
# version is libhrx's own (0.1.0) plus the release date. FastFlowLM pins one
# exact release in hrx-integration/hrx-release.env, so move this package only
# with that file. verified 2026-10-13
MY_DATE="${PV#*_p}"
MY_DATE="${MY_DATE:0:4}.${MY_DATE:4:2}.${MY_DATE:6:2}"
MY_COMMIT="e53f299"
MY_P="hrx-amdxdna-${MY_DATE}-amdxdna-hal-native-rel-${MY_COMMIT}-linux-x86_64"

DESCRIPTION="Prebuilt HRX runtime with the amdxdna driver for AMD Ryzen AI NPUs"
HOMEPAGE="
	https://github.com/jtuyls/hrx
	https://github.com/ROCm/hrx-system
"
SRC_URI="https://github.com/jtuyls/hrx/releases/download/flm-hrx-amdxdna-v${MY_DATE}/${MY_P}.tar.zst"
S="${WORKDIR}/${MY_P}"

# HRX is Apache-2.0 with the LLVM exception; the statically linked flatcc
# runtime is Apache-2.0 with MIT parts. Texts ship in LICENSES/.
LICENSE="Apache-2.0-with-LLVM-exceptions Apache-2.0 MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

# The library opens /dev/accel/accel* itself: it needs the amdxdna kernel
# driver and firmware, not XRT. It links only glibc and the GCC runtime.
# verified 2026-10-13
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

	dodoc README.md MANIFEST.json
	docinto licenses
	dodoc LICENSES/*
}

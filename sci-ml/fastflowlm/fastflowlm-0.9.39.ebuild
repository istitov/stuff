# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="NPU-first LLM runtime for AMD Ryzen AI (XDNA2) processors"
HOMEPAGE="
	https://www.fastflowlm.com/
	https://github.com/FastFlowLM/FastFlowLM
"

# Submodule commit pins.
TOKENIZERS_CPP_COMMIT="acbdc5a27ae01ba74cda756f94da698d40f11dfe"
SENTENCEPIECE_COMMIT="11051e3b73b3a6222a52acd720e39805dc7545ab"
MSGPACK_COMMIT="092bc69b6e815980bce7808595c914dd3a29f905"

SRC_URI="
	https://github.com/FastFlowLM/FastFlowLM/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/mlc-ai/tokenizers-cpp/archive/${TOKENIZERS_CPP_COMMIT}.tar.gz
		-> tokenizers-cpp-${TOKENIZERS_CPP_COMMIT}.tar.gz
	https://github.com/google/sentencepiece/archive/${SENTENCEPIECE_COMMIT}.tar.gz
		-> sentencepiece-${SENTENCEPIECE_COMMIT}.tar.gz
	https://github.com/msgpack/msgpack-c/archive/${MSGPACK_COMMIT}.tar.gz
		-> msgpack-c-${MSGPACK_COMMIT}.tar.gz
"
S="${WORKDIR}/FastFlowLM-${PV}"

# Orchestration / CLI is MIT (LICENSE_RUNTIME.txt); NPU compute kernels
# (xclbins) are proprietary (LICENSE_BINARY.txt → FastFlowLM-Binary).
LICENSE="MIT FastFlowLM-Binary"
SLOT="0"
KEYWORDS="~amd64"

# Cargo (inside tokenizers-cpp/rust) fetches crates at build time.
# Proper GURU submission would require pre-vendored crates via cargo.eclass.
PROPERTIES="live"
RESTRICT="network-sandbox"

BDEPEND="
	>=dev-build/cmake-3.22
	dev-build/ninja
	|| ( dev-lang/rust dev-lang/rust-bin )
"
RDEPEND="
	dev-util/xrt
	dev-libs/xdna-driver
	dev-libs/xrt-xdna
"
DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"

src_unpack() {
	default

	rmdir "${S}/third_party/tokenizers-cpp" || die
	mv "${WORKDIR}/tokenizers-cpp-${TOKENIZERS_CPP_COMMIT}" \
		"${S}/third_party/tokenizers-cpp" || die

	rmdir "${S}/third_party/tokenizers-cpp/sentencepiece" || die
	mv "${WORKDIR}/sentencepiece-${SENTENCEPIECE_COMMIT}" \
		"${S}/third_party/tokenizers-cpp/sentencepiece" || die

	rmdir "${S}/third_party/tokenizers-cpp/msgpack" || die
	mv "${WORKDIR}/msgpack-c-${MSGPACK_COMMIT}" \
		"${S}/third_party/tokenizers-cpp/msgpack" || die
}

src_prepare() {
	# Drop upstream's symlink-into-/usr/local/bin block; we provide our
	# own wrapper via newbin + env.d below.
	sed -i '/if.*NOT WIN32.*CMAKE_INSTALL_PREFIX/,/endif()/d' \
		"${S}/src/CMakeLists.txt" || die
	cmake_src_prepare
}

src_configure() {
	# FLM_VERSION + NPU_VERSION are set by the linux-default cmake preset
	# upstream; we set them here directly. NPU_VERSION on Linux only
	# satisfies a CMake guard (it's the Windows NPU driver version).
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/opt/fastflowlm"
		-DFLM_VERSION="${PV}"
		-DNPU_VERSION="32.0.203.304"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Wrapper so flm finds XRT and its own libs at runtime
	# (lemonade-sdk/lemonade#1315).
	newbin - flm <<-'EOF'
	#!/usr/bin/env bash
	set -euo pipefail
	export LD_LIBRARY_PATH="/opt/fastflowlm/lib:/opt/xilinx/xrt/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
	export FLM_CONFIG_PATH="${FLM_CONFIG_PATH:-/opt/fastflowlm/share/flm/model_list.json}"
	exec /opt/fastflowlm/bin/flm "$@"
	EOF

	newenvd - 99fastflowlm <<-'EOF'
	LDPATH="/opt/fastflowlm/lib"
	PATH="/opt/fastflowlm/bin"
	FLM_CONFIG_PATH="/opt/fastflowlm/share/flm/model_list.json"
	EOF
}

pkg_postinst() {
	elog ""
	elog "FastFlowLM ${PV} installed to /opt/fastflowlm."
	elog ""
	elog "Quick start:"
	elog "  flm validate          # verify NPU stack"
	elog "  flm pull llama3.2:3b  # download a model"
	elog "  flm run llama3.2:3b   # chat with it"
	elog ""
	elog "Models stored in ~/.config/flm/ (override: FLM_MODEL_PATH)."
	elog ""
	elog "Ensure memlock is unlimited.  If 'ulimit -l' is not 'unlimited',"
	elog "add to /etc/security/limits.d/99-amdxdna.conf:"
	elog "  *  soft  memlock  unlimited"
	elog "  *  hard  memlock  unlimited"
	elog ""
	elog "Run 'env-update && source /etc/profile' to pick up paths."
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

# Device-library binaries use Git LFS; stubs break llvm_zluda.
EGIT_LFS=yes

inherit git-r3 python-any-r1

DESCRIPTION="Drop-in replacement for CUDA on AMD GPUs"
HOMEPAGE="https://github.com/vosen/ZLUDA"

EGIT_REPO_URI="https://github.com/vosen/ZLUDA.git"
EGIT_SUBMODULES=( '*' )

# The bundled LLVM submodule adds its linking-exception license.
LICENSE="|| ( Apache-2.0 MIT ) Apache-2.0-with-LLVM-exceptions"
SLOT="0"
# Cargo, submodules, and LFS fetch at build time.
PROPERTIES="live"
RESTRICT="network-sandbox test"

# No CRATES list; follow upstream's online edition-2024 xtask build. LLVM needs
# CMake, Python, and C++.
BDEPEND="
	|| ( >=dev-lang/rust-1.85 >=dev-lang/rust-bin-1.85 )
	>=dev-build/cmake-3.20
	${PYTHON_DEPS}
	virtual/pkgconfig
"

# Installed cdylibs directly link HIP, rocm-smi, rocBLAS, hipBLASLt, and
# rocSPARSE; := forces rebuilds across ROCm SONAME changes. FFT is a stub, while
# LZ4 and LLVM are bundled; amd-comgr is no longer linked. verified 2026-05-27
RDEPEND="
	dev-util/hip:=
	dev-util/rocm-smi:=
	sci-libs/rocBLAS:=
	sci-libs/hipBLASLt:=
	sci-libs/rocSPARSE:=
"
DEPEND="${RDEPEND}"

src_compile() {
	# Build default members and their declared Linux CUDA symlinks.
	cargo xtask --release || die "cargo xtask --release failed"

	# xtask omits math replacements; build them explicitly. No cuRAND replacement
	# exists, so those applications still fall through or fail.
	local extra_pkgs=( zluda_fft zluda_blas zluda_blaslt zluda_sparse )
	local p
	for p in "${extra_pkgs[@]}"; do
		cargo build --release --package "${p}" || die "cargo build ${p} failed"
	done
}

src_install() {
	# Keep the upstream flat /opt layout opt-in; a default libcuda would shadow
	# nvidia-drivers on mixed systems.
	local zdir="/opt/zluda"

	insinto "${zdir}"
	# Core Linux cdylibs; omit Windows-only and debug-only outputs.
	doins target/release/libnvcuda.so
	doins target/release/libnvml.so
	doins target/release/libzluda_ld.so

	# Upstream-declared Linux aliases.
	dosym libnvcuda.so "${zdir}/libcuda.so"
	dosym libnvcuda.so "${zdir}/libcuda.so.1"
	dosym libnvml.so "${zdir}/libnvidia-ml.so"
	dosym libnvml.so "${zdir}/libnvidia-ml.so.1"
	# LD_AUDIT entry point (extension-less filename per quick_start.md).
	dosym libzluda_ld.so "${zdir}/zluda_ld"

	# Math cdylibs and upstream-declared SONAME aliases.
	doins target/release/libcufft.so
	dosym libcufft.so "${zdir}/libcufft.so.10"
	dosym libcufft.so "${zdir}/libcufft.so.11"
	dosym libcufft.so "${zdir}/libcufft.so.12"

	doins target/release/libcublas.so
	dosym libcublas.so "${zdir}/libcublas.so.11"
	dosym libcublas.so "${zdir}/libcublas.so.12"
	dosym libcublas.so "${zdir}/libcublas.so.13"

	# Rust emits lowercase libcublaslt; aliases match NVIDIA's capital-L spelling.
	doins target/release/libcublaslt.so
	dosym libcublaslt.so "${zdir}/libcublasLt.so"
	dosym libcublaslt.so "${zdir}/libcublasLt.so.11"
	dosym libcublaslt.so "${zdir}/libcublasLt.so.12"
	dosym libcublaslt.so "${zdir}/libcublasLt.so.13"

	doins target/release/libcusparse.so
	dosym libcusparse.so "${zdir}/libcusparse.so.10"
	dosym libcusparse.so "${zdir}/libcusparse.so.11"
	dosym libcusparse.so "${zdir}/libcusparse.so.12"

	dodoc README.md
}

pkg_postinst() {
	elog ""
	elog "ZLUDA installed under /opt/zluda/."
	elog ""
	elog "Run a CUDA application against ZLUDA:"
	elog "  LD_LIBRARY_PATH=/opt/zluda:\${LD_LIBRARY_PATH} <APP>"
	elog ""
	elog "or via the LD_AUDIT entry point:"
	elog "  LD_AUDIT=/opt/zluda/zluda_ld <APP>"
	elog ""
	elog "ZLUDA targets AMD GPUs only — requires a working ROCm/HIP runtime"
	elog "(dev-util/hip) and a supported AMD GPU. Upstream warns the project"
	elog "is under heavy development and may not yet work for your CUDA app."
	elog ""
	elog "Live ebuild — rebuild via: emerge --oneshot =dev-util/zluda-9999"
}

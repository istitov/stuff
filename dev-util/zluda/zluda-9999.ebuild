# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

# *.bc / *.dll under llvm_zluda/src/device-libs are git-lfs blobs and the
# llvm_zluda build.rs panics if it sees lfs stubs.
EGIT_LFS=yes

inherit git-r3 python-any-r1

DESCRIPTION="Drop-in replacement for CUDA on AMD GPUs"
HOMEPAGE="https://github.com/vosen/ZLUDA"

EGIT_REPO_URI="https://github.com/vosen/ZLUDA.git"
EGIT_SUBMODULES=( '*' )

# Dual-licensed; LLVM submodule (used at build time) is Apache-2.0 with the
# LLVM linking exception.
LICENSE="|| ( Apache-2.0 MIT ) Apache-2.0-with-LLVM-exceptions"
SLOT="0"
# No KEYWORDS for live ebuild.

# cargo fetches the entire workspace's dependency tree on first build; the
# kokoros / lemonade live ebuilds in this overlay use the same exception.
PROPERTIES="live"
RESTRICT="network-sandbox test"

# build deps: no CRATES — live ebuild fetches crates online, so depend on Rust
# directly (edition 2024). cmake + python3 + C++ are documented build
# requirements for the LLVM submodule build.
BDEPEND="
	|| ( >=dev-lang/rust-1.85 >=dev-lang/rust-bin-1.85 )
	>=dev-build/cmake-3.20
	${PYTHON_DEPS}
	virtual/pkgconfig
"

# runtime: AMD ROCm/HIP stack. cdylibs we install link these via ext/*
# sys-crates (verified 2026-05-27 against upstream master @ v6-preview.73):
#   zluda         → hip_runtime-sys → libamdhip64 (+ statically-bundled lz4)
#   zluda_ml      → rocm_smi-sys    → librocm_smi64
#   zluda_blas    → rocblas-sys     → librocblas    (+ libamdhip64)
#   zluda_blaslt  → hipblaslt-sys   → libhipblaslt  (+ libamdhip64)
#   zluda_sparse  → rocsparse-sys   → librocsparse
#   zluda_fft     → stub, no extra dep
# LLVM is bundled in-tree via ext/llvm-project since upstream fc204af
# ("Build and distribute LLVM", #555); libamd_comgr is no longer linked.
RDEPEND="
	dev-util/hip
	dev-util/rocm-smi
	sci-libs/rocBLAS
	sci-libs/hipBLASLt
	sci-libs/rocSPARSE
"
DEPEND="${RDEPEND}"

src_compile() {
	# Default xtask invocation per upstream docs/src/building.md: `cargo build
	# --release` on the workspace default-members (zluda, zluda_ml, zluda_inject,
	# zluda_redirect, compiler), creating the libnvcuda.so → libcuda.so{,.1}
	# symlinks from zluda/Cargo.toml's [package.metadata.zluda].linux_symlinks.
	cargo xtask --release || die "cargo xtask --release failed"

	# Math-library replacements (cuFFT / cuBLAS / cuBLASLt / cuSPARSE) live
	# in the workspace but aren't default-members, so xtask skips them. Build
	# them here so /opt/zluda can satisfy the corresponding libcufft.so.12 /
	# libcublas.so.12 / etc. lookups when a CUDA app is run with
	# LD_LIBRARY_PATH=/opt/zluda. Note: there is no zluda_curand crate, so
	# applications that use cuRAND (e.g. mumax3 with thermal noise) still
	# fall through to the NVIDIA stub or fail.
	local extra_pkgs=( zluda_fft zluda_blas zluda_blaslt zluda_sparse )
	local p
	for p in "${extra_pkgs[@]}"; do
		cargo build --release --package "${p}" || die "cargo build ${p} failed"
	done
}

src_install() {
	# Install to /opt/zluda (flat layout, matching upstream's prebuilt zip);
	# users opt in via LD_LIBRARY_PATH per upstream docs/src/quick_start.md.
	# Dropping libcuda.so into the default search path would shadow
	# nvidia-drivers' libcuda for any user with both installed.
	local zdir="/opt/zluda"

	insinto "${zdir}"
	# cdylibs built by xtask on Linux. Names follow each crate's [lib].name:
	#   zluda    → libnvcuda.so
	#   zluda_ml → libnvml.so
	#   zluda_ld → libzluda_ld.so
	# (zluda_inject / zluda_redirect are windows_only, compiler is debug_only.)
	doins target/release/libnvcuda.so
	doins target/release/libnvml.so
	doins target/release/libzluda_ld.so

	# Symlinks declared in each crate's [package.metadata.zluda].linux_symlinks.
	dosym libnvcuda.so "${zdir}/libcuda.so"
	dosym libnvcuda.so "${zdir}/libcuda.so.1"
	dosym libnvml.so "${zdir}/libnvidia-ml.so"
	dosym libnvml.so "${zdir}/libnvidia-ml.so.1"
	# LD_AUDIT entry point (extension-less filename per quick_start.md).
	dosym libzluda_ld.so "${zdir}/zluda_ld"

	# Math-library cdylibs + their versioned-soname symlinks (see each
	# crate's [package.metadata.zluda].linux_symlinks).
	doins target/release/libcufft.so
	dosym libcufft.so "${zdir}/libcufft.so.10"
	dosym libcufft.so "${zdir}/libcufft.so.11"
	dosym libcufft.so "${zdir}/libcufft.so.12"

	doins target/release/libcublas.so
	dosym libcublas.so "${zdir}/libcublas.so.11"
	dosym libcublas.so "${zdir}/libcublas.so.12"
	dosym libcublas.so "${zdir}/libcublas.so.13"

	# zluda_blaslt's [lib].name = "cublaslt" (lowercase), so the real
	# cdylib is libcublaslt.so; libcublasLt.so (capital L) is one of the
	# linux_symlinks pointing at it, matching NVIDIA's filename casing.
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

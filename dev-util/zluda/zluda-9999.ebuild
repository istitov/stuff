# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

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

# build deps:
#  - cargo eclass would normally derive Rust from CRATES; live ebuild fetches
#    online, so we depend on Rust directly. Edition 2024 is in use upstream.
#  - cmake + python3 + C++ compiler are documented build requirements (LLVM
#    submodule build).
BDEPEND="
	|| ( >=dev-lang/rust-1.85 >=dev-lang/rust-bin-1.85 )
	>=dev-build/cmake-3.20
	${PYTHON_DEPS}
	virtual/pkgconfig
"

# runtime: AMD ROCm/HIP stack. The cdylibs we install link against these via
# ext/* sys-crates: hip_runtime-sys → libamdhip64; amd_comgr-sys → libamd_comgr;
# rocblas-sys → librocblas (zluda_blas); hipblaslt-sys → libhipblaslt
# (zluda_blaslt); rocsparse-sys → librocsparse (zluda_sparse). zluda_fft is a
# pure stub today and adds no extra dep.
RDEPEND="
	dev-util/hip
	dev-libs/rocm-comgr
	sci-libs/rocBLAS
	sci-libs/hipBLASLt
	sci-libs/rocSPARSE
"
DEPEND="${RDEPEND}"

src_compile() {
	# Default xtask invocation per upstream docs/src/building.md. xtask runs
	# `cargo build --release` on the workspace's default-members
	# (zluda, zluda_ml, zluda_inject, zluda_redirect, compiler) and creates
	# the libnvcuda.so → libcuda.so{,.1} symlinks declared in
	# zluda/Cargo.toml's [package.metadata.zluda].linux_symlinks.
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
	# Install to /opt/zluda (flat layout, no lib/ subdir). Users opt in via
	# LD_LIBRARY_PATH per upstream docs/src/quick_start.md, where
	# <ZLUDA_DIRECTORY> is a flat directory matching the upstream prebuilt
	# zip. Dropping libcuda.so into the default search path would shadow
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

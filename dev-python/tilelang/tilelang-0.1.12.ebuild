# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Tile-level programming language for high-performance ML kernels"
HOMEPAGE="
	https://github.com/tile-ai/tilelang
	https://pypi.org/project/tilelang/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# torch-c-dlpack-ext is gated python_version<3.14 by upstream. Mirror
# that with python_targets_python3_{12..13} guards. # verified
# 2026-06-08 against 0.1.11.
#
# 0.1.12 pins apache-tvm-ffi<=0.1.11 (was open-ended in 0.1.11). tvm-ffi is
# the FFI ABI tilelang binds against — unlike the loose z3 cap below, this
# one is load-bearing. ::stuff carries apache-tvm-ffi-0.1.12, so cap at
# <0.1.12 to keep the resolver on 0.1.11. # verified 2026-07-10 against 0.1.12.
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	sci-mathematics/z3[python,${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.10[${PYTHON_USEDEP}]
		<dev-python/apache-tvm-ffi-0.1.12[${PYTHON_USEDEP}]
		dev-python/cloudpickle[${PYTHON_USEDEP}]
		dev-python/ml-dtypes[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.23.5[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		>=dev-python/tqdm-4.62.3[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.10[${PYTHON_USEDEP}]
	')
	python_single_target_python3_12? ( dev-python/torch-c-dlpack-ext[${PYTHON_SINGLE_USEDEP}] )
	python_single_target_python3_13? ( dev-python/torch-c-dlpack-ext[${PYTHON_SINGLE_USEDEP}] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/patchelf-0.17.2
	dev-util/nvidia-cuda-toolkit:=
	$(python_gen_cond_dep '
		>=dev-python/cython-3.1[${PYTHON_USEDEP}]
	')
"

# Upstream pyproject.toml caps z3-solver at <4.15.5 — ::gentoo carries
# z3 4.16.0 only, and we can't realistically fork an older z3 here.
# The cap appears to be a "tested up to here" bound rather than a
# known-incompatible API break. We rely on ::gentoo's z3 as an
# unversioned dep and don't claim upstream's <4.15.5 ceiling. Will
# revisit if a runtime test failure surfaces. # verified 2026-06-08.

# Upstream's bundled cmake/pypi-z3/FindZ3.cmake looks for libz3 and
# headers ONLY inside the PyPI z3-solver wheel's bundled site-packages
# layout (NO_DEFAULT_PATH). On Gentoo the system z3 lives at standard
# /usr/lib64 + /usr/include locations. Pre-setting Z3_INCLUDE_DIR and
# Z3_LIBRARY makes CMake's find_path / find_library skip the lookup
# entirely and use these values, after which the imported z3::libz3
# target is created with the correct paths.
DISTUTILS_ARGS=(
	-DZ3_INCLUDE_DIR=/usr/include
	-DZ3_LIBRARY=/usr/lib64/libz3.so
	# CUDA 13.x's nvcc rejects gcc later than 15 via crt/host_config.h.
	# If the active host gcc is 16 (or newer), point CMake's CUDA tooling
	# at the gcc-15 slot so the host-compiler path is in band. The
	# binary is shipped by ::gentoo's sys-devel/gcc:15 slot. # re-verified
	# 2026-06-08 with active gcc 16 + CUDA 13.3.
	-DCMAKE_CUDA_HOST_COMPILER=/usr/bin/x86_64-pc-linux-gnu-g++-15
	# TILELANG_USE_CUDA_STUBS defaults ON for "portable wheels" — it
	# links libtvm.so against tilelang-generated libcudart_stub /
	# libnvrtc_stub, which lazy-resolve via dlopen. But there is no
	# matching libcuda *driver*-API stub, so direct calls into the
	# driver API (cuDeviceGetName, etc.) come up as undefined-symbol
	# at import time. Turning the option OFF makes the build link
	# directly against /opt/cuda/lib64/stubs/libcuda.so / libcudart.so
	# / libnvrtc.so — the SONAMEs resolve to the real driver+runtime
	# libs at runtime via the system /etc/ld.so.cache. We don't ship
	# portable wheels here, so the loss-of-portability cost is moot.
	# NB: STUBS=OFF puts the libcuda stub on the link line, but Gentoo's
	# default --as-needed drops it from DT_NEEDED (the driver symbols are
	# referenced too indirectly to pin it) — src_install re-adds it with
	# patchelf, see there. # verified 2026-06-08 against 0.1.11.
	-DTILELANG_USE_CUDA_STUBS=OFF
)
export CUDAHOSTCXX=/usr/bin/x86_64-pc-linux-gnu-g++-15

python_install_all() {
	distutils-r1_python_install_all

	# libtvm_runtime.so / libtilelang.so call CUDA driver-API symbols
	# (cuDeviceGetName, ...) but Gentoo's --as-needed strips the libcuda
	# stub from DT_NEEDED despite TILELANG_USE_CUDA_STUBS=OFF (see the
	# DISTUTILS_ARGS note). Combined with hardening's -z now (BIND_NOW),
	# the dangling symbols make `import tilelang` fail at dlopen. Re-add
	# the driver SONAME so it resolves against the system libcuda.so.1 —
	# which tilelang requires at runtime anyway. # verified 2026-06-08
	# against 0.1.11 / CUDA 13.3 (import + sm_86 GPU kernel).
	local so
	while IFS= read -r -d '' so; do
		patchelf --add-needed libcuda.so.1 "${so}" || die
	done < <(find "${ED}" \( -name 'libtvm_runtime.so' -o -name 'libtilelang.so' \) -print0)
}

pkg_postinst() {
	elog "tilelang JIT-compiles kernels at runtime by invoking nvcc. On"
	elog "CUDA 13.x, nvcc rejects host gcc newer than 15. If your active"
	elog "gcc is 16+, point the runtime nvcc at the gcc-15 slot (the JIT"
	elog "does not honour CUDAHOSTCXX — pass -ccbin via NVCC_PREPEND_FLAGS):"
	elog ""
	elog "  export NVCC_PREPEND_FLAGS='-ccbin /usr/bin/x86_64-pc-linux-gnu-g++-15'"
	elog ""
	elog "Otherwise the first kernel compile fails with 'unsupported GNU"
	elog "version'. The build itself already pins gcc-15; this only"
	elog "affects kernels compiled at runtime in your own programs."
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Python bindings for CUDA driver and runtime APIs"
HOMEPAGE="
	https://github.com/NVIDIA/cuda-python
	https://nvidia.github.io/cuda-python/cuda-bindings/
	https://pypi.org/project/cuda-bindings/
"

# cuda-bindings uses bare v<PV> monorepo tags, unlike cuda-pathfinder's
# namespaced tags. # verified 2026-05-30
# 13.5.0 splits the package into cuda_bindings_12 and cuda_bindings_13;
# this one is the CUDA 13 build. # verified 2026-11-05
SRC_URI="
	https://github.com/NVIDIA/cuda-python/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cuda-python-${PV}/cuda_bindings_13"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
# The autouse context fixture requires an NVIDIA GPU.
RESTRICT="test"
# Required profiler headers make the toolkit's profiler USE flag mandatory.
RDEPEND="
	>=dev-python/cuda-pathfinder-1.5[${PYTHON_USEDEP}]
	dev-util/nvidia-cuda-toolkit:=[profiler]
"
# The source tree refuses headers older than its own CUDA minor release; the
# result runs on any CUDA 13.x toolkit. verified 2026-11-05
DEPEND="
	${RDEPEND}
	>=dev-util/nvidia-cuda-toolkit-$(ver_cut 1-2)
"
# standalone adds no backend dependency, so require upstream's setuptools >=80
# directly. The build backend also imports cuda-pathfinder. # verified 2026-07-27
# Upstream pins Cython below 3.3. Its own 3.3 bump (NVIDIA/cuda-python#2771)
# is still open over a benchmark regression, and 3.3 enforces declared
# container item types at runtime, so the EGL frame setters reject raw ints.
# The cap is kept; ::gentoo still has 3.2.9. verified 2026-11-05
# Upstream wants setuptools-scm >=8,!=10.1; ::gentoo starts above 10.1, so
# the floor alone expresses it. verified 2026-11-09
BDEPEND="
	>=dev-python/cuda-pathfinder-1.5[${PYTHON_USEDEP}]
	>=dev-python/cython-3.2.5[${PYTHON_USEDEP}]
	<dev-python/cython-3.3[${PYTHON_USEDEP}]
	>=dev-python/setuptools-80[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-10.1.1[${PYTHON_USEDEP}]
"

# build_hooks.py requires CUDA_HOME to locate headers.
export CUDA_HOME=/opt/cuda

# The archive lacks monorepo Git metadata, so supply a literal version. A
# v-prefixed value leaks into cuda.bindings.__version__ and breaks consumers
# such as cuda.core. # verified 2026-06-10
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_CUDA_BINDINGS="${PV}"

src_prepare() {
	# Let Portage control stripping and preserve split-debug support. Since
	# 13.5.0 the flags live in _build_shared.py, which also forces -g0.
	# verified 2026-11-05
	grep -qF 'extra_link_args += ["-Wl,--strip-all"]' _build_shared.py ||
		die "strip anchor moved"
	grep -qF 'extra_compile_args += ["-g0", "-O2"]' _build_shared.py ||
		die "-g0 anchor moved"
	sed -i \
		-e '/extra_link_args += \["-Wl,--strip-all"\]/d' \
		-e 's/extra_compile_args += \["-g0", "-O2"\]/extra_compile_args += ["-O2"]/' \
		_build_shared.py || die
	distutils-r1_src_prepare
}

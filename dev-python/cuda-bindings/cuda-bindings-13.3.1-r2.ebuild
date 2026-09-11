# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Python bindings for CUDA driver and runtime APIs"
HOMEPAGE="
	https://github.com/NVIDIA/cuda-python
	https://nvidia.github.io/cuda-python/cuda-bindings/
	https://pypi.org/project/cuda-bindings/
"

# cuda-bindings uses bare v<PV> monorepo tags, unlike cuda-pathfinder's
# namespaced tags. # verified 2026-05-30
SRC_URI="
	https://github.com/NVIDIA/cuda-python/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cuda-python-${PV}/cuda_bindings"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="~amd64"
# The autouse context fixture requires an NVIDIA GPU.
# The EULA forbids mirroring and binary redistribution.
RESTRICT="bindist mirror test"

# build_hooks.py parses CUDA headers and generates Cython; upstream pins Cython
# 3.2.x. Required profiler headers make the toolkit's profiler USE flag mandatory.
RDEPEND="
	>=dev-python/cuda-pathfinder-1.5[${PYTHON_USEDEP}]
	dev-util/nvidia-cuda-toolkit:=[profiler]
"
DEPEND="${RDEPEND}"
# standalone adds no backend dependency, so require upstream's setuptools >=80
# directly. The build backend also imports cuda-pathfinder. # verified 2026-07-27
BDEPEND="
	>=dev-python/pyclibrary-0.1.7[${PYTHON_USEDEP}]
	>=dev-python/cuda-pathfinder-1.5[${PYTHON_USEDEP}]
	>=dev-python/cython-3.2[${PYTHON_USEDEP}]
	<dev-python/cython-3.3[${PYTHON_USEDEP}]
	>=dev-python/setuptools-80[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
"

# build_hooks.py requires CUDA_HOME to locate headers.
export CUDA_HOME=/opt/cuda

# The archive lacks monorepo Git metadata, so supply a literal version. A
# v-prefixed value leaks into cuda.bindings.__version__ and breaks consumers
# such as cuda.core. # verified 2026-06-10
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_CUDA_BINDINGS="${PV}"

src_prepare() {
	# Let Portage control stripping and preserve split-debug support.
	sed -i -e '/extra_link_args += \["-Wl,--strip-all"\]/d' build_hooks.py || die
	distutils-r1_src_prepare
}

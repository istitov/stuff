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

# cuda-bindings uses v* monorepo tags, unlike cuda-pathfinder's prefixed tags.
SRC_URI="
	https://github.com/NVIDIA/cuda-python/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cuda-python-${PV}/cuda_bindings"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="~amd64"
# The autouse context fixture requires an NVIDIA GPU.
# The NVIDIA EULA forbids mirrored distfiles and redistributed binpkgs.
RESTRICT="bindist mirror test"

# build_hooks.py parses toolkit headers and generates Cython with the pinned
# 3.2.x series. Since 13.3, required profiler headers need toolkit[profiler].
RDEPEND="
	>=dev-python/cuda-pathfinder-1.5[${PYTHON_USEDEP}]
	dev-util/nvidia-cuda-toolkit:=[profiler]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/pyclibrary[${PYTHON_USEDEP}]
	>=dev-python/cython-3.2[${PYTHON_USEDEP}]
	<dev-python/cython-3.3[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
"

# build_hooks.py needs CUDA_HOME to locate toolkit headers.
export CUDA_HOME=/opt/cuda

# The archive lacks .git, while setuptools-scm searches the monorepo root.
# Its override bypasses tag_regex and leaks verbatim into __version__, so use
# the literal version rather than the v-prefixed tag. # verified 2026-06-10
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_CUDA_BINDINGS="${PV}"

src_prepare() {
	# Let Portage control stripping and preserve split-debug support.
	sed -i -e '/extra_link_args += \["-Wl,--strip-all"\]/d' build_hooks.py || die
	distutils-r1_src_prepare
}

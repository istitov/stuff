# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# PyTorch 2.14 moved to scikit-build-core. wheel.cmake=false preserves the split:
# this package installs upstream's Python trees without invoking CMake, while
# sci-ml/caffe2 owns libtorch, torch/_C, and generated torch/version.py.
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
inherit distutils-r1

DESCRIPTION="Tensors and Dynamic neural networks in Python"
HOMEPAGE="https://pytorch.org/"
SRC_URI="https://github.com/pytorch/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Mirror ::gentoo's monolithic IUSE by forwarding each flag to split caffe2.
# Separate atoms avoid pkgcheck's UncheckableDep on many conditional USE deps.
# verified 2026-09-10
IUSE="cuda cusparselt distributed fbgemm flash gloo kineto memefficient
	mimalloc mkl mpi nccl nnpack +numpy onednn openblas opencl openmp qnnpack
	rocm xnnpack"
RESTRICT="test"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	mpi? ( distributed )
	gloo? ( distributed )
	?? ( cuda rocm )
	rocm? ( memefficient? ( flash ) )
	cusparselt? ( || ( cuda rocm ) )
	flash? ( || ( cuda rocm ) )
	memefficient? ( || ( cuda rocm ) )
	nccl? ( rocm )
"
# Mirror unconditional Requires-Dist floors from wheel metadata. Most imports
# are lazy (FX, Inductor, remote I/O, cpp_extension) but are not optional.
# verified 2026-07-27
RDEPEND="
	${PYTHON_DEPS}
	~sci-ml/caffe2-${PV}[${PYTHON_SINGLE_USEDEP}]
	cuda? ( ~sci-ml/caffe2-${PV}[cuda] )
	cusparselt? ( ~sci-ml/caffe2-${PV}[cusparselt] )
	distributed? ( ~sci-ml/caffe2-${PV}[distributed] )
	fbgemm? ( ~sci-ml/caffe2-${PV}[fbgemm] )
	flash? ( ~sci-ml/caffe2-${PV}[flash] )
	gloo? ( ~sci-ml/caffe2-${PV}[gloo] )
	kineto? ( ~sci-ml/caffe2-${PV}[kineto] )
	memefficient? ( ~sci-ml/caffe2-${PV}[memefficient] )
	mimalloc? ( ~sci-ml/caffe2-${PV}[mimalloc] )
	mkl? ( ~sci-ml/caffe2-${PV}[mkl] )
	mpi? ( ~sci-ml/caffe2-${PV}[mpi] )
	nccl? ( ~sci-ml/caffe2-${PV}[nccl] )
	nnpack? ( ~sci-ml/caffe2-${PV}[nnpack] )
	numpy? ( ~sci-ml/caffe2-${PV}[numpy] )
	onednn? ( ~sci-ml/caffe2-${PV}[onednn] )
	openblas? ( ~sci-ml/caffe2-${PV}[openblas] )
	opencl? ( ~sci-ml/caffe2-${PV}[opencl] )
	openmp? ( ~sci-ml/caffe2-${PV}[openmp] )
	qnnpack? ( ~sci-ml/caffe2-${PV}[qnnpack] )
	rocm? ( ~sci-ml/caffe2-${PV}[rocm] )
	xnnpack? ( ~sci-ml/caffe2-${PV}[xnnpack] )
	$(python_gen_cond_dep '
		dev-python/filelock[${PYTHON_USEDEP}]
		>=dev-python/fsspec-0.8.5[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
		>=dev-python/networkx-2.5.1[${PYTHON_USEDEP}]
		>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]
		>=dev-python/sympy-1.13.3[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.10.0[${PYTHON_USEDEP}]
	')
	numpy? ( $(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	') )
"
# Mirror build-system requirements except CMake/Ninja, which are gated off with
# wheel.cmake=false.
DEPEND="${RDEPEND}
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
		>=dev-python/scikit-build-core-1.0[${PYTHON_USEDEP}]
		>=dev-python/packaging-24.2[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}"/${P}-cpp-extension-multilib.patch
)

src_prepare() {
	# Skip the C++ rebuild and package only Python trees. Keep platlib so they
	# share caffe2's location with torch/_C and torch/version.py.
	sed -e '/^\[tool\.scikit-build\.wheel\]/a cmake = false\nplatlib = true' \
		-i pyproject.toml || die
	grep -q '^cmake = false' pyproject.toml \
		|| die "wheel.cmake=false was not inserted -- upstream moved the table"

	# Empty third_party license globs violate PEP 639 because GitHub archives omit
	# submodules. Drop them; unbundled code is not installed, but retain LICENSE.
	sed -i -e '/^\s*"third_party\/\*\*\/LICENSE/d' pyproject.toml || die
	grep -q '"LICENSE",' pyproject.toml \
		|| die "top-level LICENSE entry disappeared from license-files"

	distutils-r1_src_prepare

	# PATCHES introduces this placeholder, so substitute only after src_prepare.
	sed -e "s|%LIB_DIR%|$(get_libdir)|g" \
		-i torch/utils/cpp_extension.py || die
	if grep -q '%LIB_DIR%' torch/utils/cpp_extension.py; then
		die "%LIB_DIR% placeholder survived substitution"
	fi
}

python_compile() {
	# Feed upstream's dynamic version provider without Git metadata.
	PYTORCH_BUILD_VERSION=${PV} \
	PYTORCH_BUILD_NUMBER=0 \
	distutils-r1_python_compile
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
inherit distutils-r1 prefix

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
# Mirror torch's unconditional Requires-Dist floors. Most load lazily through
# subpackages, but upstream does not mark them optional. # verified 2026-07-27
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
DEPEND="${RDEPEND}
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}"/${PN}-2.9.0-dontbuildagain.patch
	"${FILESDIR}"/${PN}-2.10.0-cpp-extension-multilib.patch
)

src_prepare() {
	# Share caffe2's build tree.
	sed -e "/BUILD_DIR/s|build|/var/lib/caffe2/|" \
		-i tools/setup_helpers/env.py || die

	# Use the declared backend rather than its deprecated legacy alias.
	sed -e "/build-backend/s|:__legacy__||" \
		-i pyproject.toml || die

	distutils-r1_src_prepare

	# cpp-extension-multilib.patch introduces this placeholder, so substitute
	# only after distutils applies PATCHES. # verified 2026-09-02
	sed -e "s|%LIB_DIR%|$(get_libdir)|g" \
		-i torch/utils/cpp_extension.py || die
	# Do not ship an unsubstituted path.
	if grep -q '%LIB_DIR%' torch/utils/cpp_extension.py; then
		die "%LIB_DIR% placeholder survived substitution"
	fi

	hprefixify tools/setup_helpers/env.py
}

python_compile() {
	PYTORCH_BUILD_VERSION=${PV} \
	PYTORCH_BUILD_NUMBER=0 \
	USE_SYSTEM_LIBS=ON \
	CMAKE_BUILD_DIR="${BUILD_DIR}" \
	distutils-r1_python_compile develop sdist
}

python_install() {
	USE_SYSTEM_LIBS=ON distutils-r1_python_install
}

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

# Every flag here only forwards to sci-ml/caffe2, which does the whole C++
# build; nothing in this package's own build reads them. They exist so that
# consumers written against ::gentoo's monolithic sci-ml/pytorch, which has
# this same IUSE, resolve against the split: ::gentoo's torchvision-0.28.0
# depends on =sci-ml/pytorch-2.13*[numpy,cuda?,rocm?], which no pytorch in
# this overlay could satisfy before. Each flag pulls caffe2 with the same
# flag, so pytorch[rocm] guarantees caffe2[rocm] without requiring the two
# USE sets to match. That is spelled as one USE-conditional block per flag
# rather than as flag? use-dependencies on a single atom: pkgcheck cannot
# expand 21 conditional use-dependencies on one atom, and then skips checking
# this package's dependencies altogether (UncheckableDep). REQUIRED_USE is
# caffe2's minus its amdgpu_targets rule, which only caffe2 can satisfy. numpy
# also adds numpy at runtime, as ::gentoo's pytorch does. verified 2026-09-10
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
# The python_gen_cond_dep block below mirrors torch's unconditional
# Requires-Dist verbatim, floors included, so it can be diffed against the
# built torch-${PV}.dist-info/METADATA. Only typing-extensions is imported by
# `import torch`; the rest are reached lazily -- sympy and networkx from
# torch.fx, jinja2 and filelock from the inductor codegen and its compile
# cache, fsspec from torch.load/save on remote paths, setuptools from
# torch.utils.cpp_extension. Lazy does not mean optional: upstream marks none
# of them as an extra. verified 2026-07-27
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
	# Set build dir for pytorch's setup
	sed -e "/BUILD_DIR/s|build|/var/lib/caffe2/|" \
		-i tools/setup_helpers/env.py || die

	# Drop legacy from pyproject.toml
	sed -e "/build-backend/s|:__legacy__||" \
		-i pyproject.toml || die

	distutils-r1_src_prepare

	# Replace the placeholder introduced by cpp-extension-multilib.patch.
	# This MUST run after distutils-r1_src_prepare: the placeholder does not
	# exist in upstream's source, the patch above puts it there, and PATCHES
	# are applied by distutils-r1_src_prepare. Running the sed first -- as
	# this ebuild did through 2.13.0-r91 -- matched nothing and exited 0, so
	# the literal %LIB_DIR% shipped: the installed
	# torch/utils/cpp_extension.py had `lib_dir = '%LIB_DIR%'` and
	# os.path.join(HIP_HOME, '%LIB_DIR%'), sending ROCm C++ extension builds
	# to /usr/%LIB_DIR% instead of /usr/$(get_libdir). Verified against the
	# merged 2.13.0-r91 on this host before the fix. # verified 2026-09-02
	sed -e "s|%LIB_DIR%|$(get_libdir)|g" \
		-i torch/utils/cpp_extension.py || die
	# Fail loudly if the placeholder ever stops being present, rather than
	# silently shipping an unsubstituted path again.
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

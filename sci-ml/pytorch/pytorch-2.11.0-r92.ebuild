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
# this same IUSE, resolve against the split. ::gentoo carries no 2.11 and no
# consumer asks this version for a flag today; the flags keep it in step with
# the 2.13 and 2.14 forks. Each flag pulls caffe2 with the same flag, so
# pytorch[rocm] guarantees caffe2[rocm] without requiring the two USE sets to
# match. That is spelled as one USE-conditional block per flag rather than as
# flag? use-dependencies on a single atom: pkgcheck cannot expand 21
# conditional use-dependencies on one atom, and then skips checking this
# package's dependencies altogether (UncheckableDep). REQUIRED_USE is caffe2's
# minus its amdgpu_targets rule, which only caffe2 can satisfy. numpy also
# adds numpy at runtime, as ::gentoo's pytorch does. verified 2026-09-10
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
# of them as an extra. Restored as a frozen rollback for the vllm(torch==2.11)
# stack (2.13.0-r91 forward otherwise). One deliberate deviation from torch
# 2.11.0's Requires-Dist: it caps setuptools<82, but that cap is unsatisfiable
# here -- it forces setuptools-79, which collides with any installed consumer
# needing >=80 (e.g. dev-python/ipython) since no setuptools exists in [80,82).
# The identical 2.13.0-r91 frontend runs on setuptools 83, and the cap only
# guards torch's cpp_extension, so relax to the same >=77.0.3 floor (no upper
# cap). verified 2026-08-08 against torch-2.11.0
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
	# This MUST run after distutils-r1_src_prepare, which is what applies
	# PATCHES: the placeholder does not exist upstream, the patch puts it
	# there, so running the sed first matched nothing, exited 0 and shipped
	# the literal -- library_paths() then handed ROCm C++ extension builds
	# /usr/%LIB_DIR% and $HIP_HOME/%LIB_DIR%. Same defect and same fix as
	# 2.13.0-r92; only the ROCm branch is affected, since the CUDA and CPU
	# branches compute lib_dir in Python. # verified 2026-09-03
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

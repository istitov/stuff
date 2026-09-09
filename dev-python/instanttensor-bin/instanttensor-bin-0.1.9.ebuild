# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
# Upstream publishes cp310..cp314 wheels (requires-python ">=3.9"); we cover
# the range the torch stack in this overlay is built for.
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN%-bin}
MY_BASE="https://files.pythonhosted.org/packages"
WHL_TAIL="manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"

DESCRIPTION="Ultra-fast distributed safetensors loader for CUDA (binary wheel)"
HOMEPAGE="https://pypi.org/project/instanttensor/"
SRC_URI="
	python_single_target_python3_12? (
		${MY_BASE}/97/01/667438b2c7b9caad3be48fe1363032574bb4a85d8d90b7a6e3ddf9979f53/${MY_PN}-${PV}-cp312-cp312-${WHL_TAIL}
	)
	python_single_target_python3_13? (
		${MY_BASE}/41/90/b50182538f64d59f4711dd902e60d84cdfb55a03e72a4619121a83260f28/${MY_PN}-${PV}-cp313-cp313-${WHL_TAIL}
	)
	python_single_target_python3_14? (
		${MY_BASE}/29/7c/b5cb0ae191bac6de43ea574b7d99a33ad9e680a44741b4f13b15e5e22e2f/${MY_PN}-${PV}-cp314-cp314-${WHL_TAIL}
	)
"
S="${WORKDIR}"

# InstantTensor itself is Apache-2.0. The extension statically links the
# vendored third_party/ set its sdist builds: libaio (LGPL-2.1), liburing
# (MIT, dual with LGPL-2.1 under COPYING), a header subset of Boost
# (Boost-1.0), pybind11 (BSD) and dlpack (Apache-2.0). Read from the 0.1.9
# sdist's csrc/third_party/, since the wheel ships no notice for them.
LICENSE="Apache-2.0 BSD Boost-1.0 LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

# Shipped as -bin: the sdist vendors and statically links libaio, liburing,
# a Boost header subset, pybind11 and dlpack (~94 MiB of third_party/), and
# drives their in-tree Makefiles from a custom build_ext. Unbundling that to
# the system copies is a packaging job of its own; the wheel is the
# upstream-supported form. It is a plain CPython extension -- `readelf -d`
# on _C.cpython-313-x86_64-linux-gnu.so lists only libdl/libstdc++/libm/
# libgcc_s/libpthread/libc, no libtorch or libc10 -- so unlike a torch C++
# extension it is not ABI-locked to a torch minor, and upstream's own
# torch>=2.8.0 floor is the real bound. verified 2026-09-09 against the
# cp313 wheel.
#
# instanttensor._impl imports torch and torch.distributed at module load, but
# only reaches the collective calls (all_reduce / all_gather_object /
# get_world_size) when a process group is passed in; single-rank loading runs
# with process_group=None and never touches them. So caffe2[distributed] is
# not required here -- multi-rank callers (vllm) pull it themselves.
#
# The extension adds no library dependencies of its own either. Its cuFile,
# CUDA-runtime and NCCL entry points are late-bound through
# csrc/instant_tensor/dl_binding/, which scans /proc/self/maps for a loaded
# lib{cufile,hipfile,cudart,nccl,rccl}.so and reopens it with
# dlopen(RTLD_NOLOAD) -- reuse only, never a load. So each backend is live
# exactly when torch has already pulled that library into the process and is
# skipped otherwise (cufile_available() is a best-effort probe with an
# io_uring / libaio / in-memory fallback). Nothing here needs the CUDA toolkit
# or NCCL declared. verified 2026-09-09 against the 0.1.9 sources.
RDEPEND="
	>=sci-ml/pytorch-2.8.0[${PYTHON_SINGLE_USEDEP}]
	sci-ml/caffe2
"

# python_install below drives `installer` by hand. distutils-r1 only pulls
# dev-python/installer in for a PEP517 build, and this is
# DISTUTILS_USE_PEP517=no, so declare it here rather than rely on it being
# incidentally merged.
BDEPEND+="
	$(python_gen_cond_dep '
		dev-python/installer[${PYTHON_USEDEP}]
	')
"

QA_PREBUILT="usr/lib*/python*/site-packages/instanttensor/*.so"

python_install() {
	local cptag=${EPYTHON#python}
	cptag=cp${cptag//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-${WHL_TAIL}"
	[[ -f ${DISTDIR}/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${DISTDIR}/${whl}" || die
	# `installer` doesn't byte-compile.
	python_optimize
}

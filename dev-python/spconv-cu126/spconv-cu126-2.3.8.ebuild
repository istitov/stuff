# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_13 )

inherit distutils-r1

MY_PN="${PN/-/_}"
DESCRIPTION="Spatially sparse convolution library (prebuilt cu126 wheel)"
HOMEPAGE="
	https://github.com/traveller59/spconv
	https://pypi.org/project/spconv-cu126/
"
# Prebuilt manylinux CUDA-12.6 wheel. spconv is the sparse-conv backend that
# matches the TRELLIS pretrained weights (they are spconv-format; torchsparse
# uses incompatible weight naming/layout). Verified to load TRELLIS and run
# image->3D on a CUDA-13.3 / torch-2.11 host. spconv 2.x bundles its own CUDA
# kernels and does not link libtorch, so it is torch-version-independent.
SRC_URI="
	https://files.pythonhosted.org/packages/af/fd/c52d71468849d09b333123f9d0cac27b4a3815a8faecff21ebd66d9c7b45/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/spconv/*"

# Upstream also lists 'fire'; it is only used by spconv's CLI tools, not when
# importing the prebuilt ops at runtime. verified 2026-06-17
RDEPEND="
	~dev-python/cumm-cu126-0.7.11[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/pccm[${PYTHON_USEDEP}]
		dev-python/ccimport[${PYTHON_USEDEP}]
		dev-python/pybind11[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

src_install() {
	python_setup
	"${EPYTHON}" -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}

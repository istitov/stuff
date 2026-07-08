# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
# Upstream wheels now reach cp314 (requires-python = "<3.15,>=3.10").
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN%-bin}
MY_PV=${PV}
MY_BASE="https://files.pythonhosted.org/packages"

DESCRIPTION="NVIDIA CUDA Tile Compiler (binary wheels)"
HOMEPAGE="
	https://pypi.org/project/cuda-tile/
"
SRC_URI="
	python_targets_python3_12? ( ${MY_BASE}/1c/f5/b4ba9d0fc71198d939ebf9a090228179995d8411ee9def8f638a0e3ccdc5/${MY_PN//-/_}-${MY_PV}-cp312-cp312-manylinux2014_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/26/d5/ae03d2b70ed8d6c21ca809ddc98227ad07988e7fe67e7e41d888c0b13d32/${MY_PN//-/_}-${MY_PV}-cp313-cp313-manylinux2014_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/65/38/165499cbfb7c1ada110592fa9224e20851125b337bbe2e656b5d56c676f0/${MY_PN//-/_}-${MY_PV}-cp314-cp314-manylinux2014_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror"

# Upstream ships wheel-only on PyPI (no sdist), and the project source
# (NVIDIA's CUDA Tile compiler) is not published — so a -bin shape is
# the only available form. Required transitively by flashinfer-python
# in vllm's CUDA target. # verified 2026-05-29 against 1.4.0.
RDEPEND="
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3.*/site-packages/cuda_tile/*.so*"

src_unpack() {
	# distutils-r1 with DISTUTILS_USE_PEP517=no and a wheel SRC_URI
	# would try to unpack the .whl directly into S. We instead stash
	# the per-impl wheels and feed them to `installer` per impl below.
	mkdir -p "${S}/wheel" || die
	local f
	for f in "${A}"; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

src_install() {
	python_foreach_impl install_wheel
}

install_wheel() {
	# EPYTHON gives e.g. python3.13; the matching wheel tag is cp313.
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN//-/_}-${MY_PV}-${cptag}-${cptag}-manylinux2014_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
}

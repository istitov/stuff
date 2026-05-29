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
	python_targets_python3_12? ( ${MY_BASE}/d7/9a/7fbdbdb30c375f80818941165adfc4f1dc6cebaf937c6a9081a02d5871f0/${MY_PN//-/_}-${MY_PV}-cp312-cp312-manylinux2014_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/11/0b/4770f9e36b8108ce8c9078f71eb21c65e594d79c0770dd38daa045cfbd6c/${MY_PN//-/_}-${MY_PV}-cp313-cp313-manylinux2014_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/8f/fb/bf3849ad68b1858ba50e6992863d266892d7d7db02d11c485c26cd090a1b/${MY_PN//-/_}-${MY_PV}-cp314-cp314-manylinux2014_x86_64.whl )
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

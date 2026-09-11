# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=no
# Upstream provides wheels through cp314 and requires Python <3.15.
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
	python_targets_python3_12? ( ${MY_BASE}/40/21/3dfeafbd3512e94a277a25ce022c10e7bdff5d43e364afffcc0928f7fcaf/${MY_PN//-/_}-${MY_PV}-cp312-cp312-manylinux2014_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/9c/70/879ab39f2dab93eca6c9d5caa8b5195ceccf330f95bbd8cb5f35289ee9be/${MY_PN//-/_}-${MY_PV}-cp313-cp313-manylinux2014_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/3c/94/9d174b601cf5e23eaf1590b63b1eb30f21944e91b99f61e6a0908b6f28ab/${MY_PN//-/_}-${MY_PV}-cp314-cp314-manylinux2014_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"

# Upstream publishes only wheels; required through flashinfer-python.
RDEPEND="
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3.*/site-packages/cuda_tile/*.so*"

src_unpack() {
	# Prevent default wheel unpacking; install each implementation below.
	mkdir -p "${S}/wheel" || die
	local f
	for f in "${A}"; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

python_install() {
	# Map python3.13 to its cp313 wheel tag.
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN//-/_}-${MY_PV}-${cptag}-${cptag}-manylinux2014_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
	python_optimize
}

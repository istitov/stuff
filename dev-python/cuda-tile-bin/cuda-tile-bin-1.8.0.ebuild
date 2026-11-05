# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=standalone
# Since 1.8.0 upstream provides wheels through cp315 and requires
# Python <3.16. verified 2026-11-05
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

MY_PN=${PN%-bin}
MY_PV=${PV}
MY_BASE="https://files.pythonhosted.org/packages"

DESCRIPTION="NVIDIA CUDA Tile Compiler (binary wheels)"
HOMEPAGE="
	https://pypi.org/project/cuda-tile/
"
SRC_URI="
	python_targets_python3_12? ( ${MY_BASE}/5f/7c/46c23641dc2423ae4a7f9607a7e812632aabd4201da43bed062637bea09c/${MY_PN//-/_}-${MY_PV}-cp312-cp312-manylinux2014_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/08/66/93254c1aa0ce07745186a28c108ffb037a68faa2aef487f520038ffa8edf/${MY_PN//-/_}-${MY_PV}-cp313-cp313-manylinux2014_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/94/58/f488c6f8e481b7f566e330d0a149ab173939ec912a302acedbb01672c6d8/${MY_PN//-/_}-${MY_PV}-cp314-cp314-manylinux2014_x86_64.whl )
	python_targets_python3_15? ( ${MY_BASE}/e6/cf/3c0a855cbe6e6004d3c5baec8148bbefa05297154db1c02c9259bf4b0455/${MY_PN//-/_}-${MY_PV}-cp315-cp315-manylinux2014_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"

# Upstream publishes only wheels; required through flashinfer-python.
RDEPEND="
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3.*/site-packages/cuda/tile/*.so"

src_unpack() {
	# The wheels are installed as they are in python_compile.
	:
}

python_compile() {
	# The wheel carries the cutile-cache console script. Installing each
	# implementation straight into ${D} collides on /usr/bin; staging them
	# with distutils_wheel_install lets the eclass wrap the script with
	# python-exec. verified 2026-11-05
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN//-/_}-${MY_PV}-${cptag}-${cptag}-manylinux2014_x86_64.whl"
	[[ -f ${DISTDIR}/${whl} ]] || die "expected wheel ${whl} not found"
	distutils_wheel_install "${BUILD_DIR}/install" "${DISTDIR}/${whl}"
}

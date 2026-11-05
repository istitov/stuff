# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=standalone
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
	python_targets_python3_12? ( ${MY_BASE}/62/a1/071e186cc45859df593b80d292e03581af30755cadebbd180603b0fc6712/${MY_PN//-/_}-${MY_PV}-cp312-cp312-manylinux2014_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/70/76/486f77b44f3f2407e98fb3b158f91fe0782050a241e0c20798690084d14a/${MY_PN//-/_}-${MY_PV}-cp313-cp313-manylinux2014_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/f6/82/557c8bb7a73381cc287106d3f35a39858ea876f54af0805c9a9c3e8f958b/${MY_PN//-/_}-${MY_PV}-cp314-cp314-manylinux2014_x86_64.whl )
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

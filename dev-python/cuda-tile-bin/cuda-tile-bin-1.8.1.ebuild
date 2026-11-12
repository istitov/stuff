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
	python_targets_python3_12? ( ${MY_BASE}/b4/94/c80ea5922875479c000326c379ece64e3375183179c3f226d43b6375a246/${MY_PN//-/_}-${MY_PV}-cp312-cp312-manylinux2014_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/9d/cc/2034c4bb3cf86735dbd9a98002c9e4b187a897bfea45237a92e2f7b5091b/${MY_PN//-/_}-${MY_PV}-cp313-cp313-manylinux2014_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/dd/5b/0d86be58ed288205cf1b125d814ee5a29aac9f362085e3310a3b0365ada4/${MY_PN//-/_}-${MY_PV}-cp314-cp314-manylinux2014_x86_64.whl )
	python_targets_python3_15? ( ${MY_BASE}/73/99/eefbba7fad393014cb478e381e2d84de20b98f06b1b20cf575483b26b6fb/${MY_PN//-/_}-${MY_PV}-cp315-cp315-manylinux2014_x86_64.whl )
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

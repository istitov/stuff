# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
# Upstream does not publish CPython 3.15 wheels yet.
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN="kornia_rs"
MY_BASE="https://files.pythonhosted.org/packages"
AMD64_WHL_TAIL="manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
ARM64_WHL_TAIL="manylinux_2_17_aarch64.manylinux2014_aarch64.whl"

case ${ARCH} in
	amd64) WHL_TAIL=${AMD64_WHL_TAIL} ;;
	arm64) WHL_TAIL=${ARM64_WHL_TAIL} ;;
esac

DESCRIPTION="Low-level computer vision ops in Rust with PyO3 bindings (binary wheels)"
HOMEPAGE="
	https://github.com/kornia/kornia-rs
	https://pypi.org/project/kornia-rs/
"
SRC_URI="
	amd64? (
		python_targets_python3_12? ( ${MY_BASE}/56/72/4a9502b5243667fae48cccbfbc00fb9a6fffb219494c84797d18a6d23f4d/${MY_PN}-${PV}-cp312-cp312-${AMD64_WHL_TAIL} )
		python_targets_python3_13? ( ${MY_BASE}/3f/4c/55ff90d22a7cb3c1b63fadde59336fe1e668c1ebfef1bfbdb6a933305df0/${MY_PN}-${PV}-cp313-cp313-${AMD64_WHL_TAIL} )
		python_targets_python3_14? ( ${MY_BASE}/df/22/1e800fdd667692f46e55298ce265a42261931d03feb681f2d6c0172f3083/${MY_PN}-${PV}-cp314-cp314-${AMD64_WHL_TAIL} )
	)
	arm64? (
		python_targets_python3_12? ( ${MY_BASE}/2c/cb/4d24e07c76cd1100897804f8055cebfd03558db119deb0abcf8bfb0c4113/${MY_PN}-${PV}-cp312-cp312-${ARM64_WHL_TAIL} )
		python_targets_python3_13? ( ${MY_BASE}/aa/71/37ef7cd0a3957a64a431f70186da9b588945585abef5aaad684c1c3b981a/${MY_PN}-${PV}-cp313-cp313-${ARM64_WHL_TAIL} )
		python_targets_python3_14? ( ${MY_BASE}/23/cc/c74b9ef2b0d47fa5a2d05ae18c522f6ea31ce3196b64521a9d03f24368b2/${MY_PN}-${PV}-cp314-cp314-${ARM64_WHL_TAIL} )
	)
"
S="${WORKDIR}"

# Wheel metadata and bundled license identify Apache-2.0; -bin avoids packaging
# the Rust/PyO3 source graph.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/kornia_rs/*"
BDEPEND="dev-python/installer[${PYTHON_USEDEP}]"

src_unpack() {
	# Preserve per-implementation wheels for python_install().
	mkdir -p "${S}/wheel" || die
	local f
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

src_compile() { :; }

python_install() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-${WHL_TAIL}"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
	python_optimize
}

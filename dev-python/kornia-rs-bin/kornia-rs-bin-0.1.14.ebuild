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
		python_targets_python3_12? ( ${MY_BASE}/72/7f/01c9456a09a3a5731bf986724f6f6ff70d627ac8072cf298d842ec204692/${MY_PN}-${PV}-cp312-cp312-${AMD64_WHL_TAIL} )
		python_targets_python3_13? ( ${MY_BASE}/f2/09/3f78df732325132a3f8fceb0059c1e4736bb48e4fca8acea7d3de93ad15f/${MY_PN}-${PV}-cp313-cp313-${AMD64_WHL_TAIL} )
		python_targets_python3_14? ( ${MY_BASE}/ed/05/ffd6ae5b5cdddcbf9f7b7940d408c38911b8ab3911148b5b114522410ff1/${MY_PN}-${PV}-cp314-cp314-${AMD64_WHL_TAIL} )
	)
	arm64? (
		python_targets_python3_12? ( ${MY_BASE}/d1/f5/dc5e8f69130de7ed8d59500789bc0cf1658ada8d5360164e416622cb47f1/${MY_PN}-${PV}-cp312-cp312-${ARM64_WHL_TAIL} )
		python_targets_python3_13? ( ${MY_BASE}/32/f2/ebb0584fe11a93b4f92fbd2638c0476999003e3501557c26ceef51a5b9da/${MY_PN}-${PV}-cp313-cp313-${ARM64_WHL_TAIL} )
		python_targets_python3_14? ( ${MY_BASE}/58/89/a90c7ebe73715ec5d326cf5f215f430f32fb5f208a0f7db7bc04f523d7e6/${MY_PN}-${PV}-cp314-cp314-${ARM64_WHL_TAIL} )
	)
"
S="${WORKDIR}"

# Project is Apache-2.0; the wheel statically links permissively-licensed
# Rust crates (MIT/Apache-2.0/BSD). Shipped as -bin to avoid vendoring the
# Rust/PyO3 dependency graph in-tree.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/kornia_rs/*"
BDEPEND="dev-python/installer[${PYTHON_USEDEP}]"

src_unpack() {
	# distutils-r1 (PEP517=no) would try to build from the wheel; stash the
	# per-impl wheels and feed them to `installer` instead.
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

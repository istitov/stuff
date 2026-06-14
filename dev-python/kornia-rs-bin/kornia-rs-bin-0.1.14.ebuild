# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
# Upstream ships per-cpython manylinux wheels up to cp313 only (no cp314 as
# of 0.1.14), and python3_11 is past the eclass support window, so the usable
# range is 3.12-3.13. kornia is capped to match.
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1

MY_PN="kornia_rs"
MY_BASE="https://files.pythonhosted.org/packages"
WHL_TAIL="manylinux_2_17_x86_64.manylinux2014_x86_64.whl"

DESCRIPTION="Low-level computer vision ops in Rust with PyO3 bindings (binary wheels)"
HOMEPAGE="
	https://github.com/kornia/kornia-rs
	https://pypi.org/project/kornia-rs/
"
SRC_URI="
	python_targets_python3_12? ( ${MY_BASE}/72/7f/01c9456a09a3a5731bf986724f6f6ff70d627ac8072cf298d842ec204692/${MY_PN}-${PV}-cp312-cp312-${WHL_TAIL} )
	python_targets_python3_13? ( ${MY_BASE}/f2/09/3f78df732325132a3f8fceb0059c1e4736bb48e4fca8acea7d3de93ad15f/${MY_PN}-${PV}-cp313-cp313-${WHL_TAIL} )
"
S="${WORKDIR}"

# Project is Apache-2.0; the wheel statically links permissively-licensed
# Rust crates (MIT/Apache-2.0/BSD). Shipped as -bin because upstream
# publishes no sdist and the Rust/PyO3 source build is impractical in-tree.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/kornia_rs/*"

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

src_install() {
	python_foreach_impl install_wheel
}

install_wheel() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-${WHL_TAIL}"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
	python_optimize
}

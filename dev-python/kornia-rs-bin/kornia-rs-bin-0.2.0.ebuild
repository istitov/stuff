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
		python_targets_python3_12? ( ${MY_BASE}/1b/01/05a31ef5ed358f9a086626718fb7bafba4a5f60e408ec1bb2309ba307779/${MY_PN}-${PV}-cp312-cp312-${AMD64_WHL_TAIL} )
		python_targets_python3_13? ( ${MY_BASE}/eb/4c/b7f9a36a6fe174069c9a6f2f6debea49e7c992dcbb8a768a217303ef1b49/${MY_PN}-${PV}-cp313-cp313-${AMD64_WHL_TAIL} )
		python_targets_python3_14? ( ${MY_BASE}/99/5b/eda16fb41f2321bbb227e53350bad5d1302100dbadb0386f6b1cdac9075b/${MY_PN}-${PV}-cp314-cp314-${AMD64_WHL_TAIL} )
	)
	arm64? (
		python_targets_python3_12? ( ${MY_BASE}/07/12/40544b39cb08db8577c7e4b227d41be2ee6f18304627751645572d504f47/${MY_PN}-${PV}-cp312-cp312-${ARM64_WHL_TAIL} )
		python_targets_python3_13? ( ${MY_BASE}/00/04/b64d07637c09d23f1020f77b25e44681b0fd639291272aab55dc1b528436/${MY_PN}-${PV}-cp313-cp313-${ARM64_WHL_TAIL} )
		python_targets_python3_14? ( ${MY_BASE}/81/2e/3e078823b92c8e4f08abf7532f5eff9e99948066d65ad416ae81700e8b1c/${MY_PN}-${PV}-cp314-cp314-${ARM64_WHL_TAIL} )
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

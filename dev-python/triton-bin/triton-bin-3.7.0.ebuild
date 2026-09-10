# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
# Match the Torch stack within the wheel's >=3.10,<3.15 range.
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN%-bin}
MY_BASE="https://files.pythonhosted.org/packages"
# Triton publishes a single fat manylinux tag per (impl) wheel.
WHL_TAIL="manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"

DESCRIPTION="Triton GPU programming language and compiler (binary wheels)"
HOMEPAGE="
	https://github.com/triton-lang/triton
	https://pypi.org/project/triton/
"
SRC_URI="
	python_targets_python3_12? ( ${MY_BASE}/62/7b/468a576e35beef1426e0828e28e9ba9e65f5474d496f16ee126c15646324/${MY_PN}-${PV}-cp312-cp312-${WHL_TAIL} )
	python_targets_python3_13? ( ${MY_BASE}/30/b1/b7507bb9815d403927c8dd51d4158ed2e11751a92dbc118a044f247b6848/${MY_PN}-${PV}-cp313-cp313-${WHL_TAIL} )
	python_targets_python3_14? ( ${MY_BASE}/8f/af/9904ec6d3c93d9b24e5ec360445bbdf758b7f00bfbeedb89cb0eb64eb8bb/${MY_PN}-${PV}-cp314-cp314-${WHL_TAIL} )
"
S="${WORKDIR}"

# The wheel bundles LLVM/MLIR and proprietary redistributable NVIDIA tools.
LICENSE="MIT Apache-2.0-with-LLVM-exceptions NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

# The wheel bundles LLVM and NVIDIA tools and has no Python runtime dependencies;
# JIT compilation uses the system driver. Building its LLVM/MLIR tree in-overlay
# is impractical, hence -bin.
# PyTorch 2.12 pairs with Triton 3.7; vllm CUDA kernels require Triton. Pairing
# verified 2026-06-15, but not yet end-to-end with vllm[cuda].

RDEPEND="!!dev-python/triton"
QA_PREBUILT="usr/lib/python3.*/site-packages/triton/*"

src_unpack() {
	# Stash per-implementation wheels for installer instead of unpacking into S.
	mkdir -p "${S}/wheel" || die
	local f
	for f in ${A}; do
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
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-${WHL_TAIL}"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
	# Drop profiler scripts that collide in /usr/bin and across implementations;
	# the profiler remains importable.
	rm -f "${D}"/usr/bin/proton "${D}"/usr/bin/proton-viewer || die
	# installer does not byte-compile.
	python_optimize
}

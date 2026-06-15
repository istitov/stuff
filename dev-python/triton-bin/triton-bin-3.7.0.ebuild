# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
# Upstream wheels are requires-python "<3.15,>=3.10"; we cover the torch
# stack's range. cp314 wheels are published from 3.5.0 onward.
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

# Triton itself is MIT. The wheel bundles LLVM/MLIR
# (Apache-2.0-with-LLVM-exceptions) and NVIDIA ptxas / cuobjdump /
# nvdisasm / cupti (proprietary, redistributable under the CUDA EULA)
# under triton/backends/nvidia.
LICENSE="MIT Apache-2.0-with-LLVM-exceptions NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

# Triton's wheel is fully self-contained: `import triton` pulls only the
# stdlib (upstream lists no runtime Requires-Dist), and it bundles its own
# LLVM and the NVIDIA ptxas toolchain, so there are no hard python
# RDEPENDs. It JIT-compiles GPU kernels at runtime against the system
# NVIDIA driver. Shipped as -bin because Triton builds from an LLVM/MLIR
# source tree that is impractical to compile in-tree; the wheel is the
# upstream-supported form (same posture as dev-python/cuda-tile-bin).
#
# Version: torch-2.12.0 pairs with triton 3.7.0 (pytorch
# .ci/docker/triton_version.txt; torch-2.11.0 paired with 3.6.0). vllm's
# CUDA kernels (slot mapping, attention, sampling, the
# torch.compile/inductor path) are @triton.jit and hard-fail without it.
# Pairing verified 2026-06-15 against pytorch v2.12.0; not yet
# end-to-end-tested with vllm[cuda] on this triton (the 3.6.0 ebuild
# carries that run for the torch-2.11 pairing).

QA_PREBUILT="usr/lib/python3.*/site-packages/triton/*"

src_unpack() {
	# distutils-r1 with DISTUTILS_USE_PEP517=no and a wheel SRC_URI would
	# try to unpack the .whl directly into S. Stash the per-impl wheels and
	# feed them to `installer` per impl below instead.
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
	# Triton ships proton/proton-viewer (its profiler) as console scripts;
	# drop them -- the generic names collide in /usr/bin (e.g. with Valve
	# Proton) and a multi-impl install would clobber the shebang anyway.
	# torch/vllm don't use them; triton.profiler.proton stays importable.
	rm -f "${D}"/usr/bin/proton "${D}"/usr/bin/proton-viewer || die
	# `installer` doesn't byte-compile; do it ourselves so portage doesn't
	# warn about missing .pyc for triton's many pure-python modules.
	python_optimize
}

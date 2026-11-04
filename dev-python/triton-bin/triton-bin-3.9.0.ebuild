# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
# Match the torch stack within upstream's >=3.11,<3.16 wheel range.
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN%-bin}
MY_BASE="https://files.pythonhosted.org/packages"
# From 3.9.0 one cp312-abi3 wheel serves every non-free-threaded CPython
# from 3.12 up, so a single distfile covers all PYTHON_TARGETS.
MY_WHL="${MY_PN}-${PV}-cp312-abi3-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"

DESCRIPTION="Triton GPU programming language and compiler (binary wheels)"
HOMEPAGE="
	https://github.com/triton-lang/triton
	https://pypi.org/project/triton/
"
SRC_URI="${MY_BASE}/3f/c9/af85b25e0d98bd921a7646ad1db1c8746250ee04b8f1595982d29b6283cf/${MY_WHL}"
S="${WORKDIR}"

# The wheel bundles LLVM/MLIR and proprietary CUDA tools under backends/nvidia.
LICENSE="MIT Apache-2.0-with-LLVM-exceptions NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

# The self-contained wheel has no Requires-Dist on Python 3.10+ and bundles
# LLVM/CUDA tools; runtime JIT uses the system NVIDIA driver. Building its
# LLVM/MLIR tree in the overlay is impractical, so use upstream's supported
# wheel.
# Track PyTorch's .ci/docker/triton_version.txt, not latest Triton:
#
#   torch 2.11.0 -> triton 3.6.0
#   torch 2.12.0 -> triton 3.7.0
#   torch 2.13.0 -> triton 3.7.1
#   torch 2.14.0 -> triton 3.8.0
#   torch 2.15.0 -> triton 3.9.0
#
# Pairing verified from release tarballs 2026-09-09 (2.12 on 2026-08-29); 2.14
# and 2.15 read from .ci/docker/triton_version.txt at their tags 2026-11-04.
# vllm 0.33.0 is the torch 2.14 consumer; ComfyUI leaves Triton unversioned.
# Bump together with dev-python/triton and the matching virtual/triton.
# vllm's JIT kernels hard-require Triton, but this pairing lacks an end-to-end
# CUDA run; only 3.6.0 with torch 2.11 is verified.

RDEPEND="!!dev-python/triton"
QA_PREBUILT="usr/lib/python3.*/site-packages/triton/*"

BDEPEND+="
	$(python_gen_cond_dep '
		dev-python/installer[${PYTHON_USEDEP}]
	')
"

src_unpack() {
	# Keep the wheel packed; installer reads it from DISTDIR per impl.
	:
}

src_install() {
	python_foreach_impl install_wheel
}

install_wheel() {
	${EPYTHON} -m installer --destdir="${D}" "${DISTDIR}/${MY_WHL}" || die
	# Drop generic, multi-impl-clobbered profiler scripts; its module remains.
	rm -f "${D}"/usr/bin/proton "${D}"/usr/bin/proton-viewer || die
	# installer does not byte-compile.
	python_optimize
}

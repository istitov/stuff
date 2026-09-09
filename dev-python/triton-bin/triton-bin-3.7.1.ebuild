# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
# Match the torch stack within upstream's >=3.10,<3.15 wheel range.
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
	python_targets_python3_12? ( ${MY_BASE}/c4/6f/fb96d15db6f36d6eae4cafb998c2e0353bf59d7c4ea1662d7497f269134a/${MY_PN}-${PV}-cp312-cp312-${WHL_TAIL} )
	python_targets_python3_13? ( ${MY_BASE}/07/42/2c3ac59253ae8892b6f307875263dd23dc875cdf732d3aea40d6d41fb7cb/${MY_PN}-${PV}-cp313-cp313-${WHL_TAIL} )
	python_targets_python3_14? ( ${MY_BASE}/a4/09/5683146fda6a2b569deb78ccfd8fbfea8bfe55f726b081c0a6bb18dd6f28/${MY_PN}-${PV}-cp314-cp314-${WHL_TAIL} )
"
S="${WORKDIR}"

# The wheel bundles LLVM/MLIR and proprietary CUDA tools under backends/nvidia.
LICENSE="MIT Apache-2.0-with-LLVM-exceptions NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

# The self-contained wheel has no Requires-Dist and bundles LLVM/CUDA tools;
# runtime JIT uses the system NVIDIA driver. Building its LLVM/MLIR tree in the
# overlay is impractical, so use upstream's supported wheel.
# Track PyTorch's .ci/docker/triton_version.txt, not latest Triton:
#
#   torch 2.11.0 -> triton 3.6.0
#   torch 2.12.0 -> triton 3.7.0
#   torch 2.13.0 -> triton 3.7.1
#   torch 2.14.0 -> triton 3.8.0
#
# Pairing verified from release tarballs 2026-09-09 (2.12 on 2026-08-29).
# vllm 0.27.1/0.28.0 pin this 2.13 pairing; ComfyUI leaves Triton unversioned.
# Do not bump 3.8 alone: it needs the matching virtual and a 2.14 consumer.
# vllm's JIT kernels hard-require Triton, but this pairing lacks an end-to-end
# CUDA run; only 3.6.0 with torch 2.11 is verified.

RDEPEND="!!dev-python/triton"
QA_PREBUILT="usr/lib/python3.*/site-packages/triton/*"

src_unpack() {
	# Prevent distutils-r1 from unpacking wheels directly into S; stage per impl.
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
	# Map EPYTHON=python3.13 to wheel tag cp313.
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-${WHL_TAIL}"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
	# Drop generic, multi-impl-clobbered profiler scripts; its module remains.
	rm -f "${D}"/usr/bin/proton "${D}"/usr/bin/proton-viewer || die
	# installer does not byte-compile.
	python_optimize
}

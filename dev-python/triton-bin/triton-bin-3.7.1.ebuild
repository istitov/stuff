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
	python_targets_python3_12? ( ${MY_BASE}/c4/6f/fb96d15db6f36d6eae4cafb998c2e0353bf59d7c4ea1662d7497f269134a/${MY_PN}-${PV}-cp312-cp312-${WHL_TAIL} )
	python_targets_python3_13? ( ${MY_BASE}/07/42/2c3ac59253ae8892b6f307875263dd23dc875cdf732d3aea40d6d41fb7cb/${MY_PN}-${PV}-cp313-cp313-${WHL_TAIL} )
	python_targets_python3_14? ( ${MY_BASE}/a4/09/5683146fda6a2b569deb78ccfd8fbfea8bfe55f726b081c0a6bb18dd6f28/${MY_PN}-${PV}-cp314-cp314-${WHL_TAIL} )
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
# Version: this tracks pytorch's .ci/docker/triton_version.txt, NOT the
# newest triton release. The mapping (2.11.0, 2.13.0 and 2.14.0 read from
# the release tarballs 2026-09-09; 2.12.0 from the 2026-08-29 pass):
#
#   torch 2.11.0 -> triton 3.6.0
#   torch 2.12.0 -> triton 3.7.0
#   torch 2.13.0 -> triton 3.7.1
#   torch 2.14.0 -> triton 3.8.0
#
# 3.7.1 is the pairing for the torch 2.13.0 line, which is what vllm
# 0.27.1 and 0.28.0 pin. comfyui does not pin a torch at all -- it depends
# on caffe2 and torchvision unversioned -- so it takes an unversioned
# virtual/triton and enforces no pairing of its own.
# triton 3.8.0 is released upstream and shows as drift on
# every nvchecker run, but it is not a standalone drift fix: it belongs to
# the torch 2.14.0 line, which entered the tree on 2026-09-03 and so far
# carries only torchvision-0.29.0. Landing it needs a virtual/triton-3.8.0
# as well, since every consumer goes through the virtual, and a consumer on
# the 2.14 line that actually wants Triton. Bump it inside a torch bump,
# never on its own.
#
# vllm's CUDA kernels (slot mapping, attention, sampling, the
# torch.compile/inductor path) are @triton.jit and hard-fail without it.
# This wheel has had no end-to-end vllm[cuda] run: the run on record is on
# the 3.6.0 ebuild, for the torch-2.11 pairing, and that gap now matters
# because vllm pins this version rather than 3.6.0. (An earlier note here
# claimed a 2026-06-15 verification against pytorch v2.12.0, which cannot
# apply to this ebuild -- 2.12.0 pairs with 3.7.0, per the table above.)

RDEPEND="!!dev-python/triton"
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

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN//-/_}
MY_WHEEL="${MY_PN}-${PV}-py3-none-any.whl"

DESCRIPTION="NVIDIA CUTLASS Python DSL — arch-agnostic core Python package"
HOMEPAGE="
	https://github.com/NVIDIA/cutlass
	https://pypi.org/project/nvidia-cutlass-dsl-libs-core/
"
SRC_URI="
	https://files.pythonhosted.org/packages/c7/b2/5984ad95ec71eeaf634f81b36691f6f9cdfebb46f92828b851f89039ae5a/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
# NVIDIA-CUDA is an EULA license; distfiles must not be mirrored,
# binpkgs must not be redistributed.
RESTRICT="bindist mirror"

# New sibling in 4.6.0: NVIDIA split the pure-Python cutlass DSL core
# (nvidia_cutlass_dsl/dsl_packages/cutlass/...) out of libs-base into
# this arch-agnostic wheel. libs-base now carries only the _mlir/iket
# generated bits and libs-cu13 only the CUDA-13 runtime; all three file
# sets are disjoint (0 overlap).
#
# Upstream also declares protobuf<7,>=6.30.2, but this wheel carries no
# *_pb2 module and no google.protobuf reference anywhere in its payload;
# the only consumer is the iket perfetto profiler, whose
# perfetto_trace_pb2.py ships in libs-base instead. Declaring it would
# also evict the installed protobuf rather than slot alongside it -
# dev-python/protobuf keeps every version in main slot 0, so a <7 atom
# forces a system-wide 7->6 downgrade onto every protobuf-7 consumer.
# Omitted deliberately. nvidia-cuda-nvdisasm (core DSL compiler —
# base_dsl/compiler.py) is provided by the CUDA toolkit.
# # verified 2026-07-14, wheel payload re-checked 2026-07-27 against 4.6.1.
RDEPEND="
	dev-python/cuda-python[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	>=dev-util/nvidia-cuda-toolkit-13.3
"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

src_install() {
	python_foreach_impl install_wheel
}

install_wheel() {
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die
}

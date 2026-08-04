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

LICENSE="NVIDIA-CUTLASS"
SLOT="0"
KEYWORDS="-* ~amd64"
# The CUTLASS EULA restricts redistribution.
RESTRICT="bindist mirror"

# New sibling in 4.6.0: NVIDIA split the pure-Python cutlass DSL core
# (nvidia_cutlass_dsl/dsl_packages/cutlass/...) out of libs-base into
# this arch-agnostic wheel. libs-base now carries only the _mlir/iket
# generated bits and libs-cu13 only the CUDA-13 runtime; all three file
# sets are disjoint (0 overlap).
#
# Upstream duplicates its protobuf metadata here, but this payload has no
# protobuf importer; libs-base owns that dependency. The nvdisasm lookup is
# patched to accept the system CUDA toolkit instead of requiring a PyPI wheel.
# # verified 2026-08-04 against 4.6.1.
RDEPEND="
	>=dev-python/cuda-python-12.8[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.10.0[${PYTHON_USEDEP}]
	>=dev-util/nvidia-cuda-toolkit-13.3
	<dev-util/nvidia-cuda-toolkit-14
"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die

	local sp="${D}$(${EPYTHON} -c 'import sysconfig; print(sysconfig.get_path("purelib"))')"
	pushd "${sp}/nvidia_cutlass_dsl" >/dev/null || die
	eapply "${FILESDIR}/${PN}-4.6-system-nvdisasm.patch"
	popd >/dev/null || die
	python_optimize
}

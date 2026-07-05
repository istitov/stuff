# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_WHEEL="${PN//-/_}-${PV}-py3-none-any.whl"

DESCRIPTION="NVIDIA CUTLASS Python DSL — metapackage for libs-base + libs-cu13"
HOMEPAGE="
	https://github.com/NVIDIA/cutlass
	https://docs.nvidia.com/cutlass/
	https://pypi.org/project/nvidia-cutlass-dsl/
"
SRC_URI="
	https://files.pythonhosted.org/packages/8b/1c/fbddb760a0228df87a9e9d1e60b76ecbe6e18035f5853efe0b4563651b2b/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

# Trivial metapackage: empty py3-none-any wheel that just pulls libs-base
# and (via the cu13 extra) libs-cu13. No PyPI source release — cutlass-dsl
# ships a PyPI-only metawheel from NVIDIA/cutlass — so packaging the wheel
# directly is byte-equivalent to an empty source.
#
# Always the cu13 path (amd64 + CUDA 13.2 at /opt/cuda); cu12 would need a
# libs-cu12 sibling we haven't packaged. Add a USE flag if a cu12 user emerges.
RDEPEND="
	~dev-python/nvidia-cutlass-dsl-libs-base-${PV}[${PYTHON_USEDEP}]
	~dev-python/nvidia-cutlass-dsl-libs-cu13-${PV}[${PYTHON_USEDEP}]
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

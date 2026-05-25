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
	https://files.pythonhosted.org/packages/f0/15/575d7df4fe2f3406f1cfc68be72aeff2834f8a696daf1cd5bee8017e4507/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

# Trivial metapackage — empty py3-none-any wheel whose entire purpose
# is to pull libs-base and (under the cu13 extra) libs-cu13. No source
# release on PyPI; the GitHub monorepo cuda-python doesn't carry this
# subdir either since cutlass-dsl lives at NVIDIA/cutlass with its own
# release cadence and PyPI-only metawheel. Packaging the wheel
# directly is byte-equivalent to a hypothetical empty source.
#
# This overlay always pulls the cu13 path: amd64 + CUDA 13.2 at
# /opt/cuda. cu12 would need its own libs-cu12 sibling which we
# haven't packaged. Add a USE flag if a cu12 user emerges.
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

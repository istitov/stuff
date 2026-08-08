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
	https://files.pythonhosted.org/packages/b2/ec/14e6ecbfed31ec35bbd1bb6965ae61f879370906a8f9c2e851e292704ba4/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUTLASS"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

# This wheel ships nvidia_cutlass_dsl_packages.pth plus metadata. Upstream
# defaults to libs-base + libs-cu12 and exposes libs-cu13 as an extra; replace
# the unavailable cu12 backend with cu13 because this overlay packages CUDA 13.
RDEPEND="
	~dev-python/nvidia-cutlass-dsl-libs-base-${PV}[${PYTHON_USEDEP}]
	~dev-python/nvidia-cutlass-dsl-libs-cu13-${PV}[${PYTHON_USEDEP}]
"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die
}

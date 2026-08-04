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

LICENSE="NVIDIA-CUTLASS"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

# Metadata-only wheel with no payload files. Upstream requires libs-base and
# exposes libs-cu13 as an extra; select that extra directly because this overlay
# packages only the CUDA 13 backend.
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

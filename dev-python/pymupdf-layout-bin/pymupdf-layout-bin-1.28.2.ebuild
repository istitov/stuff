# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

AMD64_WHEEL="pymupdf_layout-${PV}-cp310-abi3-manylinux_2_28_x86_64.whl"
ARM64_WHEEL="pymupdf_layout-${PV}-cp310-abi3-manylinux_2_28_aarch64.whl"

case ${ARCH} in
	amd64) MY_WHEEL=${AMD64_WHEEL} ;;
	arm64) MY_WHEEL=${ARM64_WHEEL} ;;
esac

DESCRIPTION="PyMuPDF document-layout analysis extension (binary wheel)"
HOMEPAGE="
	https://pymupdf.readthedocs.io/en/latest/pymupdf-layout/
	https://github.com/ArtifexSoftware/pymupdf_layout
	https://pypi.org/project/pymupdf-layout/
"
SRC_URI="
	amd64? ( https://files.pythonhosted.org/packages/03/65/6b92d25678c64839fb2066ee98d6d1f164d820ba045d83c77e79021cda98/${AMD64_WHEEL} )
	arm64? ( https://files.pythonhosted.org/packages/75/82/6cbf0331e148db48bf609c165dbe900cf3c1158546c5d09d4ad7fd4d6b17/${ARM64_WHEEL} )
"
S="${WORKDIR}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	~dev-python/PyMuPDF-${PV}[${PYTHON_USEDEP}]
	~dev-python/mupdf-${PV}:=[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	sci-libs/onnxruntime[python,${PYTHON_USEDEP}]
	dev-python/networkx[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-util/patchelf
	dev-python/installer[${PYTHON_USEDEP}]
"

QA_PREBUILT="
	usr/lib/python3.*/site-packages/pymupdf/_features.so
	usr/lib/python3.*/site-packages/pymupdf/_tgif.so
"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die

	# The wheel expects the MuPDF libraries bundled beside the upstream
	# PyMuPDF wheel.  Link to our exact-version source-built libraries instead.
	local mod
	for mod in _features.so _tgif.so; do
		patchelf --replace-needed "libmupdf.so.${PV#1.}" \
			"libmupdf.so.${PV}" "${D}$(python_get_sitedir)/pymupdf/${mod}" || die
		patchelf --replace-needed "libmupdfcpp.so.${PV#1.}" \
			"libmupdfcpp.so.${PV}" "${D}$(python_get_sitedir)/pymupdf/${mod}" || die
	done
	python_optimize
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
# Python 3.15 remains unkeyworded in ::gentoo (verified 2026-08-04).
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# Translate Gentoo's _pN suffix back to PyPI's .postN for upstream
# wheel filenames; Gentoo's PMS version syntax forbids ".postN".
MY_PV="${PV/_p/.post}"
MY_WHEEL="${PN//-/_}-${MY_PV}-py3-none-any.whl"

DESCRIPTION="Pre-compiled cubins for FlashInfer kernels"
HOMEPAGE="
	https://github.com/flashinfer-ai/flashinfer
	https://pypi.org/project/flashinfer-cubin/
"
SRC_URI="
	https://files.pythonhosted.org/packages/29/96/da75a9f61c64c87b16baa339fc8216a6c3743c5d263c555fded30fcbe6f7/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

# The binary wheel has no license payload or reproducible source mapping.
# Its metadata claims Apache-2.0, but the pre-compiled artifacts come from
# NVIDIA's artifactory, so retain the conservative redistribution policy.
# Imported as a dependency-free runtime sidecar by flashinfer-python.
# verified 2026-08-04 against 0.6.11.post2.

BDEPEND+="
	$(python_gen_cond_dep '
		dev-python/installer[${PYTHON_USEDEP}]
	')
"

QA_PREBUILT="usr/lib/python3.*/site-packages/flashinfer_cubin/*"

src_unpack() {
	:
}

python_install() {
	${EPYTHON} -m installer --destdir="${D}" \
		"${DISTDIR}/${MY_WHEEL}" || die
	python_optimize
}

pkg_postinst() {
	ewarn "The upstream wheel omits the optional host-native CuTe DSL FMHA"
	ewarn "libraries listed in its manifests. That backend is not provided by"
	ewarn "this package and may attempt an unsupported runtime download."
}

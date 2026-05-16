# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# Translate Gentoo's _p1 suffix back to PyPI's .post1 for upstream
# wheel filenames; Gentoo's PMS version syntax forbids ".postN".
MY_PV="${PV/_p/.post}"
MY_WHEEL="${PN//-/_}-${MY_PV}-py3-none-any.whl"

DESCRIPTION="Pre-compiled cubins for FlashInfer kernels"
HOMEPAGE="
	https://github.com/flashinfer-ai/flashinfer
	https://pypi.org/project/flashinfer-cubin/
"
SRC_URI="
	https://files.pythonhosted.org/packages/d8/8a/f63d89bfdb20848d4403da73892a4b55ec6bcc4fdfb7a8d90a0ce4d5f5a3/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

# Pre-compiled cubins shipped only as a binary wheel — no upstream
# source release. Imported as a runtime sidecar by flashinfer-python.
# Has no Python-level dependencies. # verified 2026-05-07 against 0.6.8.post1.

QA_PREBUILT="usr/lib/python3.*/site-packages/flashinfer_cubin/*"

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

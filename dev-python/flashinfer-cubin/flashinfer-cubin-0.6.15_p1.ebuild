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
# 0.6.15.post1 is not on PyPI (the cubin package lags flashinfer-python);
# the wheel ships as a GitHub release asset on the main flashinfer repo.
# The Manifest hash is the load-bearing pin regardless of fetch host.
SRC_URI="
	https://github.com/flashinfer-ai/flashinfer/releases/download/v${MY_PV}/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

# Pre-compiled cubins shipped only as a binary wheel — no upstream
# source release. Imported as a runtime sidecar by flashinfer-python.
# Has no Python-level dependencies. # verified 2026-06-25 against 0.6.13.

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

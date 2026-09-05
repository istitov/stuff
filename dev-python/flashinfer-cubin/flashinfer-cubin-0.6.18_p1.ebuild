# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
# Python 3.15 remains unkeyworded in ::gentoo: the only 3.15 ebuild is
# dev-lang/python-0.3.15.0_rc1-r1 and it carries no KEYWORDS line at all, so
# pkgcheck's PythonCompatUpdate here is a false lead. verified 2026-08-29.
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
# 0.6.16.post3 is not on PyPI (the cubin package lags flashinfer-python);
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

# The binary wheel has no license payload or reproducible source mapping.
# Its metadata claims Apache-2.0, but the pre-compiled artifacts come from
# NVIDIA's artifactory, so retain the conservative redistribution policy.
# Imported as a dependency-free runtime sidecar by flashinfer-python.
# verified 2026-08-08 against 0.6.16.post3.

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

python_install_all() {
	# Upstream packaged one empty download lock beside every artifact.  These
	# are cache residue, not runtime data; remove them and their stale RECORD
	# entries rather than consuming more than sixteen thousand inodes.
	find "${ED}" -type f -name '*.lock' -delete || die
	local record
	for record in "${ED}"/usr/lib/python*/site-packages/*.dist-info/RECORD; do
		[[ -f ${record} ]] || continue
		sed -e '/\.lock,/d' -i "${record}" || die
	done
}

pkg_postinst() {
	ewarn "The upstream wheel omits the optional host-native CuTe DSL FMHA"
	ewarn "libraries listed in its manifests. That backend is not provided by"
	ewarn "this package and may attempt an unsupported runtime download."
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
# Python 3.15 remains unkeyworded in ::gentoo; defer pkgcheck's suggestion.
# rechecked 2026-09-10
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# Map Gentoo's _pN suffix to the wheel's .postN.
MY_PV="${PV/_p/.post}"
MY_WHEEL="${PN//-/_}-${MY_PV}-py3-none-any.whl"

DESCRIPTION="Pre-compiled cubins for FlashInfer kernels"
HOMEPAGE="
	https://github.com/flashinfer-ai/flashinfer
	https://pypi.org/project/flashinfer-cubin/
"
# Versions after 0.6.13 are GitHub-only release wheels. rechecked 2026-09-10
SRC_URI="
	https://github.com/flashinfer-ai/flashinfer/releases/download/v${MY_PV}/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

# The wheel has no license files or reproducible source mapping. Its metadata
# says Apache-2.0, but the cubins originate from NVIDIA's artifactory; retain
# conservative redistribution restrictions.

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
	# Drop over 16,000 empty cache locks and their stale RECORD entries.
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

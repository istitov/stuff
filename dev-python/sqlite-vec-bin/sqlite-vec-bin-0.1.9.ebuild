# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_WHEEL_AMD64="sqlite_vec-${PV}-py3-none-manylinux_2_17_x86_64.manylinux2014_x86_64.manylinux1_x86_64.whl"
MY_WHEEL_ARM64="sqlite_vec-${PV}-py3-none-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"

DESCRIPTION="SQLite vector search extension (binary wheel)"
HOMEPAGE="https://pypi.org/project/sqlite-vec/"
SRC_URI="
	amd64? (
		https://files.pythonhosted.org/packages/6f/ad/6afd073b0f817b3e03f9e37ad626ae341805891f23c74b5292818f49ac63/${MY_WHEEL_AMD64}
	)
	arm64? (
		https://files.pythonhosted.org/packages/00/d4/f2b936d3bdc38eadcbd2a87875815db36430fab0363182ba5d12cd8e0b51/${MY_WHEEL_ARM64}
	)
"
S="${WORKDIR}"

LICENSE="MIT Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

BDEPEND="
	dev-python/installer[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3.*/site-packages/sqlite_vec/vec0.so"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	local f
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

python_install() {
	local wheels=( "${S}"/wheel/*.whl )
	[[ ${#wheels[@]} -eq 1 && -f ${wheels[0]} ]] ||
		die "expected exactly one wheel"
	${EPYTHON} -m installer --destdir="${D}" "${wheels[0]}" || die
	python_optimize
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 flag-o-matic

MY_PV=${PV/_p/-r}
MY_P=${PN}-${MY_PV}

DESCRIPTION="APSW - Another Python SQLite Wrapper"
HOMEPAGE="https://github.com/rogerbinns/apsw/"
SRC_URI="https://github.com/rogerbinns/apsw/releases/download/${MY_PV}/${MY_P}.zip"

S=${WORKDIR}/${MY_P}

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="doc"

# apsw's PV is <sqlite-version>.<apsw-revision> (e.g. 3.53.1.0 = first
# apsw release tracking sqlite 3.53.1). Strip the trailing apsw-rev to
# get the matching sqlite floor; ::gentoo ships sqlite as 3.53.1
# (no trailing .0).
RDEPEND=">=dev-db/sqlite-${PV%.*}"
DEPEND="${RDEPEND}
	app-arch/unzip"

python_compile() {
	python_is_python3 || append-cflags -fno-strict-aliasing
	distutils-r1_python_compile --enable=load_extension
}

python_test() {
	"${PYTHON}" setup.py build_test_extension || die "Building of test loadable extension failed"
	"${PYTHON}" tests.py -v || die "Tests failed under ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/. )
	distutils-r1_python_install_all
}

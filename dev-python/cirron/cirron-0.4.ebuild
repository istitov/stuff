# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

# upstream sdist uses uppercase project name (Cirron-0.4.tar.gz)
PYPI_PN="Cirron"
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi toolchain-funcs

DESCRIPTION="Measure CPU instructions / branch misses / page faults of Python code"
HOMEPAGE="
	https://github.com/s7nfo/Cirron
	https://pypi.org/project/Cirron/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# strace is invoked at runtime by the optional Tracer; perf_event_open is
# kernel-side and always available on stock Gentoo.
RDEPEND="dev-debug/strace"

src_prepare() {
	# Upstream lazily compiles cirronlib.cpp at first import, writing into
	# its own site-packages dir — that fails as a normal user on a
	# system-wide Gentoo install. Pre-build the .so during src_compile and
	# add it to package_data so it ships pre-baked.
	sed -i \
		-e 's|"cirronlib.cpp",|"cirronlib.cpp", "cirronlib.so",|' \
		setup.py || die
	distutils-r1_src_prepare
}

src_compile() {
	$(tc-getCXX) ${CXXFLAGS} ${LDFLAGS} -shared -fPIC \
		-o cirron/cirronlib.so cirron/cirronlib.cpp || die "C++ compile failed"
	distutils-r1_src_compile
}

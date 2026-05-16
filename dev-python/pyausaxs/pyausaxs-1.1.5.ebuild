# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-r1

DESCRIPTION="Python wrapper around the AUSAXS C++ SAXS library"
HOMEPAGE="
	https://github.com/AUSAXS/pyAUSAXS
	https://pypi.org/project/pyausaxs/
"
# Upstream publishes only wheels; install the manylinux one verbatim,
# including the bundled prebuilt libausaxs.so it ships in
# pyausaxs/resources/. See the RDEPEND blocker below for background.
SRC_URI="
	https://files.pythonhosted.org/packages/e5/e0/e97075abe1525e0b67b68827f35f9eb501f1ec33c7670feaf071ed92ebeb/${P}-py3-none-manylinux2014_x86_64.whl
"
S="${WORKDIR}"

LICENSE="LGPL-3+"
SLOT="0"
# x86 not supported; wheel is manylinux2014_x86_64.
KEYWORDS="~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Coexists with sci-libs/ausaxs.  pyausaxs.loader.find_lib_path()
# always returns the bundled .so via an absolute pkg_resources path
# (verified 2026-05-16 against 1.1.{3,4,5} — identical loader.py),
# and ctypes.CDLL with an absolute path doesn't consult ldconfig, so
# sci-libs/ausaxs's /usr/lib64/libausaxs.so is invisible at runtime.
# Empirically tested: with /usr/lib64/libausaxs.so staged from a
# from-source 1.2.3 build, all six ctypes-wired symbols
# (test_integration, evaluate_sans_debye, fit_saxs, iterative_fit_
# {start,step,finish}) still resolved from the bundled copy and
# `debye_no_ff` (only in the system .so) remained absent — proving
# the bundled .so is the one loaded.  The historical blocker (which
# was correct for 1.0.4's now-discontinued loader behavior) is no
# longer load-bearing at 1.1.x.
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/py-cpuinfo-8.0.0[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.20.0[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.10[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.7[${PYTHON_USEDEP}]
"
BDEPEND="app-arch/unzip"

src_unpack() {
	unzip -q "${DISTDIR}/${P}-py3-none-manylinux2014_x86_64.whl" -d "${S}" || die
}

_install_one() {
	python_domodule pyausaxs

	# Ship the .dist-info so importlib.metadata.version("pyausaxs")
	# and pip's view of the installed packages match upstream.
	local distinfo="${P/-/_}.dist-info"
	if [[ -d ${distinfo} ]]; then
		local sitedir
		sitedir=$(python_get_sitedir)
		mkdir -p "${D}${sitedir}" || die
		cp -r "${distinfo}" "${D}${sitedir}/" || die
	fi
}

src_install() {
	python_foreach_impl _install_one
}

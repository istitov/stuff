# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit optfeature python-r1

DESCRIPTION="Python wrapper around the AUSAXS C++ SAXS library"
HOMEPAGE="
	https://github.com/AUSAXS/pyAUSAXS
	https://pypi.org/project/pyausaxs/
"
# Upstream publishes only wheels; install the manylinux one verbatim,
# including the bundled prebuilt libausaxs.so it ships in
# pyausaxs/resources/. See the RDEPEND blocker below for background.
SRC_URI="
	https://files.pythonhosted.org/packages/a0/ca/0e6d40ff62bcc8b3cdc91503df83479d637d7cc04c345c3338288e96b389/${P}-py3-none-manylinux2014_x86_64.whl
"
S="${WORKDIR}"

LICENSE="LGPL-3+"
SLOT="0"
# x86 not supported; wheel is manylinux2014_x86_64.
KEYWORDS="~amd64 ~arm64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Coexists with sci-libs/ausaxs.  By default pyausaxs.loader.find_lib_path()
# returns the bundled .so via an absolute importlib.resources path, and
# ctypes.CDLL with an absolute path doesn't consult ldconfig, so
# sci-libs/ausaxs's /usr/lib64/libausaxs.so stays invisible at runtime
# unless the user opts in.  loader.py was byte-identical across
# 1.1.{3,4,5,6}; 1.1.7 rewrote it and 1.2.0 keeps that shape unchanged
# (verified 2026-07-28): find_lib_path() first consults a relink cache
# file (get_relink_path()) and only falls back to bundled_lib_path() when
# none is set, and set_relink_path() lets a user persist a custom backend
# path (e.g. the system .so) that then wins.  So the system library *can*
# be selected explicitly, but never by default — no relink cache ships in
# the wheel.
# Empirically tested 2026-05-16: with /usr/lib64/libausaxs.so staged from
# a from-source 1.2.3 build and no relink configured, all six ctypes-wired
# symbols (test_integration, evaluate_sans_debye, fit_saxs, iterative_fit_
# {start,step,finish}) resolved from the bundled copy and `debye_no_ff`
# (only in the system .so) remained absent — proving the bundled .so is
# the one loaded.
# 1.2.0 moved matplotlib and scipy out of the base requirements into a
# "plots" extra; both are imported lazily (matplotlib inside FitResult's
# plotting methods behind an importlib.util.find_spec guard that raises a
# clear ImportError, scipy inside plot/plot_helper), so `import pyausaxs`
# and the whole ctypes API need only numpy + py-cpuinfo. They are
# advertised via optfeature instead of hard-depended. The "gui" extra's
# tkinterdnd2 is unpackaged, so that path stays unavailable. verified
# 2026-07-28
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/py-cpuinfo-8.0.0[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.20.0[${PYTHON_USEDEP}]
"
BDEPEND="app-arch/unzip"

src_unpack() {
	unzip -q "${DISTDIR}/${P}-py3-none-manylinux2014_x86_64.whl" -d "${S}" || die
}

_install_one() {
	python_domodule pyausaxs

	# Ship the .dist-info so importlib.metadata.version("pyausaxs")
	# and pip's view of the installed packages match upstream. The wheel
	# names it "${P}.dist-info" (a literal hyphen before the version, per
	# the wheel spec — "pyausaxs" needs no name normalisation), so use
	# ${P} directly; the historical ${P/-/_} mangled the name-version
	# separator and silently skipped the copy. verified 2026-06-10
	local distinfo="${P}.dist-info"
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

pkg_postinst() {
	optfeature "plotting fit results" dev-python/matplotlib
	optfeature "curve-fit helpers in the plotting module" dev-python/scipy
}

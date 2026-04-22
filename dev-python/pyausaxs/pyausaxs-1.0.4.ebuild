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
	https://files.pythonhosted.org/packages/ab/6d/816ede4a9ce2c9f7c233f524e350d148d43dcc939dea3eb07e48013de340/${P}-py3-none-manylinux2014_x86_64.whl
"
S="${WORKDIR}"

LICENSE="LGPL-3+"
SLOT="0"
# x86 not supported; wheel is manylinux2014_x86_64.
KEYWORDS="~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Blocker on sci-libs/ausaxs:
#
# pyausaxs 1.0.4 ships a prebuilt libausaxs.so inside its wheel that
# exposes test_integration, evaluate_sans_debye, fit_saxs,
# iterative_fit_start/step/finish as extern "C" symbols. As of AUSAXS
# v1.2.1 the public source tree only exposes test_integration and
# debye_no_ff (the others are either commented out or renamed), so a
# from-source libausaxs.so built from sci-libs/ausaxs cannot satisfy
# pyausaxs 1.0.4's ctypes lookups, which fail the whole init and
# force SasView onto its pure-Python fallback. Keep the two packages
# mutually exclusive until upstream re-aligns the C API or a newer
# pyausaxs is packaged.
RDEPEND="
	${PYTHON_DEPS}
	!sci-libs/ausaxs
	dev-python/py-cpuinfo[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
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

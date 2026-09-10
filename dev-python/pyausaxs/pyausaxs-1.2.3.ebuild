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
# Upstream publishes only wheels; install the x86-64 wheel with its bundled
# libausaxs.so.
SRC_URI="
	https://files.pythonhosted.org/packages/a0/ca/0e6d40ff62bcc8b3cdc91503df83479d637d7cc04c345c3338288e96b389/${P}-py3-none-manylinux2014_x86_64.whl
"
S="${WORKDIR}"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# The loader selects its bundled library by absolute path unless the user creates
# a relink cache, so sci-libs/ausaxs coexists and is ignored by default.
# verified 2026-05-16 and 2026-07-28
# matplotlib/scipy are lazy "plots" imports; tkinterdnd2 for the "gui" extra is
# unpackaged. Advertise the plotting stack via optfeature. # verified 2026-07-28
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

	# Keep dist-info for importlib.metadata; ${P/-/_} would corrupt the wheel's
	# literal name-version separator. # verified 2026-06-10
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

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Simple and tiny yield-based trampoline implementation"
HOMEPAGE="
	https://gitlab.com/ferreum/trampoline
	https://pypi.org/project/trampoline/
"
# Upstream provides only a universal wheel and no release tags; install it directly.
SRC_URI="$(pypi_wheel_url "${PN}")"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="dev-python/installer[${PYTHON_USEDEP}]"

src_unpack() {
	# Keep the wheel intact for per-implementation installer calls.
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

src_install() {
	python_foreach_impl install_wheel
}

install_wheel() {
	${EPYTHON} -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}

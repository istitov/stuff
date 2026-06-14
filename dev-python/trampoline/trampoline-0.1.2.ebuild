# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Simple and tiny yield-based trampoline implementation"
HOMEPAGE="
	https://gitlab.com/ferreum/trampoline
	https://pypi.org/project/trampoline/
"
# Upstream publishes no sdist -- only a pure-python py3-none-any wheel -- and
# the GitLab repo carries no release tags, so install the wheel directly.
SRC_URI="$(pypi_wheel_url "${PN}")"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

src_unpack() {
	# A PEP517=no distutils-r1 would try to build from the wheel; stash it
	# and feed it to `installer` per impl instead.
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

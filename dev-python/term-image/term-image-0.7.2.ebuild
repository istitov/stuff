# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Display images in the terminal — sixel, kitty, iTerm2, block-art"
HOMEPAGE="
	https://github.com/AnonymouX47/term-image
	https://pypi.org/project/term-image/
"
SRC_URI="https://github.com/AnonymouX47/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Tests require a TTY with kitty, iTerm2, and Sixel protocols.
RESTRICT="test"

# Relax Dependabot's Pillow <11 cap; all used APIs work with in-tree 12.2.0.
# Main has updated the cap but has no newer release. verified 2026-05-09
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/pillow-9.1[${PYTHON_USEDEP}]
	>=dev-python/requests-2.23[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

src_prepare() {
	sed -i 's/"pillow>=9\.1,<11"/"pillow>=9.1"/' setup.py || die
	distutils-r1_src_prepare
}

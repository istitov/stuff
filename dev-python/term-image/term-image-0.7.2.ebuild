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

# Tests need a TTY that supports the various graphics protocols (kitty,
# iterm2, sixel) and aren't sandbox-friendly. Skip until someone wants
# a sub-suite split.
RESTRICT="test"

# Upstream setup.py pins pillow<11. The cap is auto-bumped via Dependabot
# per the commit log ("deps: Bump pillow from 10.4.0 to 11.1.0" #157),
# not a knowledge claim. Empirically verified 2026-05-09 against in-tree
# pillow-12.2.0: every Pillow API term-image actually uses (Image.open,
# Image.frombytes, UnidentifiedImageError, mode/size/format/info/n_frames/
# is_animated attrs, tobytes/save/seek methods) works unchanged. Sed the
# cap rather than wait for upstream's next release — last tag is
# 2024-09-15; main has pillow<12 + py3.13 since 2025-04-04 but no new
# tagged release. typing_extensions added on main only, not v0.7.2.
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/pillow-9.1[${PYTHON_USEDEP}]
	>=dev-python/requests-2.23[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

src_prepare() {
	# verified 2026-05-09: cap is unfounded, see comment above RDEPEND.
	sed -i 's/"pillow>=9\.1,<11"/"pillow>=9.1"/' setup.py || die
	distutils-r1_src_prepare
}

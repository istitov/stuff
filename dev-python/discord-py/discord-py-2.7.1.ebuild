# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_PN="discord.py"
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="A Python wrapper for the Discord API"
HOMEPAGE="
	https://github.com/Rapptz/discord.py
	https://pypi.org/project/discord.py/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# discord/player.py imports audioop at package import time, which left the
# standard library in Python 3.13. The voice extra is not provided: it caps
# PyNaCl below 1.6, older than ::gentoo's, and needs the unpackaged davey;
# both imports are guarded, so only voice channels go without them.
# verified 2026-11-17
RDEPEND="
	>=dev-python/aiohttp-3.7.4[${PYTHON_USEDEP}]
	<dev-python/aiohttp-4[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/audioop-lts[${PYTHON_USEDEP}]
	' 3.13 3.14)
"

EPYTEST_PLUGINS=( pytest-asyncio pytest-mock )
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare
	# tests/test_files.py attaches the checkout's .gitignore, which the sdist
	# omits; with it, all 282 tests pass. verified 2026-11-17
	use test && { touch .gitignore || die; }
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Generates memoizing PEG/Packrat parsers in Python from an EBNF grammar"
HOMEPAGE="
	https://github.com/neogeny/TatSu
	https://pypi.org/project/TatSu-LTS/
"

LICENSE="BSD-4"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The core parser has no runtime dependencies; colorama and rich are extras.

EPYTEST_PLUGINS=()

distutils_enable_tests pytest

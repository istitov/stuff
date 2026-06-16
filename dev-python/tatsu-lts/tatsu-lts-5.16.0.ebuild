# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Generates memoizing PEG/Packrat parsers in Python from an EBNF grammar"
HOMEPAGE="
	https://github.com/neogeny/TatSu
	https://pypi.org/project/TatSu-LTS/
"

LICENSE="BSD-4"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream declares dependencies = []; colorama (colorized output) and
# rich (the optional parproc submodule) are extras only, and the core
# parser — all beanquery needs — imports neither.

# Stock pytest only; no third-party plugins.
EPYTEST_PLUGINS=()

distutils_enable_tests pytest

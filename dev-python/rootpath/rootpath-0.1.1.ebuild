# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Detect/retrieve the root path of the current project"
HOMEPAGE="
	https://github.com/grimen/python-rootpath
	https://pypi.org/project/rootpath/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Upstream's requires_dist over-declares its test toolchain (tox/coverage/
# deepdiff/...); the runtime module only needs six. verified 2026-06-16.
RDEPEND="dev-python/six[${PYTHON_USEDEP}]"

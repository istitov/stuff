# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Backport of PEP 604/585 typing evaluation to older Python versions"
HOMEPAGE="
	https://github.com/alexmojaki/eval_type_backport
	https://pypi.org/project/eval-type-backport/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

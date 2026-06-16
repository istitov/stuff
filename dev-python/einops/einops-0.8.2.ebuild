# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Flexible and powerful tensor operations for readable code"
HOMEPAGE="
	https://github.com/arogozhnikov/einops
	https://pypi.org/project/einops/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python library for type checking / type conversion"
HOMEPAGE="
	https://github.com/thombashi/typepy
	https://pypi.org/project/typepy/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# Make the widely used datetime extra unconditional. Version 2 drops pytz for
# zoneinfo; upstream's tzdata dependency is Windows-only. verified 2026-07-27
RDEPEND="
	dev-python/mbstrdecoder[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

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

# typepy[datetime] extra is what every dependent package actually wants;
# wire its deps unconditionally. 2.0.0 dropped pytz for stdlib zoneinfo -
# it is absent from requires_dist and the installed tree imports it nowhere -
# so unlike 1.3.5 the extra is just python-dateutil + packaging. tzdata is
# win32-only upstream and does not apply here. verified 2026-07-27
RDEPEND="
	dev-python/mbstrdecoder[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

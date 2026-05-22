# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Socket.IO realtime client and server for Python"
HOMEPAGE="
	https://github.com/miguelgrinberg/python-socketio
	https://pypi.org/project/python-socketio/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/bidict-0.21.0[${PYTHON_USEDEP}]
	>=dev-python/python-engineio-4.11.0[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

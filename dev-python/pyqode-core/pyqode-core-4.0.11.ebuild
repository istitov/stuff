# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN="pyqode.core"

DESCRIPTION="Core framework for pyqode - Qt source-code editor widget"
HOMEPAGE="
	https://github.com/pyQode/pyqode.core/
	https://pypi.org/project/pyqode.core/
"
# PyPI dash-normalized this legacy sdist's filename.
SRC_URI="
	https://files.pythonhosted.org/packages/3c/ee/d0c56ae99c5ba1a44b566227798abedaa893c898b4b197af6993952eacd6/${PN}-${PV}.tar.gz
"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# Upstream retains future for Python 2 compatibility, but no runtime imports
# remain.
RDEPEND="
	dev-python/qtawesome[${PYTHON_USEDEP}]
	dev-python/pathspec[${PYTHON_USEDEP}]
"

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python wrapper around the PubChem PUG REST API"
HOMEPAGE="
	https://github.com/mcs07/PubChemPy
	https://pypi.org/project/PubChemPy/
	https://docs.pubchempy.org
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
# Tests hit pubchem.ncbi.nlm.nih.gov; not runnable offline.
RESTRICT="test"

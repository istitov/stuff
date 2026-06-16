# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# Github tarball loses .git/ — setuptools-scm needs the version via env.
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_LANGCODES="${PV}"

BDEPEND="dev-python/setuptools-scm[${PYTHON_USEDEP}]"

DESCRIPTION="Tools for language codes (BCP 47, IETF / RFC 5646)"
HOMEPAGE="
	https://github.com/georgkrause/langcodes
	https://pypi.org/project/langcodes/
"
SRC_URI="https://github.com/georgkrause/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

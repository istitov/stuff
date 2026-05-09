# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# Github tarball loses .git/ — setuptools-scm needs the version via env.
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_DLINFO="${PV}"

BDEPEND="dev-python/setuptools-scm[${PYTHON_USEDEP}]"

MY_PN="python-dlinfo"
DESCRIPTION="Python wrapper for libc dlinfo() — query attributes of loaded shared objects"
HOMEPAGE="
	https://github.com/fphammerle/python-dlinfo
	https://pypi.org/project/dlinfo/
"
SRC_URI="https://github.com/fphammerle/${MY_PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

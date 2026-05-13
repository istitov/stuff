# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Lightweight tool to report Python package versions and system info"
HOMEPAGE="
	https://github.com/banesullivan/scooby
	https://pypi.org/project/scooby/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# scooby uses setuptools_scm to derive its version from git metadata,
# but PyPI sdist tarballs ship a PKG-INFO file with the version baked
# in instead — set SETUPTOOLS_SCM_PRETEND_VERSION so the build doesn't
# fall back to git introspection (which fails in portage's sandbox
# anyway).
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

EPYTEST_PLUGINS=()

distutils_enable_tests pytest

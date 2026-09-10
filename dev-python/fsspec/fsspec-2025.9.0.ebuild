# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Specification that Python filesystems should adhere to"
HOMEPAGE="
	https://github.com/fsspec/filesystem_spec/
	https://pypi.org/project/fsspec/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Retain this older version solely for datasets-4.3.0's <=2025.9.0 ceiling.
# Other consumers accept ::gentoo's newer versions; remove this package with
# the last datasets 4.x release.
# verified 2026-08-29

BDEPEND="dev-python/hatch-vcs[${PYTHON_USEDEP}]"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

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
KEYWORDS="~amd64"

# This is deliberately OLDER than ::gentoo, which ships 2026.6.0 and 2026.7.0.
# Do not "fix" the apparent drift by bumping it: this version exists solely to
# satisfy sci-ml/datasets-4.3.0's `<=dev-python/fsspec-2025.9.0-r0` ceiling,
# which neither ::gentoo version can meet. No other consumer in the overlay
# has a CEILING: dask, lightning, pytorch and bigcode-eval declare a floor,
# and huggingface_hub and sitka-spruce are unversioned. Either way they all
# resolve against ::gentoo's newer fsspec.
#
# datasets-5.0.1 raised that ceiling to <=2026.6.0 and so no longer needs this
# package. Once datasets-4.3.0 is dropped -- it is retained as the last of the
# 4.x series -- nothing in the overlay requires an fsspec below ::gentoo's, and
# this whole package can go. Re-check on every datasets retention pass.
# verified 2026-08-29

BDEPEND="dev-python/hatch-vcs[${PYTHON_USEDEP}]"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

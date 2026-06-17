# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

# No PyPI release carries the API TRELLIS uses; pin the exact commit TRELLIS's
# setup.sh installs (EasternJournalist/utils3d @ 9a4eb15e, 2024-12-01).
COMMIT="9a4eb15e4021b67b12c460c7057d642626897ec8"

DESCRIPTION="Easy 3D geometry processing utilities for numpy and pytorch"
HOMEPAGE="https://github.com/EasternJournalist/utils3d"
SRC_URI="https://github.com/EasternJournalist/utils3d/archive/${COMMIT}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
"

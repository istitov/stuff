# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

MY_PN="${PN/-/_}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python wrapper of the C library 'Google CRC32C'"
HOMEPAGE="
	https://github.com/googleapis/python-crc32c
	https://pypi.org/project/google-crc32c/
"
SRC_URI="$(pypi_sdist_url "${MY_PN}" "${PV}")"
S="${WORKDIR}/${MY_P}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-libs/crc32c
"
DEPEND="${RDEPEND}"

# Link the C extension against system dev-libs/crc32c.
export CRC32C_INSTALL_PREFIX="${EPREFIX}/usr"

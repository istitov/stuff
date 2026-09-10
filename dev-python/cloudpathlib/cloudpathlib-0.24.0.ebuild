# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="pathlib-style classes for cloud storage services (S3, GS, Azure)"
HOMEPAGE="
	https://github.com/drivendataorg/cloudpathlib
	https://pypi.org/project/cloudpathlib/
"
SRC_URI="https://github.com/drivendataorg/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Cloud-backend extras (S3, GS, Azure) are optional and omitted.
RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

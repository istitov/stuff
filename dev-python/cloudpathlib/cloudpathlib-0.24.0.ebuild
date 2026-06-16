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

# Core install only — cloud-backend extras (s3, gs, azure) bring boto3,
# google-cloud-storage, azure-* respectively. Not pulled here; opt in
# via downstream packages or upstream pip if needed.
RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN="smart_open"
DESCRIPTION="Utility for streaming large files from S3, HDFS, gzip / bzip2, etc."
HOMEPAGE="
	https://github.com/piskvorky/smart_open
	https://pypi.org/project/smart-open/
"
SRC_URI="https://github.com/piskvorky/${MY_PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/wrapt[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

# 8.0.0 switched to setuptools_scm for versioning. The GitHub archive tarball
# carries no .git, so setuptools_scm would fall back to 0.1.dev0+gitnotfound;
# pin the real version instead. verified 2026-06-28
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

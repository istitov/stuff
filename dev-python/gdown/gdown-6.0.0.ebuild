# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Command-line Google Drive file downloader"
HOMEPAGE="
	https://github.com/wkentaro/gdown/
	https://pypi.org/project/gdown/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# Upstream's tests download from Google Drive; not viable at build
# time.
RESTRICT="test"

RDEPEND="
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	dev-python/filelock[${PYTHON_USEDEP}]
	dev-python/requests[socks5,${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
"

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
KEYWORDS="~amd64 ~arm64 ~x86"
# Upstream's tests download from Google Drive; not viable at build
# time.
RESTRICT="test"

# distutils-r1 contributes only dev-python/hatchling for
# DISTUTILS_USE_PEP517=hatchling. Upstream's build-system requires two
# further plugins, and both are wired up rather than vestigial:
# [tool.hatch.version] source = "vcs" and a fancy-pypi-readme metadata
# hook, with dynamic = ["readme", "version"] driving them. Gentoo builds
# with --no-build-isolation, so they have to be installed already. They
# were never declared here -- the build passes on any host that happens
# to have them. verified 2026-09-04 against the 6.1.1 sdist
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
		dev-python/hatch-vcs[${PYTHON_USEDEP}]
	')
"

RDEPEND="
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	dev-python/filelock[${PYTHON_USEDEP}]
	dev-python/requests[socks5,${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
"

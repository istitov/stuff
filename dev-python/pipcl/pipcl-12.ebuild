# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=standalone

inherit distutils-r1

DESCRIPTION="Python packaging operations helper used by ArtifexSoftware projects"
HOMEPAGE="
	https://github.com/ArtifexSoftware/pipcl
	https://mupdf.com
"
SRC_URI="https://github.com/ArtifexSoftware/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# standalone omits build requirements; pipcl also imports packaging at runtime.
# verified 2026-06-19
BDEPEND="dev-python/packaging[${PYTHON_USEDEP}]"
RDEPEND="dev-python/packaging[${PYTHON_USEDEP}]"

# Tests install extra tooling over the network and build sample wheels.
# verified 2026-06-19
RESTRICT="test"

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_TAG="cuda-pathfinder-v${PV}"

DESCRIPTION="Pathfinder for CUDA components"
HOMEPAGE="
	https://github.com/NVIDIA/cuda-python
	https://pypi.org/project/cuda-pathfinder/
"
SRC_URI="https://github.com/NVIDIA/cuda-python/archive/${MY_TAG}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/cuda-python-${MY_TAG}/cuda_pathfinder"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

src_prepare() {
	# The GitHub archive carries no git history, so the upstream
	# setuptools_scm-driven dynamic version resolution can't run. Rewrite
	# pyproject.toml to use a static version and write the _version.py
	# stub that setuptools_scm would otherwise generate.
	sed -i \
		-e '/setuptools_scm/d' \
		-e 's/dynamic = \["version", "readme"\]/dynamic = ["readme"]/' \
		-e "/^name = \"cuda-pathfinder\"/a version = \"${PV}\"" \
		-e '/^\[tool\.setuptools_scm\]/,/^\[/{/^\[tool\.setuptools_scm\]/d; /^\[/!d}' \
		pyproject.toml || die

	cat > cuda/pathfinder/_version.py <<-EOF || die
		__version__ = "${PV}"
	EOF

	distutils-r1_src_prepare
}

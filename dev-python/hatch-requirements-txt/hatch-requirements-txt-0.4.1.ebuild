# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1 pypi

DESCRIPTION="Hatchling plugin to read project dependencies from requirements.txt"
HOMEPAGE="https://github.com/repo-helper/hatch-requirements-txt"
SRC_URI="$(pypi_sdist_url "${PN}" "${PV}")"
#S=${WORKDIR}/${P^}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc python"

RDEPEND="
dev-python/hatchling
"

DEPEND="${RDEPEND}
        doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

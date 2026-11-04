# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-r1

DESCRIPTION="Virtual for the Triton GPU-kernel compiler (source build or binary wheel)"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	|| (
		~dev-python/triton-${PV}[${PYTHON_USEDEP}]
		~dev-python/triton-bin-${PV}[${PYTHON_USEDEP}]
	)
"

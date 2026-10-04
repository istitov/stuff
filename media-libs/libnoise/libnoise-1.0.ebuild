# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Coherent-noise generation library (OrcaSlicer fork with modern CMake)"
HOMEPAGE="https://github.com/SoftFever/Orca-deps-libnoise"
SRC_URI="https://github.com/SoftFever/Orca-deps-libnoise/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/Orca-deps-${PN}-${PV}"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

# The fork builds only liblibnoise_static.a, and its sole consumer,
# media-gfx/orcaslicer, links that archive (its Findlibnoise imports a
# STATIC target), so installing it meets PG0302. verified 2026-10-04

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for the AOTriton math library (binary package or source build)"

SLOT="0/${PV%b}"
KEYWORDS="-* ~amd64"

# No matching source build is packaged.
RDEPEND="
	~sci-libs/aotriton-bin-${PV}
"

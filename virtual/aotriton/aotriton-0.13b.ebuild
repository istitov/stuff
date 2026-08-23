# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for the AOTriton math library (binary package or source build)"

SLOT="0/${PV%b}"
KEYWORDS="-* ~amd64"

# Binary first: the from-source sci-libs/aotriton is a multi-hour AOT kernel
# compile, so default to sci-libs/aotriton-bin unless the user explicitly
# installs the source build.
RDEPEND="
	|| (
		~sci-libs/aotriton-bin-${PV}
		~sci-libs/aotriton-${PV}
	)
"

# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=ETJ
DIST_VERSION=1.26
inherit perl-module toolchain-funcs

DESCRIPTION="Simple interface to F77 libs"

SLOT="0"
# Same-version copy of ::gentoo's 1.260.0-r1, carried only for ~arm64,
# which ::gentoo lacks; PGPLOT needs it there. Drop it once
# ::gentoo keywords arm64. verified 2026-11-09
KEYWORDS="~alpha amd64 arm ~arm64 ~hppa ~m68k ~mips ppc ppc64 ~s390 ~sparc x86"

RDEPEND="
	dev-perl/File-Which
	virtual/fortran
"
BDEPEND="${RDEPEND}"

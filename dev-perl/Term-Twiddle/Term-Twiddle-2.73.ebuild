# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=SCOTTW
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="Twiddles a thingy while-u-wait"
LICENSE="|| ( Artistic GPL-2 )"

SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# Twiddle.pm:9 does `use Time::HiRes qw(setitimer ITIMER_REAL)`, matching
# upstream's Makefile.PL PREREQ_PM. Time::HiRes is perl-core, so this only
# ever arrived via dev-lang/perl; declare it the way the ::gentoo peers with
# the same prereq do. No floor: the oldest virtual in the tree is already far
# above the 1.30 upstream asks for. verified 2026-07-27
RDEPEND="virtual/perl-Time-HiRes"
BDEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
"

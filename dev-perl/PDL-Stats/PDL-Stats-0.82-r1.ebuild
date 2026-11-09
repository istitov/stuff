# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=ETJ
DIST_VERSION=${PV}
inherit perl-module

PATCHES=( "${FILESDIR}/${P}-pdl-2.100.patch" )

DESCRIPTION="A collection of statistics modules in Perl Data Language"

SLOT="0"
# PDL, a hard dependency, carries no arm64 keyword. verified 2026-11-09
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"
# Map upstream PDL 2.057 to Gentoo's 2.57.0 floor. MakeMaker is build-only;
# tests need unpackaged Test::PDL. verified 2026-07-27
RDEPEND="
	>=dev-perl/PDL-2.57.0
"
BDEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
"

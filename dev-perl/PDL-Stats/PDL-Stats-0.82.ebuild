# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=ETJ
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="A collection of statistics modules in Perl Data Language"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"
RDEPEND="
	virtual/perl-ExtUtils-MakeMaker
	dev-perl/PDL
"

SRC_TEST="do"

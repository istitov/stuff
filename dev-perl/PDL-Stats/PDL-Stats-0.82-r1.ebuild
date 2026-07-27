# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=ETJ
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="A collection of statistics modules in Perl Data Language"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"
# Upstream META.json for this release requires PDL 2.057 at runtime and
# PDL::Core 2.008 to build and configure; gentoo's PDL versioning maps the perl
# 2.0NN form onto 2.NN.0, so 2.057 is 2.57.0. ExtUtils::MakeMaker runs
# Makefile.PL and is not needed once installed, so it moves to BDEPEND.
# Tests additionally want Test::PDL, which is not packaged in any repo.
# verified 2026-07-27
RDEPEND="
	>=dev-perl/PDL-2.57.0
"
BDEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
"

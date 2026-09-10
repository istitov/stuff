# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=SWEETKID
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="A LaxNum type which provides the loose behavior of Moose's Num pre-2.10 "

SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-perl/Moose
	virtual/perl-ExtUtils-MakeMaker
"
DEPEND="${RDEPEND}
	>=virtual/perl-ExtUtils-MakeMaker-6.420.0
"

# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=SWEETKID
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="A LaxNum type which provides the loose behavior of Moose's Num pre-2.10 "

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-perl/Moose
	virtual/perl-ExtUtils-MakeMaker
"
#	dev-perl/Moose-Util-TypeConstraints
#	dev-perl/Scalar-Util

DEPEND="${RDEPEND}
	>=virtual/perl-ExtUtils-MakeMaker-6.420.0
"
#	test? (
#		dev-perl/File-Find
#		dev-perl/File-Temp
#		dev-perl/Test-Fatal
#		dev-perl/Test-More
#	)

SRC_TEST=do

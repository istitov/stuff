# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=DRYMAN
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="Monitor file changes"

SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# lib/File/Monitor/Lite.pm uses all four at module scope: File::Spec::Functions,
# File::Find::Rule and File::Monitor by name, and Class::Accessor::Fast via
# `use base` plus mk_accessors. Matches upstream's Makefile.PL PREREQ_PM, minus
# File::Touch which only the test files use. verified 2026-07-27
RDEPEND="
	dev-perl/Class-Accessor
	dev-perl/File-Find-Rule
	dev-perl/File-Monitor
	virtual/perl-File-Spec
"
BDEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
	test? (
		dev-perl/File-Touch
		virtual/perl-Test-Simple
	)
"

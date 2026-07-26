# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=MGRUNER
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="generates CPAN like project documents from pod"

SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
# https://rt.cpan.org/Ticket/Display.html?id=60373
#IUSE="+highlight"
comment() { true;}
COMMON_DEPEND="
	$(comment Moose)
	$(comment Moose::Role)
	dev-perl/Moose

	$(comment HTML::Entities)
	dev-perl/HTML-Parser

	$(comment Pod::Simple::XHTML 3.31)
	>=virtual/perl-Pod-Simple-3.310.0

	$(comment File::Spec)
	virtual/perl-File-Spec

	$(comment File::Basename)

	$(comment File::Find)

	$(comment File::Copy)

	$(comment MIME::Base64)
	virtual/perl-MIME-Base64

	$(comment Template)
	dev-perl/Template-Toolkit

	$(comment Readonly)
	dev-perl/Readonly

	$(comment JSON 2.04)
	>=dev-perl/JSON-2.40.0
"
#	highlight? (
#		dev-perl/Syntax-Highlight-Universal
#	)
#"
#>=virtual/perl-Pod-Parser-1.320.0
DEPEND="
	${COMMON_DEPEND}
"
RDEPEND="
	${COMMON_DEPEND}
"

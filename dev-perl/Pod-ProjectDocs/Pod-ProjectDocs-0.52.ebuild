# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
MODULE_AUTHOR=MGRUNER
MODULE_VERSION=${PV}
inherit perl-module

DESCRIPTION="generates CPAN like project documents from pod"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
# https://rt.cpan.org/Ticket/Display.html?id=60373
#IUSE="+highlight"
comment() { true;}
COMMON_DEPEND="
	$(comment Pod::Parser 1.32)
	$(comment Pod::ParseUtils)
	>=virtual/perl-Pod-Parser-1.320.0

	$(comment Class::Accessor::Fast)
	dev-perl/Class-Accessor

	$(comment Class::Data::Inheritable)
	dev-perl/Class-Data-Inheritable

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

	$(comment URI::Escape)
	dev-perl/URI

	$(comment JSON 2.04)
	>=dev-perl/JSON-2.40.0
"
#	highlight? (
#		dev-perl/Syntax-Highlight-Universal
#	)
#"
DEPEND="
	${COMMON_DEPEND}
"
RDEPEND="
	${COMMON_DEPEND}
"

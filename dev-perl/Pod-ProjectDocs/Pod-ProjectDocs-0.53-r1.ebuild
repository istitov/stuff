# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=MGRUNER
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="generates CPAN like project documents from pod"

SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
COMMON_DEPEND="
	dev-perl/Moose
	dev-perl/HTML-Parser
	>=virtual/perl-Pod-Simple-3.310.0
	virtual/perl-File-Spec
	virtual/perl-MIME-Base64
	dev-perl/Template-Toolkit
	dev-perl/Readonly
	>=dev-perl/JSON-2.40.0
"
DEPEND="
	${COMMON_DEPEND}
"
RDEPEND="
	${COMMON_DEPEND}
"

# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit perl-module perl-functions git-r3 virtualx

DESCRIPTION="Software for XAS data processing"
HOMEPAGE="https://github.com/bruceravel/demeter"
EGIT_REPO_URI="https://github.com/bruceravel/demeter.git"

LICENSE="Artistic GPL-1+"
SLOT="0"
IUSE="doc test"

RDEPEND="
	sci-physics/ifeffit
	>=dev-perl/Archive-Zip-1.31
	dev-perl/Module-Build
	>=dev-perl/Capture-Tiny-0.07
	dev-perl/Config-INI
	>=dev-perl/Const-Fast-0.01
	dev-perl/DateTime
	>=dev-perl/Encoding-FixLatin-1.04
	dev-perl/Encoding-FixLatin-XS
	dev-perl/File-Copy-Recursive
	dev-perl/File-Find-Rule
	dev-perl/File-CountLines
	dev-perl/File-Touch
	>=dev-perl/File-Which-1.09
	dev-perl/File-Monitor
	dev-perl/File-Monitor-Lite
	dev-perl/File-Copy-Recursive
	dev-perl/File-Slurper
	dev-perl/Graph
	dev-perl/Heap
	dev-perl/JSON
	dev-perl/List-MoreUtils
	dev-perl/Math-Combinatorics
	dev-perl/Math-Derivative
	dev-perl/Math-Random
	dev-perl/Math-Round
	dev-perl/Math-Spline
	>=dev-perl/Moose-2.09
	>=dev-perl/MooseX-Aliases-0.10
	>=dev-perl/MooseX-Types-0.31
	dev-perl/MooseX-Types-LaxNum
	>=dev-perl/PDL-2.4.9
	>=dev-perl/PDL-Stats-0.5.5
	dev-perl/Pod-POM
	dev-perl/RPC-XML
	dev-perl/Regexp-Assemble
	dev-perl/Regexp-Common
	dev-perl/Spreadsheet-WriteExcel
	dev-perl/Statistics-Descriptive
	dev-perl/Text-Template
	dev-perl/Text-Unidecode
	dev-perl/Tree-Simple
	dev-perl/Want
	dev-perl/XMLRPC-Lite
	dev-perl/Pod-ProjectDocs
	dev-perl/Graphics-GnuplotIF
	>=dev-perl/Wx-0.86
	dev-perl/Chemistry-Elements
	dev-perl/Term-Sk
	dev-perl/Term-Twiddle
	virtual/perl-ExtUtils-CBuilder
"
#	sci-physics/xraylarch
#	dev-perl/Digest-SHA
#	dev-perl/YAML-Tiny
#	dev-perl/RPC-XML-Client

DEPEND="${RDEPEND}
	test? ( x11-base/xorg-server[xvfb] )
	doc? ( dev-util/gtk-doc )
"

S="${WORKDIR}/${PN}-${PV}"

PATCHES=(
	"${FILESDIR}"/ifeffit_locate.patch
)

src_configure() {
	perl -I . Build.PL
}

src_compile() {
	./Build
}

src_test() {
	virtx ./Build test
}

src_install() {
	perl_set_version
	./Build --install_path lib="${D}"/${SITE_LIB} \
		--install_path arch="${D}"/${SITE_LIB} \
		--install_path bin="${D}"/bin \
		--install_path script="${D}"/bin \
		--install_path bindoc=`pwd`/man/ \
		--install_path libdoc=`pwd`/man/ \
		install
}

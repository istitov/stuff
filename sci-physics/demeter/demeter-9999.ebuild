# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit perl-module git-r3

DESCRIPTION="Software for XAS data processing"
HOMEPAGE="https://github.com/bruceravel/demeter"
EGIT_REPO_URI="git://github.com/bruceravel/demeter.git"

LICENSE="Artistic GPL-1+"
SLOT="0"
KEYWORDS=""
IUSE="doc perl"

RDEPEND="
	sci-physics/xraylarch
	sci-physics/ifeffit
	dev-perl/Module-Build
	dev-perl/Capture-Tiny
	dev-perl/Config-INI
	dev-perl/Const-Fast
	dev-perl/DateTime
	dev-perl/Encoding-FixLatin
	dev-perl/File-Copy-Recursive
	dev-perl/File-Find-Rule
	dev-perl/File-CountLines
	dev-perl/File-Touch
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
	dev-perl/Moose
	dev-perl/MooseX-Aliases
	dev-perl/MooseX-Types
	dev-perl/MooseX-Types-LaxNum
	dev-perl/PDL
	dev-perl/PDL-Stats
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
	dev-perl/Wx
	dev-perl/Chemistry-Elements
	dev-perl/Term-Sk
	dev-perl/Term-Twiddle
"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

S="${WORKDIR}/${PN}-${PV}"
DESTDIR="${D}"

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
	test? ./Build test
}

src_install() {
	./Build --install_path lib="${D}"/usr/local/lib64/perl5 \
        	--install_path arch="${D}"/usr/local/lib64/perl5 \
		--install_path bin="${D}"/bin \
        	--install_path script="${D}"/bin \
      		--install_path bindoc=`pwd`/man/ \
        	--install_path libdoc=`pwd`/man/ \
		install
}

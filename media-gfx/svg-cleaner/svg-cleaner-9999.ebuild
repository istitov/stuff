# Copyright 2008-2012 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit git-2
DESCRIPTION="SVG Cleaner cleans up your SVG files from unnecessary data."
HOMEPAGE="http://qt-apps.org/content/show.php?action=content&content=147974 https://github.com/RazrFalcon/SVGCleaner"
EGIT_REPO_URI="https://github.com/RazrFalcon/SVGCleaner.git"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
dev-perl/XML-Twig
app-arch/p7zip
dev-lang/perl
>=dev-qt/qtsvg-4.6"
RDEPEND="${DEPEND}"
src_configure() {
qmake \"PREFIX+="${D}"\"
}
src_compile() {
emake || die "Make failed!"
}
src_install() {
emake install || die "Install failed"
}

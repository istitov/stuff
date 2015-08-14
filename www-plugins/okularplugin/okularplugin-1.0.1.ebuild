# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit kde4-base nsplugins readme.gentoo

DESCRIPTION="Plugin for embedding okular into the browser"
HOMEPAGE="https://github.com/afrimberger/okularplugin"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="kde-base/okular:4"
RDEPEND="${DEPEND}"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
okularplugin is now installed, but must be configured as PDF viewer
in your browser(s).
Chrome:
	Open the address chrome://plugins, disable \"Chrome PDF viewer\"
	and check \"Always allowed\" for \"Okular plugin\".
Chromium:
	Open the address chrome://plugins and check \"Always allowed\"
	for \"Okular plugin\".
Firefox:
	Open the Preferences dialog, go in the Applications section and
	select \"Use Okular plugin (in Firefox)\" beside
	\"Portable Document Format (PDF)\".
"

src_install() {
	kde4-base_src_install
	inst_plugin "$(kde4-config --install lib)/lib${PN}.so"
	readme.gentoo_create_doc
}

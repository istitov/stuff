# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools desktop git-r3 xdg

DESCRIPTION="GTK-based collaborative editor"
HOMEPAGE="https://gobby.github.io/"
EGIT_REPO_URI="https://github.com/${PN}/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
IUSE="avahi nls"

RDEPEND="
	>=dev-cpp/gtkmm-3.6.0:3.0
	>=dev-cpp/glibmm-2.39.93:2
	dev-cpp/libxmlpp:2.6
	dev-libs/libsigc++:2
	net-libs/libinfinity:0.7[gtk3,avahi?]
	x11-libs/gtk+:3
	x11-libs/gtksourceview:3.0
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-text/yelp-tools
	virtual/pkgconfig
	nls? ( >=sys-devel/gettext-0.12.1 )
"

src_prepare() {
	default
	# Rename binary, automake symbols, and data paths from upstream's
	# legacy 'gobby-0.5' suffix to match the actual package version.
	local f
	while read -r f; do
		sed -i \
			-e 's/gobby-0\.5/gobby-0.6/g' \
			-e 's/gobby_0_5/gobby_0_6/g' "${f}" || die
	done < <(grep -rlE 'gobby-0\.5|gobby_0_5' \
		--include='Makefile.am' --include='*.in' --include='*.cpp' \
		--include='*.docbook' --include='*.xml' --include='*.ui' .)
	while read -r f; do
		mv "${f}" "${f//gobby-0.5/gobby-0.6}" || die
	done < <(find . -name 'gobby-0.5*' -type f)
	eautoreconf
}

src_configure() {
	econf $(use_enable nls)
}

src_install() {
	default
}

# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit git-r3

EGIT_REPO_URI="https://github.com/cedlemo/blingbling.git"

DESCRIPTION="Blingbling is a graphical widget library for Awesome Windows Manager"
HOMEPAGE="http://awesome.naquadah.org/wiki/Blingbling"

LICENSE="GPL-2"
SLOT="0"
IUSE="+vicious"

RDEPEND="dev-lang/lua
	x11-wm/awesome
	dev-libs/oocairo
	vicious? ( x11-plugins/vicious )"

DEPEND="${RDEPEND}"

src_install() {
	#echo "$P | $PV | $PN | $D"
	insinto "/usr/share/awesome/lib/${PN}"
	for f in `ls ./*.lua`; do
		if [ -f ${f} ]; then
			doins "${f}"
		fi
	done

	#insinto "/usr/share/awesome/lib/${PN}/layout"
	#for f in `ls ./layout/`; do
	#		doins "layout/${f}"
	#done

	dodoc README.md To_Do
}

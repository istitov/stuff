# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="tk(+)"

_PYTHON_ALLOW_PY27=1
DISTUTILS_USE_SETUPTOOLS="manual"
#DISTUTILS_SINGLE_IMPL=1
DISTUTILS_OPTIONAL=1

inherit git-r3 distutils-r1_py2 xdg-utils desktop

DESCRIPTION="sK1 vector graphics editor"
HOMEPAGE="http://www.sk1project.org/"
EGIT_REPO_URI="https://github.com/sk1project/sk1-tk.git"

LICENSE="|| ( GPL-2 LGPL-2 )"
SLOT="0"

#The absence of [py2] on deps for pillow looks suspicious
DEPEND="
	dev-lang/python:2.7
	dev-lang/tcl:0
	dev-lang/tk:0
	media-libs/freetype:2
	>=sys-libs/zlib-1.1.4
	>=x11-libs/cairo-1.2.4
	media-libs/lcms:2
	dev-python/pycairo
	dev-python/pillow
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXcursor"
RDEPEND="${DEPEND}
	dev-python/reportlab
	app-text/ghostscript-gpl"

src_compile() {
	python_foreach_impl _distutils-r1_copy_egg_info
	python_foreach_impl esetup.py build  "${build_args[@]}" "${@}"
}

src_install() {
		distutils-r1_src_install
		newicon src/sk1/share/images/sk1-app-icon.png sk1.png
		make_desktop_entry ${PN} "${MY_PN}" ${PN} "Graphics;VectorGraphics;"
}

pkg_postinstall() {
	xdg_pkg_postinst
	xdg_desktop_database_update
}

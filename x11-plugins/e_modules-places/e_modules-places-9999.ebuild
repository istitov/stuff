# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

E_PKG_IUSE="nls"

ESVN_SUB_PROJECT="E-MODULES-EXTRA"
ESVN_URI_APPEND="${PN#e_modules-}"
inherit enlightenment

DESCRIPTION="E17 Module that manage the mounting of volumes"

IUSE=""

DEPEND="x11-wm/enlightenment"

RDEPEND="${DEPEND}"

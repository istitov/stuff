# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils versionator

MY_PV="$(replace_version_separator 2 '-')"
MY_PN="db-vk"

DESCRIPTION="DeadBeef plugin for listening music from vkontakte.com"
HOMEPAGE="https://github.com/scorpp/db-vk"
SRC_URI="https://github.com/scorpp/${MY_PN}/archive/v${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="gtk2 gtk3"
REQUIRED_USE="|| ( ${IUSE} )"

DEPEND_COMMON="dev-libs/json-glib
	gtk2? ( media-sound/deadbeef[gtk2,curl] )
	gtk3? ( media-sound/deadbeef[gtk3,curl] )"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"
S="${WORKDIR}/${MY_PN}-${PV}"

src_configure() {
	mycmakeargs="
	$(cmake-utils_use_with gtk2 GTK2)
	$(cmake-utils_use_with gtk3 GTK3)"
	cmake-utils_src_configure
}

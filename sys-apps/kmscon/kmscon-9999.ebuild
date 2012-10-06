# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

if [[ ${PV} = 9999* ]]; then
    GIT_ECLASS="git-2"
    EXPERIMENTAL="true"
fi

inherit autotools toolchain-funcs $GIT_ECLASS

DESCRIPTION="Kmscon is a userspace virtual console for Linux, using kernel mode-setting (KMS) for output."
HOMEPAGE="https://github.com/dvdhrm/kmscon"
EGIT_REPO_URI="git://github.com/dvdhrm/kmscon.git"
LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="wayland gles2 systemd pango"

DEPEND="gles2? ( media-libs/mesa[gles2,gbm] ) \
    wayland? ( dev-libs/wayland ) \
    systemd? ( sys-apps/systemd ) \
    pango? ( x11-libs/pango )
    x11-libs/libdrm[libkms] \
    x11-libs/libxkbcommon \
    sys-fs/udev
"
RDEPEND="${DEPEND}"

src_prepare() {
    if [[ ${PV} = 9999* ]]; then
        eautoreconf
    fi
}

src_configure() {
    econf $(use_enable gles2) \
        $(use_enable wayland wlterm) \
        $(use_enable systemd) \
        $(use_enable pango)
}

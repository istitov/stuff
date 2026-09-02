# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

# Upstream tag is v0.1.806-beta. Through 0.1.803-beta the release assets spelled
# the version with underscores (Unsloth-Desktop-0_1_803_beta-Ubuntu.deb); at
# 0.1.804-beta upstream dropped the version from every asset name, so the .deb
# is now just Unsloth-Desktop-Ubuntu.deb. The tag in the URL still pins the
# fetch, and the -> ${P}.deb rename below keeps the distfile name version-unique,
# so the unversioned upstream name is not a durability hazard. Settled convention
# now: it has held unchanged from 0.1.804-beta through 0.1.806-beta, across every
# platform asset. verified 2026-09-02 against v0.1.806-beta
MY_TAG="v${PV/_beta/-beta}"
MY_DEB="Unsloth-Desktop-Ubuntu.deb"

DESCRIPTION="Tauri desktop UI to run and train LLMs/diffusion/audio models locally"
HOMEPAGE="
	https://unsloth.ai/docs/desktop
	https://github.com/unslothai/unsloth
"
SRC_URI="https://github.com/unslothai/unsloth/releases/download/${MY_TAG}/${MY_DEB} -> ${P}.deb"
S="${WORKDIR}"

# The prebuilt desktop UI (usr/bin/unsloth-studio) is the studio/ tree, which is
# AGPL-3.0-only in the dual-licensed upstream repo (the Apache-2.0 half is the
# Python library, packaged separately as sci-ml/unsloth).
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

# Ground-truth DT_NEEDED of usr/bin/unsloth-studio (readelf -d), NOT the .deb's
# declared Depends: the .deb over-declares libappindicator3-1, but the binary
# carries no such NEEDED -- the tray icon is dlopen-optional. The remaining
# NEEDED (libgdk_pixbuf/gobject/gio/javascriptcoregtk) are covered by the atoms
# below. verified 2026-09-02 against Unsloth-Desktop-Ubuntu.deb (v0.1.806-beta).
# This standalone binary installs /usr/bin/unsloth-studio, which collides with
# sci-ml/unsloth[studio]'s system-launcher of the same name (and pulling that in
# is the from-source sci-ml/unsloth-desktop path -- a different way to get the
# same app). Block co-installation rather than ship a file collision.
RDEPEND="
	!!sci-ml/unsloth[studio]
	dev-libs/glib:2
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
"

QA_PREBUILT="usr/bin/unsloth-studio"

src_unpack() {
	# .deb -> extracts the usr/ tree (data.tar) straight into ${WORKDIR}.
	unpack_deb "${A}"
}

src_install() {
	# Preserve the upstream .deb paths: unsloth-studio resolves its bundled
	# backend installer at /usr/lib/Unsloth/install.sh, so keep it there.
	exeinto /usr/bin
	doexe usr/bin/unsloth-studio

	exeinto /usr/lib/Unsloth
	doexe usr/lib/Unsloth/install.sh

	domenu usr/share/applications/Unsloth.desktop
	doicon -s 32 usr/share/icons/hicolor/32x32/apps/unsloth-studio.png
	doicon -s 128 usr/share/icons/hicolor/128x128/apps/unsloth-studio.png
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "This package installs ONLY the Unsloth Desktop UI shell (unsloth-studio)."
	elog "On first launch it bootstraps its own Python backend under"
	elog "  ~/.unsloth/studio"
	elog "downloading uv, a private CPython, PyTorch and the inference engine."
	elog "It does NOT use the system sci-ml/unsloth / sci-ml/pytorch stack."
	elog ""
	elog "First run therefore needs network access and a downloader (curl or wget);"
	elog "git is used when present. AMD ROCm is auto-selected on supported Radeon"
	elog "GPUs (including Strix). This is beta software."
}

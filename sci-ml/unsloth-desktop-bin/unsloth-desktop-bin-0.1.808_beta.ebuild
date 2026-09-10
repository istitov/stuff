# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

# Since 0.1.804_beta, assets use unversioned names; the tag pins the fetch and
# the rename keeps distfiles unique. Verified through 0.1.808_beta.
MY_TAG="v${PV/_beta/-beta}"
MY_DEB="Unsloth-Desktop-Ubuntu.deb"

DESCRIPTION="Tauri desktop UI to run and train LLMs/diffusion/audio models locally"
HOMEPAGE="
	https://unsloth.ai/docs/desktop
	https://github.com/unslothai/unsloth
"
SRC_URI="https://github.com/unslothai/unsloth/releases/download/${MY_TAG}/${MY_DEB} -> ${P}.deb"
S="${WORKDIR}"

# This studio binary is AGPL-3-only; Apache-2.0 covers the separately packaged
# Python library.
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

# Dependencies follow DT_NEEDED, not the overdeclared Debian metadata;
# libappindicator is dlopen-optional. Block sci-ml/unsloth[studio], which owns
# the same /usr/bin/unsloth-studio. Verified 2026-09-10.
RDEPEND="
	!!sci-ml/unsloth[studio]
	|| (
		net-misc/curl
		net-misc/wget
	)
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
	unpack_deb "${A}"
}

src_install() {
	# The binary resolves its backend installer at /usr/lib/Unsloth/install.sh.
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

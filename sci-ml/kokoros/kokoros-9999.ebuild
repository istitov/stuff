# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Kokoro-82M TTS server in Rust (CPU; OpenAI-compatible HTTP API)"
HOMEPAGE="https://github.com/lucasjinreal/Kokoros"

# Tracks upstream lucasjinreal/Kokoros directly — the lemonade-sdk fork
# diverges only in CI/release infrastructure plus a bundled copy of
# espeak-ng-data. Having app-accessibility/espeak-ng installed does NOT
# by itself make that bundle redundant: the binary never consults
# /usr/share unless pointed there, which is what the wrapper in
# src_install exists to do. Given that, the fork's bundling is plausibly
# a workaround for the same baked-path problem — untested, so treat it as
# a lead rather than a fact if the fork is ever revisited.
EGIT_REPO_URI="https://github.com/lucasjinreal/Kokoros.git"

LICENSE="Apache-2.0"
SLOT="0"
# No KEYWORDS for live ebuild.

# Cargo fetches all crates online; bundled ONNX Runtime download is also part
# of the build via `ort = { default-features = true }`. Keep network open.
PROPERTIES="live"
RESTRICT="network-sandbox"

# Edition 2024 needs rust >= 1.85; Cargo.toml workspace pins ort 2.0-rc11 etc.
BDEPEND="
	|| ( >=dev-lang/rust-1.85 >=dev-lang/rust-bin-1.85 )
	virtual/pkgconfig
"
RDEPEND="
	app-accessibility/espeak-ng
	media-libs/libogg:=
	media-libs/opus:=
	media-libs/pcaudiolib
	media-libs/sonic
	media-sound/lame:=
"
DEPEND="${RDEPEND}"

src_compile() {
	# cargo.eclass assumes a vendored CRATES list; we let cargo fetch
	# online via RESTRICT=network-sandbox, so call cargo directly.
	# espeak-rs-sys bundles espeak-ng but its build.rs doesn't emit
	# `cargo:rustc-link-lib=pcaudio`, leaving audio_object_* unresolved
	# at link time. Force the link via RUSTFLAGS.
	local RUSTFLAGS="${RUSTFLAGS} -l pcaudio"
	export RUSTFLAGS

	cargo build --release --bin koko || die "cargo build failed"
}

src_install() {
	# koko does NOT pick up the system espeak-ng-data on its own, despite
	# linking espeak-rs. espeak-rs-sys builds a *vendored* espeak-ng via the
	# cmake crate, which defaults CMAKE_INSTALL_PREFIX to $OUT_DIR, and
	# espeak-ng bakes that prefix into the binary as its compile-time
	# PATH_ESPEAK_DATA. $OUT_DIR is inside the portage work dir, so the
	# baked path evaporates at merge and every synthesis call fails to load
	# phontab.
	#
	# The failure is silent in the worst way: the error goes to koko's
	# stderr only, the process still exits 0, and it still writes a valid
	# WAV - a fixed ~0.48 s stub, byte-identical for every input, because
	# the style vector is applied to an empty phoneme sequence. Consumers
	# that proxy koko over HTTP (sci-ml/lemonade) report success throughout.
	#
	# There is no build-time fix. espeak-rs-sys-0.1.9's build.rs exposes
	# only ESPEAK_BUILD_SHARED_LIBS, ESPEAK_LIB_PROFILE, ESPEAK_STATIC_CRT
	# and CMAKE_VERBOSE - nothing for the data path, and no option to link
	# the system espeak-ng instead of vendoring. It never sets
	# CMAKE_INSTALL_PREFIX itself, so the prefix cannot be steered without
	# also breaking the -L search paths that point into $OUT_DIR.
	#
	# So redirect at runtime. espeak_ng_InitializePath() (speech.c) resolves
	# in order: explicit argument, $ESPEAK_DATA_PATH, $HOME, then the baked
	# PATH_ESPEAK_DATA. Kokoros passes no explicit path, so the env var is
	# the first hook available. check_data_path() tries "$VAR/espeak-ng-data"
	# before "$VAR" itself, so /usr/share is the canonical value - it
	# resolves to app-accessibility/espeak-ng's /usr/share/espeak-ng-data.
	#
	# A wrapper rather than documentation: the main consumer (lemonade)
	# spawns koko itself, so nobody gets to set the variable at the call
	# site.
	#
	# The wrapper VALIDATES rather than merely defaulting, which matters:
	# sci-ml/lemonade exports ESPEAK_DATA_PATH=/usr/bin/espeak-ng-data
	# before spawning koko - correct for a portable bundle that keeps its
	# data beside the binary, meaningless for a distro install where the
	# binary is in /usr/bin. A plain ${VAR:-default} would honour that dead
	# path and change nothing, which is exactly what happened on the first
	# attempt at this fix. Testing for phontab mirrors what espeak-ng
	# itself probes, so a genuine user override still wins and only a
	# broken value is replaced. verified 2026-07-28
	exeinto /usr/libexec/${PN}
	doexe target/release/koko

	newbin - koko <<-EOF
		#!/bin/sh
		# espeak-ng probes "\$ESPEAK_DATA_PATH/espeak-ng-data" then
		# "\$ESPEAK_DATA_PATH" itself; accept either, else point at the
		# system data from app-accessibility/espeak-ng.
		if [ ! -f "\${ESPEAK_DATA_PATH}/espeak-ng-data/phontab" ] &&
		   [ ! -f "\${ESPEAK_DATA_PATH}/phontab" ]; then
			ESPEAK_DATA_PATH=/usr/share
		fi
		export ESPEAK_DATA_PATH
		exec /usr/libexec/${PN}/koko "\$@"
	EOF
}

pkg_postinst() {
	elog ""
	elog "Kokoros installed.  Binary: /usr/bin/koko"
	elog ""
	elog "Model + voice files are NOT shipped with this ebuild — they total"
	elog "~330 MB and need to be downloaded from HuggingFace before first use."
	elog ""
	elog "Quickest path: drop them into ~/.cache/kokoros/ (or any dir):"
	elog "  mkdir -p ~/.cache/kokoros/checkpoints ~/.cache/kokoros/data"
	elog "  curl -L -o ~/.cache/kokoros/checkpoints/kokoro-v1.0.onnx \\"
	elog "    https://github.com/nazdridoy/kokoro-tts/releases/download/v1.0.0/kokoro-v1.0.onnx"
	elog "  curl -L -o ~/.cache/kokoros/data/voices-v1.0.bin \\"
	elog "    https://github.com/nazdridoy/kokoro-tts/releases/download/v1.0.0/voices-v1.0.bin"
	elog ""
	elog "Then run from that directory, or pass --model / --voices-bin paths."
	elog ""
	elog "/usr/bin/koko is a wrapper that sets ESPEAK_DATA_PATH=/usr/share so"
	elog "the phoneme tables from app-accessibility/espeak-ng are found. The"
	elog "real binary is /usr/libexec/${PN}/koko; calling it directly without"
	elog "that variable produces a fixed ~0.5s stub for any input, silently"
	elog "and with exit status 0."
}

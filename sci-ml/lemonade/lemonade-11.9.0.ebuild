# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop systemd

DESCRIPTION="Local AI server: optimized LLM inference on AMD NPU + GPU"
HOMEPAGE="
	https://lemonade-server.ai/
	https://github.com/lemonade-sdk/lemonade
"
SRC_URI="https://github.com/lemonade-sdk/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="openrc system-fastflowlm system-kokoro system-llamacpp system-rocm system-sdcpp system-therock system-whispercpp systemd tauri webui"

# Only one system ROCm source can define ROCM_PATH.
REQUIRED_USE="?? ( system-rocm system-therock )"

# Missing cpp-httplib pkg-config metadata and optional libwebsockets cause
# upstream FetchContent downloads at configure time.
PROPERTIES="live"
RESTRICT="network-sandbox"

# Keep the systemd account/state across USE changes; OpenRC uses LEMONADE_USER.
# Linux always links libdrm_amdgpu; require its flag. verified 2026-07-18
# backend_versions.json maps TheRock 7.14 to 10.0, so <7.15 excludes 10.x.
# verified 2026-09-02
# brotli is macOS-only; zstd-1.5.5 is upstream's floor. verified 2026-09-02
RDEPEND="
	>=app-arch/zstd-1.5.5:=
	>=dev-cpp/cli11-2.4.2
	>=dev-cpp/cpp-httplib-0.26.0
	>=dev-cpp/nlohmann_json-3.11.3
	>=net-libs/libwebsockets-4.3.3
	>=net-misc/curl-8.5.0
	sys-libs/libcap
	x11-libs/libdrm[video_cards_amdgpu]
	acct-user/lemonade
	acct-group/lemonade
	system-fastflowlm? ( sci-ml/fastflowlm )
	system-llamacpp? ( sci-misc/llama-cpp )
	system-whispercpp? ( app-accessibility/whisper-cpp )
	system-sdcpp? ( sci-misc/stable-diffusion-cpp )
	system-kokoro? ( sci-ml/kokoros )
	system-rocm? ( dev-util/hip )
	system-therock? ( >=dev-util/therock-bin-7.14.0 <dev-util/therock-bin-7.15 )
	webui? (
		app-misc/jq
		x11-misc/xdg-utils
	)
	tauri? (
		net-libs/webkit-gtk:4.1
		x11-libs/gtk+:3
		net-libs/libsoup:3.0
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/cmake-3.12
	virtual/pkgconfig
	system-fastflowlm? ( app-misc/jq )
	system-llamacpp? ( app-misc/jq )
	system-whispercpp? ( app-misc/jq )
	system-sdcpp? ( app-misc/jq )
	system-kokoro? ( app-misc/jq )
	webui? ( net-libs/nodejs[npm] )
	tauri? (
		net-libs/nodejs[npm]
		|| ( dev-lang/rust dev-lang/rust-bin )
	)
"

src_prepare() {
	cmake_src_prepare

	# Gentoo lacks the .pc file used for cpp-httplib detection. Repin the fallback
	# from a CMake-4-broken tag to compatible v0.38.0; match either SHA or tag.
	# verified 2026-09-02
	sed -i \
		-e '/FetchContent_Declare(httplib/,/GIT_TAG/ s|GIT_TAG .*|GIT_TAG v0.38.0|' \
		CMakeLists.txt || die
}

src_configure() {
	# webui uses npm and its launcher requires jq and xdg-open.
	# verified 2026-07-16
	# BUILD_TAURI_APP builds during configure before CMakeCache exists; build its
	# independent target later and install it manually.
	# Use /usr because upstream's resource lookup does not support /opt/lemonade.
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DBUILD_WEB_APP=$(usex webui ON OFF)
		-DBUILD_TAURI_APP=OFF
		# Upstream's distro-packaging path; skips unshipped test binaries.
		-DBUILD_TESTING=OFF
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	# This standalone target is not part of all.
	if use tauri; then
		cmake_src_compile tauri-app
	fi
}

src_install() {
	cmake_src_install

	# Do not ship the FetchContent dependency's private static archive.
	find "${ED}" -name 'libwebsockets.a' -delete || die

	# Upstream installs systemd files unconditionally. Remove them when disabled;
	# OpenRC reads a different secrets file, and examples also contain non-systemd
	# samples. Recheck exact paths on bumps. verified 2026-08-27
	if ! use systemd; then
		# Unit directories include EPREFIX; pair them with D, not ED.
		rm "${D}$(systemd_get_systemunitdir)/lemond.service" || die
		rm "${D}$(systemd_get_userunitdir)/lemond.service" || die
		rm "${ED}/usr/lib/sysusers.d/lemonade.conf" || die
		rm "${ED}/etc/default/lemond" || die
		rm "${ED}/usr/share/lemonade-server/examples/migrate-to-systemd.sh" || die
		rmdir "${ED}/usr/share/lemonade-server/examples" 2>/dev/null || true
	fi

	if use openrc; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	fi

	# Point services at system ROCm instead of downloading TheRock. The dependency
	# constrains therock-bin; manual launches still need ROCM_PATH.
	# verified 2026-07-16
	local rocm_path=
	use system-rocm && rocm_path="/usr"
	use system-therock && rocm_path="/opt/therock-bin"
	if [[ -n ${rocm_path} ]]; then
		if use openrc; then
			sed -i -e "s|^#\?LEMONADE_ROCM_PATH=.*|LEMONADE_ROCM_PATH=\"${rocm_path}\"|" \
				"${ED}/etc/conf.d/${PN}" || die
		fi
		if use systemd; then
			printf '[Service]\nEnvironment=ROCM_PATH=%s\n' "${rocm_path}" \
				> "${T}/10-rocm-path.conf" || die
			local unitdir
			for unitdir in "$(systemd_get_systemunitdir)" "$(systemd_get_userunitdir)"; do
				insinto "${unitdir#"${EPREFIX}"}/lemond.service.d"
				newins "${T}/10-rocm-path.conf" 10-rocm-path.conf
			done
		fi
	fi

	# Route fetch-by-default backends to packaged binaries. Set both backend and
	# its matching *_bin: "auto" otherwise ignores the path. whispercpp has only
	# cpu_bin; kokoro and flm have no backend selector. These keys route binaries,
	# not GPU implementations, so do not add backend USE constraints. Guard each
	# section before jq can create a misplaced key. verified 2026-07-12
	local -a jqf=() sections=()
	if use system-llamacpp; then
		jqf+=( '.llamacpp.backend="vulkan" | .llamacpp.vulkan_bin="/usr/bin/llama-server"' )
		sections+=( llamacpp )
	fi
	if use system-whispercpp; then
		jqf+=( '.whispercpp.backend="cpu" | .whispercpp.cpu_bin="/usr/bin/whisper-server"' )
		sections+=( whispercpp )
	fi
	if use system-sdcpp; then
		jqf+=( '.sdcpp.backend="vulkan" | .sdcpp.vulkan_bin="/usr/bin/sd-server"' )
		sections+=( sdcpp )
	fi
	if use system-kokoro; then
		jqf+=( '.kokoro.cpu_bin="/usr/bin/koko"' )
		sections+=( kokoro )
	fi
	if use system-fastflowlm; then
		# PATH is ignored without prefer_system; pin npu_bin to prevent a download.
		# verified 2026-07-25
		jqf+=( '.flm.npu_bin="/usr/bin/flm"' )
		sections+=( flm )
	fi
	if [[ ${#jqf[@]} -gt 0 ]]; then
		# Patch the config seed, not its byte-identical resources copy.
		# verified 2026-07-12 with a fresh config
		local def="${ED}/usr/share/lemonade/defaults.json"
		local s
		for s in "${sections[@]}"; do
			jq -e "has(\"${s}\")" "${def}" >/dev/null \
				|| die "defaults.json has no '${s}' section; re-audit the reuse pin"
		done
		local filter
		printf -v filter '%s | ' "${jqf[@]}"
		jq "${filter% | }" "${def}" > "${T}/defaults.json" || die
		mv "${T}/defaults.json" "${def}" || die
	fi

	if use tauri; then
		# Upstream's configure-time install rules are unusable; install manually.
		dobin "${BUILD_DIR}/app/lemonade-app"
		domenu "${S}/data/lemonade-app.desktop"
		newicon -s scalable "${S}/src/app/assets/logo.svg" lemonade-app.svg
	fi
}

pkg_postinst() {
	elog ""
	elog "Lemonade ${PV} installed. lemond binds 127.0.0.1:13305 (loopback)"
	elog "by default; expose it beyond localhost only behind API-key auth"
	elog "(LEMONADE_API_KEY) or an SSH tunnel / WireGuard."
	elog ""
	ewarn "Privacy: at startup lemond sends a UDP presence broadcast on LAN"
	ewarn "(RFC1918) interfaces -- on by default, and it fires even with the"
	ewarn "loopback bind. Disable it by setting broadcast to false in"
	ewarn "~/.cache/lemonade/config.json (11.7.0 renamed the old no_broadcast"
	ewarn "key to broadcast, inverting the sense)."
	elog ""
	elog "Data lives under ~/.cache/lemonade (config + models) and"
	elog "~/.cache/huggingface (model cache + HF_TOKEN if set); model pulls"
	elog "fetch from HuggingFace over the network."
	elog ""
	if ! use system-sdcpp; then
		ewarn "Disk (AMD/ROCm): the first image (sd-cpp) request makes lemond"
		ewarn "download AMD's TheRock ROCm runtime into ~/.cache/lemonade --"
		ewarn "~3 GB compressed, >7 GB unpacked, on top of the model. Avoid it:"
		ewarn "  - USE=system-sdcpp routes sd-cpp to the portage /usr/bin/sd-server"
		ewarn "    (sci-misc/stable-diffusion-cpp) -- no runtime fetch. Recommended."
		ewarn "  - Else set ROCM_PATH=/usr: lemond links its ROCm backend against"
		ewarn "    the system ROCm and fetches only the ~228 MB backend binary,"
		ewarn "    not TheRock. The OpenRC service sets this by default; export it"
		ewarn "    yourself for a manual or systemd launch."
		ewarn "acestep/thinksound (audio) have no system-* route yet and share"
		ewarn "this -- ROCM_PATH covers them too."
		ewarn ""
	fi
	elog "Quick start (manual):"
	elog "  lemond                   # start the server (port 13305 by default)"
	elog "  lemonade run <model>     # CLI client"
	elog ""
	if use webui; then
		elog "Web UI: lemond serves the bundled React app at the server root,"
		elog "e.g. http://127.0.0.1:13305/ -- open it in a browser. It shares the"
		elog "API's bind, so it is loopback-only unless you widen LEMONADE_HOST."
		elog "A 'lemonade-web-app' launcher (+ \"Lemonade Web App\" menu entry)"
		elog "that opens the UI in your browser is installed too; start lemond first."
		elog ""
	fi
	if use tauri; then
		elog "Desktop app: run 'lemonade-app' (or launch \"Lemonade App\" from"
		elog "your menu) for the same UI in a native window. It is a client for"
		elog "a lemond server, so start lemond (or the service) first."
		elog ""
	fi
	if use openrc; then
		elog "OpenRC service (supervise-daemon; auto-restart on crash):"
		elog "  edit /etc/conf.d/lemonade and set LEMONADE_USER (required)"
		elog "  the --host default (127.0.0.1) keeps it loopback-only"
		elog "  rc-service lemonade start"
		elog "  rc-update add lemonade default       # auto-start at boot"
		elog ""
	fi
	if use systemd; then
		elog "systemd service (runs as the dedicated 'lemonade' user):"
		elog "  systemctl enable --now lemond          # system-wide, or"
		elog "  systemctl --user enable --now lemond   # per-user"
		elog "  host/port live in config.json, not env vars; HF_TOKEN and"
		elog "  LEMONADE_API_KEY go in /etc/default/lemond"
		elog ""
	fi
	if use system-llamacpp || use system-whispercpp || use system-sdcpp || use system-kokoro; then
		elog "system-* backends: lemond reuses portage-managed binaries instead"
		elog "of fetching prebuilts into ~/.cache/lemonade/ at runtime --"
		use system-llamacpp   && elog "  llamacpp   -> /usr/bin/llama-server   (sci-misc/llama-cpp)"
		use system-whispercpp && elog "  whispercpp -> /usr/bin/whisper-server (app-accessibility/whisper-cpp)"
		use system-sdcpp      && elog "  sdcpp      -> /usr/bin/sd-server      (sci-misc/stable-diffusion-cpp)"
		use system-kokoro     && elog "  kokoro     -> /usr/bin/koko           (sci-ml/kokoros)"
		elog ""
		ewarn "Which GPU backend runs is decided by the BINARY, not lemond: ggml"
		ewarn "uses the first-registered backend (gpu_device 0). In a build with"
		ewarn "several GPU backends, ROCm/CUDA register before Vulkan, so a"
		ewarn "hip+vulkan or cuda+vulkan binary runs ROCm/CUDA -- not Vulkan."
		ewarn "Build the reused package with the backend you actually want"
		ewarn "(e.g. a vulkan-only build if you want Vulkan)."
		if use system-sdcpp; then
			ewarn "On Ryzen AI, stable-diffusion-cpp[opencl] makes sd-server abort"
			ewarn "at startup (XRT OpenCL ICD GGML_ASSERT) -- build it with -opencl."
		fi
		elog ""
		elog "The shipped defaults pin the vulkan routing (cpu for whisper/kokoro);"
		elog "new configs pick these up automatically. For an existing config, or"
		elog "if you built a different backend, set the bin (and matching backend):"
		elog "  lemonade config set llamacpp.backend=vulkan llamacpp.vulkan_bin=/usr/bin/llama-server"
		elog "lemond does not verify these paths; if the package is removed the"
		elog "backend's model loads fail."
		elog ""
	fi
	if use system-rocm || use system-therock; then
		local _rp=/usr
		use system-therock && _rp=/opt/therock-bin
		elog "ROCm runtime: lemond is pointed at ${_rp} (ROCM_PATH), so its"
		elog "rocm-stable image/audio backends reuse that ROCm instead of"
		elog "downloading AMD's ~3 GB TheRock runtime. The OpenRC service (confd)"
		elog "and the systemd units (drop-in) set it automatically; for a MANUAL"
		elog "launch, export it yourself:"
		elog "  export ROCM_PATH=${_rp}"
		if use system-therock; then
			elog "dev-util/therock-bin must major.minor-match lemond's pinned ROCm"
			elog "(7.14); the RDEPEND holds it to the 7.14 line. A mismatched version"
			elog "file makes lemond reject it and download TheRock anyway."
		fi
		elog ""
	fi
	if use system-fastflowlm; then
		elog "system-fastflowlm: the NPU runtime is provided by sci-ml/fastflowlm."
		elog "The config seed pins flm.npu_bin=/usr/bin/flm, so a fresh config"
		elog "reuses it with no runtime fetch. A bare flm on PATH is NOT auto-used"
		elog "-- 11.x gates PATH resolution behind flm.prefer_system -- so an"
		elog "EXISTING ~/.cache/lemonade/config.json (which the rebuild does not"
		elog "touch) still shows the NPU backend as \"supported but not installed\""
		elog "until you set the pin by hand:"
		elog "  lemonade config set flm.npu_bin=/usr/bin/flm"
		elog "Confirm 'flm validate' passes before lemonade drives the NPU backend."
	else
		ewarn "Without USE=system-fastflowlm, lemond 11.x auto-downloads the FastFlowLM"
		ewarn "(flm) NPU runtime into ~/.cache/lemonade on first NPU use. It resolves"
		ewarn "flm as flm.npu_bin override -> PATH (only when flm.prefer_system is"
		ewarn "set) -> download; a bare flm on PATH is NOT used by default. Enable"
		ewarn "USE=system-fastflowlm (sci-ml/fastflowlm), which pins"
		ewarn "flm.npu_bin=/usr/bin/flm, to reuse the packaged runtime and skip the fetch."
	fi
}

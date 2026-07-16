# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 desktop systemd

DESCRIPTION="Local AI server: optimized LLM inference on AMD NPU + GPU"
HOMEPAGE="
	https://lemonade-server.ai/
	https://github.com/lemonade-sdk/lemonade
"

EGIT_REPO_URI="https://github.com/lemonade-sdk/${PN}.git"

LICENSE="Apache-2.0"
SLOT="0"
# No KEYWORDS for live ebuild.
IUSE="openrc system-fastflowlm system-kokoro system-llamacpp system-rocm system-sdcpp system-therock system-whispercpp systemd tauri webui"

# system-rocm and system-therock both point lemond's ROCm runtime at a system
# path via ROCM_PATH (skipping the TheRock download); at most one applies.
REQUIRED_USE="?? ( system-rocm system-therock )"

# Upstream's CMake detects nlohmann_json/curl/zstd/CLI11 via pkg-config or
# find_path, but cpp-httplib detection requires a .pc file (which ::gentoo
# doesn't ship) and libwebsockets isn't required at runtime in many ::gentoo
# stacks — so both fall back to FetchContent at configure time. Allow
# network access for that, matching sci-ml/fastflowlm's pattern.
PROPERTIES="live"
RESTRICT="network-sandbox"

# acct-user/lemonade backs the systemd unit's User=lemonade. Pulled
# unconditionally (matching sci-ml/ollama's acct-user) so toggling
# USE=systemd can't orphan the /var/lib/lemonade state dir; the OpenRC
# service ignores this account and runs as LEMONADE_USER instead.
RDEPEND="
	app-arch/brotli:=
	app-arch/zstd:=
	>=dev-cpp/cli11-2.4.2
	>=dev-cpp/cpp-httplib-0.26.0
	>=dev-cpp/nlohmann_json-3.11.3
	>=net-libs/libwebsockets-4.3.3
	>=net-misc/curl-8.5.0
	sys-libs/libcap
	acct-user/lemonade
	acct-group/lemonade
	system-fastflowlm? ( sci-ml/fastflowlm )
	system-llamacpp? ( sci-misc/llama-cpp )
	system-whispercpp? ( app-accessibility/whisper-cpp )
	system-sdcpp? ( sci-misc/stable-diffusion-cpp )
	system-kokoro? ( sci-ml/kokoros )
	system-rocm? ( dev-util/hip )
	system-therock? ( >=dev-util/therock-bin-7.13.0 <dev-util/therock-bin-7.14 )
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

	# ::gentoo's cpp-httplib ships no pkg-config .pc, so upstream's detection
	# misses it and the build FetchContents cpp-httplib. The pinned version's
	# own CMakeLists.txt has a malformed
	# `if(CMAKE_SYSTEM_NAME MATCHES "Windows" AND VERSION_LESS 10.0.0)` which
	# CMake 4 rejects ("Unknown arguments specified"). Repin the httplib fetch
	# to v0.38.0 -- the CMake-4-clean version we ship as dev-cpp/cpp-httplib.
	# Upstream varies the GIT_TAG between `v${MIN_HTTPLIB_VERSION}` and a bare
	# commit SHA across HEAD, so rewrite the httplib FetchContent_Declare
	# block's GIT_TAG whatever its form rather than matching a fixed string
	# (the release ebuilds pin the stable `v${MIN_HTTPLIB_VERSION}` form
	# directly). confirmed at HEAD 2026-07-15
	sed -i \
		-e '/FetchContent_Declare(httplib/,/GIT_TAG/ s|GIT_TAG .*|GIT_TAG v0.38.0|' \
		CMakeLists.txt || die
}

src_configure() {
	# BUILD_WEB_APP (USE=webui) builds the bundled React SPA that lemond
	# serves at the server root (/); without it lemond serves a static
	# "built without a web app" placeholder there. Since v11.0.0 USE=webui
	# also installs a lemonade-web-app browser launcher (/usr/bin + a
	# .desktop menu entry + /usr/share/pixmaps icon) via cmake_src_install;
	# that launcher runs under `set -e` and pipes `lemonade status --json`
	# through jq for port discovery (which aborts the launcher if jq is
	# absent), falling back to xdg-open to open the browser -- hence the
	# webui? ( app-misc/jq x11-misc/xdg-utils ) RDEPEND. verified 2026-07-16
	# The build runs `npm ci`
	# (fetching the JS dependency tree from the npm registry — hence the
	# network build, already the case here for FetchContent) then webpack.
	# net-libs/nodejs provides node+npm. Upstream's USE_SYSTEM_NODEJS_MODULES
	# path (system webpack + distro JS libs under /usr/share/nodejs) would
	# avoid the npm fetch, but ::gentoo doesn't package those modules, so the
	# npm fetch is the only viable route. USE=tauri additionally builds the
	# Tauri desktop app -- a native webkit2gtk window wrapping the same
	# renderer -- but BUILD_TAURI_APP stays OFF deliberately: upstream's ON
	# path builds the app during the *configure* step (fails on a clean build
	# -- no CMakeCache.txt yet) and gates its install() rules on the binary
	# already existing at configure time. The `tauri-app` custom target is
	# defined whenever node+npm+cargo are found (independent of this flag), so
	# src_compile builds it and src_install places the artifacts by hand.
	#
	# Upstream defaults to /opt as the prefix for Linux, but lemond's
	# get_resource_path() searches /usr/share/lemonade-server/ and
	# /opt/share/lemonade-server/ — the /opt branch wants resources at
	# the *top* of /opt, not under /opt/lemonade/. /usr matches their
	# .deb/.rpm layout and lets the resources resolve cleanly.
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DBUILD_WEB_APP=$(usex webui ON OFF)
		-DBUILD_TAURI_APP=OFF
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	# Build the Tauri desktop app. `tauri-app` is a standalone CMake target
	# (not part of `all`): it runs `npm ci` in src/app then
	# `tauri build --no-bundle` (webpack renderer + cargo host, LTO release).
	# The npm + crates.io fetches ride the same network build the rest of the
	# ebuild already needs. The built binary lands at ${BUILD_DIR}/app/.
	if use tauri; then
		cmake_src_compile tauri-app
	fi
}

src_install() {
	cmake_src_install

	# FetchContent-built libwebsockets installs its static archive into
	# the prefix; we don't need it shipped (lemond linked against it
	# statically already, no consumers).
	find "${ED}" -name 'libwebsockets.a' -delete || die

	# Upstream's CPack "if(UNIX AND NOT APPLE)" block unconditionally installs
	# a full systemd payload: the system + user lemond.service units, a
	# sysusers.d snippet, an /etc/lemonade/conf.d secrets EnvironmentFile, and
	# a migrate-to-systemd helper. Gate the lot behind USE=systemd -- the
	# system unit runs as User=lemonade (provided by acct-user/lemonade).
	# Without USE=systemd, strip all of it so OpenRC (or unit-less) installs
	# don't carry dead systemd files. zz-secrets.conf especially is worse than
	# dead on OpenRC: the init reads /etc/conf.d/lemonade, so an API key
	# dropped in /etc/lemonade/conf.d/ is silently ignored (no auth) rather
	# than applied. sysusers.d/lemonade.conf is redundant with the unconditional
	# acct-user/lemonade; keep it under systemd (idempotent), drop it here.
	#
	# The paths below mirror what upstream's CMake installs at HEAD (v11.x).
	# On a HEAD bump, re-confirm each basename/dir -- a rename upstream turns
	# any of these `rm ... || die` into a build failure. NB: since v11.0.0 the
	# examples/ dir also carries non-systemd API samples, so the rmdir below
	# no-ops (dir non-empty) -- only migrate-to-systemd.sh is systemd-specific
	# and stripped; the samples ship regardless of USE. verified 2026-07-16
	if ! use systemd; then
		# systemd_get_*unitdir already carries EPREFIX, so pair it with
		# ${D} (not ${ED}) to avoid a doubled prefix.
		rm "${D}$(systemd_get_systemunitdir)/lemond.service" || die
		rm "${D}$(systemd_get_userunitdir)/lemond.service" || die
		rm "${ED}/usr/lib/sysusers.d/lemonade.conf" || die
		rm "${ED}/etc/lemonade/conf.d/zz-secrets.conf" || die
		rm "${ED}/usr/share/lemonade-server/examples/migrate-to-systemd.sh" || die
		rmdir "${ED}/usr/share/lemonade-server/examples" 2>/dev/null || true
		rmdir "${ED}/etc/lemonade/conf.d" "${ED}/etc/lemonade" 2>/dev/null || true
	fi

	if use openrc; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	fi

	# system-rocm / system-therock bake lemond's ROCm-runtime source into the
	# service so it reuses a system ROCm via ROCM_PATH instead of downloading
	# AMD's TheRock. system-rocm -> /usr (Gentoo's ROCm; blind-trusted, no
	# version file); system-therock -> /opt/therock-bin (dev-util/therock-bin,
	# whose .info/version must major.minor-match lemond's backend_versions.json
	# therock.version 7.13 -- the RDEPEND holds it to the 7.13 line). OpenRC
	# gets the confd value; systemd gets an Environment drop-in on both units.
	# A manual launch still needs the export (see pkg_postinst). verified 2026-07-16
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

	# Repoint lemond's fetch-by-default backends at the portage-managed
	# binaries so it reuses them instead of downloading an upstream prebuilt
	# into ~/.cache/lemonade/bin/ at runtime. lemond seeds a fresh config.json
	# from the config-seed defaults file (the ${def} set below -- NOT the
	# byte-identical resources/ copy): new installs reuse automatically,
	# existing users run `lemonade config set` (see pkg_postinst).
	#
	# Each section pins `backend` AND the matching <backend>_bin. Pinning the
	# backend is REQUIRED -- lemond's "auto" resolves per-backend and only reads
	# the resolved backend's *_bin, so setting *_bin alone is a silent no-op
	# that still fetches. But the pinned value is only lemond's routing to the
	# binary; it does NOT pick the GPU. Once launched, the binary uses whichever
	# ggml backend it registered first (gpu_device 0) -- on a multi-backend
	# build ROCm/CUDA register before Vulkan, so the deps carry no backend USE
	# constraint and pkg_postinst tells the user to build the package with the
	# backend they want. whispercpp's section has no vulkan_bin key (only
	# cpu/npu), so it MUST route via cpu_bin whatever the build -- do not
	# "correct" it to vulkan. kokoro has no `backend` key at all (CPU-only).
	# backend/*_bin keys recur across sections -> edit by key with jq, not sed.
	# The has() guard fails the build loudly if a future lemonade renames or
	# moves a section (jq would otherwise auto-vivify a stray key and lemond
	# would silently fall back to fetching). Routing is by config key, not a
	# capability probe -- a cpu/vulkan pin launches a cuda-built server that
	# still runs on its own GPU (device 0). End-to-end reuse (fresh config, no
	# fetch, GPU device 0) cross-checked on a CUDA host. verified 2026-07-12
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
	if [[ ${#jqf[@]} -gt 0 ]]; then
		# Pin the CONFIG-SEED template, /usr/share/lemonade/defaults.json --
		# NOT /usr/share/lemonade-server/resources/defaults.json. lemond ships
		# BOTH (byte-identical) but seeds a fresh ~/.cache/lemonade/config.json
		# only from the former; edits to the resources/ copy never reach a
		# fresh config, so reuse silently no-ops and fetches. Identical content
		# makes the wrong file easy to pick -- do not "simplify" to the
		# resources/ path. verified 2026-07-12 (sentinel-seeded a fresh config)
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
		# Install the Tauri desktop binary by hand (upstream's install() rules
		# are unusable -- see src_configure). The .desktop launches it as
		# `lemonade-app` (a URL-scheme handler for lemonade://), so dobin to
		# /usr/bin; the icon resolves Icon=lemonade-app from hicolor.
		dobin "${BUILD_DIR}/app/lemonade-app"
		domenu "${S}/data/lemonade-app.desktop"
		newicon -s scalable "${S}/src/app/assets/logo.svg" lemonade-app.svg
	fi
}

pkg_postinst() {
	elog ""
	elog "Lemonade ${PV} (live) installed. lemond binds 127.0.0.1:13305"
	elog "(loopback) by default; expose it beyond localhost only behind API-key"
	elog "auth (LEMONADE_API_KEY) or an SSH tunnel / WireGuard."
	elog ""
	ewarn "Privacy: at startup lemond sends a UDP presence broadcast on LAN"
	ewarn "(RFC1918) interfaces -- on by default, and it fires even with the"
	ewarn "loopback bind. Disable it by setting no_broadcast to true in"
	ewarn "~/.cache/lemonade/config.json."
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
	elog "Live ebuild -- rebuild via: emerge --oneshot =sci-ml/lemonade-9999"
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
		elog "  LEMONADE_API_KEY go in /etc/lemonade/conf.d/*.conf"
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
			elog "(7.13); the RDEPEND holds it to the 7.13 line. A mismatched version"
			elog "file makes lemond reject it and download TheRock anyway."
		fi
		elog ""
	fi
	if use system-fastflowlm; then
		elog "USE=system-fastflowlm enabled — the NPU runtime is provided by"
		elog "sci-ml/fastflowlm (flm on PATH; lemond resolves it there, no"
		elog "runtime fetch). Confirm 'flm validate' passes before lemonade"
		elog "drives the NPU backend."
	else
		ewarn "Without USE=system-fastflowlm, lemond auto-downloads the FastFlowLM"
		ewarn "(flm) NPU runtime into ~/.cache/lemonade on first NPU use -- it"
		ewarn "resolves flm as config-override -> PATH -> download, so a packaged"
		ewarn "flm on PATH wins. Enable USE=system-fastflowlm (sci-ml/fastflowlm) to"
		ewarn "use the packaged runtime and skip that fetch."
	fi
}

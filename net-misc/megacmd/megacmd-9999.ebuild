# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic git-r3 shell-completion

DESCRIPTION="Command Line Interactive and Scriptable Application to access MEGA"
HOMEPAGE="https://mega.io/cmd https://github.com/meganz/MEGAcmd"
EGIT_REPO_URI="https://github.com/meganz/MEGAcmd.git"
# The SDK is built from the submodule commit master pins, as in the
# release ebuild.
EGIT_SUBMODULES=( sdk )

# The SDK is BSD-2; its bundled ccronexpr is Apache-2.0, csv and evt-tls MIT.
LICENSE="BSD-2 Apache-2.0 MIT"
SLOT="0"
IUSE="+fuse pcre"

DEPEND="
	dev-db/sqlite:3
	dev-libs/crypto++:=
	dev-libs/icu:=
	dev-libs/libsodium:=
	dev-libs/libutf8proc:=
	dev-libs/libuv:=
	dev-libs/openssl:=
	dev-libs/zxcvbn-c
	net-libs/http-parser:=
	net-misc/curl
	sys-libs/readline:=
	virtual/zlib:=
	fuse? ( sys-fs/fuse:3= )
	pcre? ( dev-libs/libpcre:3[cxx] )
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

# The newest release's patches; master may need them refreshed.
PATCHES=(
	"${FILESDIR}"/${PN}-2.7.0-no-git-no-vcpkg.patch
	"${FILESDIR}"/${PN}-2.7.0-gentoo-install-layout.patch
	"${FILESDIR}"/${PN}-2.7.0-pcrecpp.patch
	"${FILESDIR}"/${PN}-2.7.0-missing-links.patch
	"${FILESDIR}"/${PN}-2.7.0-sdk-system-libs.patch
	"${FILESDIR}"/${PN}-2.7.0-sdk-cryptopp-pc.patch
)

src_prepare() {
	# vcpkg port overlays, unused with system libraries
	rm -r sdk/cmake/vcpkg_overlay_ports || die
	cmake_src_prepare
}

src_configure() {
	# Upstream packages build RelWithDebInfo, whose stock flags carry
	# -DNDEBUG; cmake.eclass empties them. Without it the SDK's asserts
	# call mutex methods that exist only with DEBUG and fail to compile
	# (sdk#2679).
	append-cppflags -DNDEBUG

	local sdk_commit
	sdk_commit=$(git -C sdk rev-parse --short HEAD) || die

	local mycmakeargs=(
		# SDKlib has no install rules; link it into the binaries.
		-DBUILD_SHARED_LIBS=OFF
		-DSDK_COMMIT_HASH="${sdk_commit}"
		-DVCPKG_ROOT=
		# FULL_REQS=ON requires PDFium, FFmpeg and MediaInfo for previews
		# and media attributes; with it off they default to off.
		-DFULL_REQS=OFF
		-DUSE_FREEIMAGE=OFF
		-DENABLE_ISOLATED_GFX=OFF
		-DENABLE_MEGACMD_TESTS=OFF
		-DUSE_PCRE=$(usex pcre)
		-DWITH_FUSE=$(usex fuse)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	insinto /usr/lib/sysctl.d
	newins - 99-megacmd-inotify-limit.conf <<<"fs.inotify.max_user_watches = 524288"

	# One completion script serves every mega-* command; completion is
	# looked up by command name, so alias it to each of them.
	newbashcomp src/client/megacmd_completion.sh mega-cmd
	local f cmds=()
	for f in "${ED}"/usr/bin/mega-*; do
		f=${f##*/}
		[[ ${f} == mega-cmd ]] || cmds+=( "${f}" )
	done
	bashcomp_alias mega-cmd "${cmds[@]}"
}

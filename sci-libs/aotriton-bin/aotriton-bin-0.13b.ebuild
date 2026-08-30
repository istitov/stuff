# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=${PN%*-bin}
MY_P=${MY_PN}-${PV}

DESCRIPTION="Ahead of Time (AOT) Triton Math Library (binary package)"
HOMEPAGE="https://github.com/ROCm/aotriton"

URI_PREFIX="https://github.com/ROCm/${MY_PN}/releases/download/${PV}"
SHIM_URI_PREFIX="${URI_PREFIX}/${MY_P}-manylinux_2_28_x86_64"
IMAGES_URI_PREFIX="${URI_PREFIX}/${MY_P}-images-amd"

# Download libs for all rocm releases (4mb each), but unpack only one.
# 0.13b adds a standalone gfx1250 image (gfx12xx now split gfx120x + gfx1250).
#
# The 6.4/7.0/7.1/7.2 -> 7.14/7.15 gap in upstream's shim set is AMD's release
# renumbering, not missing releases: the 7.14/7.15 line was renamed to ROCm
# 10.0, and dev-util/hip-10.0.0 reports HIP version 7.15.0 (`hipconfig
# --version`). So rocm7.15 IS the shim for hip-10.0, and src_unpack picks the
# archive by the installed hip's $(ver_cut 1-2) -- "10.0" -- hence the rename.
# verified 2026-08-30 against the 0.13b release assets.
SRC_URI="
	${SHIM_URI_PREFIX}-rocm6.4-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.0-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.1-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.2-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.15-shared.tar.gz
		-> ${MY_P}-manylinux_2_28_x86_64-rocm10.0-shared.tar.gz

	amdgpu_targets_gfx90a? ( ${IMAGES_URI_PREFIX}-gfx90a.tar.gz )
	amdgpu_targets_gfx942? ( ${IMAGES_URI_PREFIX}-gfx942.tar.gz )
	amdgpu_targets_gfx950? ( ${IMAGES_URI_PREFIX}-gfx950.tar.gz )

	amdgpu_targets_gfx1100? ( ${IMAGES_URI_PREFIX}-gfx110x.tar.gz )
	amdgpu_targets_gfx1101? ( ${IMAGES_URI_PREFIX}-gfx110x.tar.gz )
	amdgpu_targets_gfx1102? ( ${IMAGES_URI_PREFIX}-gfx110x.tar.gz )
	amdgpu_targets_gfx1103? ( ${IMAGES_URI_PREFIX}-gfx110x.tar.gz )
	amdgpu_targets_gfx1150? ( ${IMAGES_URI_PREFIX}-gfx115x.tar.gz )
	amdgpu_targets_gfx1151? ( ${IMAGES_URI_PREFIX}-gfx115x.tar.gz )

	amdgpu_targets_gfx1200? ( ${IMAGES_URI_PREFIX}-gfx120x.tar.gz )
	amdgpu_targets_gfx1201? ( ${IMAGES_URI_PREFIX}-gfx120x.tar.gz )
	amdgpu_targets_gfx1250? ( ${IMAGES_URI_PREFIX}-gfx1250.tar.gz )
"
S="${WORKDIR}/${MY_PN}"

LICENSE="MIT"
SLOT="0/${PV%b}"

KEYWORDS="-* ~amd64"

IUSE_TARGETS=(
	gfx90a
	gfx942
	gfx950
	gfx1100
	gfx1101
	gfx1102
	gfx1103
	gfx1150
	gfx1151
	gfx1200
	gfx1201
	gfx1250
)
IUSE_TARGETS=( "${IUSE_TARGETS[@]/#/amdgpu_targets_}" )
IUSE="${IUSE_TARGETS[*]/#/+}"

RESTRICT="strip"
QA_PREBUILT="usr/lib*/libaotriton_v2.so.*"

# glibc & gcc:  linked with manylinux version, no rebuild required
# xz-utils:     used to decompress lzma blobs with kernels in runtime
# dev-util/hip: must be in sync with SRC_URI
#               and trigger reinstall on sub-slot change.
#               Shims wired here are rocm6.4/7.0/7.1/7.2 and rocm7.15 (= ROCm
#               10.0 after the renumbering), so floor hip at 6.4 and cap below
#               11. There is no shim for a hip between 7.3 and 9.x, and none
#               exists to package -- src_unpack would find no match and unpack
#               nothing, so keep the cap tied to what SRC_URI actually lists.
RDEPEND="
	!!sci-libs/aotriton
	sys-libs/glibc
	sys-devel/gcc
	app-arch/xz-utils
	>=dev-util/hip-6.4:=
	<dev-util/hip-11:=
"

src_unpack() {
	# *-rocmX.X-shared.tar.gz archives with host code have the same structure,
	# so decompression of all of them would overwrite files of each other.
	# Instead we decompress only one version for current dev-util/hip.
	local hippkg=$(best_version dev-util/hip)
	local rocmver="$(ver_cut 1-2 "${hippkg#*hip-}")"
	local file shim_found=
	for file in ${A}; do
		if [[ $file == *-rocm${rocmver}-*.tar.gz ]]; then
			shim_found=1
			unpack "${file}"
		elif [[ $file == *-gfx*.tar.gz ]]; then
			unpack "${file}"
		fi
	done

	# The RDEPEND range is wider than the set of shims SRC_URI lists, because
	# upstream skips HIP versions. Without this, an unmatched version unpacks
	# only the gfx images, and the missing libaotriton_v2.so is not noticed
	# until src_install has already produced a package with no library in it.
	[[ -n ${shim_found} ]] ||
		die "no aotriton shim for dev-util/hip-${rocmver}; SRC_URI lists rocm6.4/7.0/7.1/7.2 and rocm7.15 (as rocm10.0)"
}

src_install() {
	doheader -r include/*

	insinto /usr/$(get_libdir)
	doins -r lib/*
}

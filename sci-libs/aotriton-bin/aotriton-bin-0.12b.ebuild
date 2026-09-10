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

# Fetch every ROCm shim (4 MiB each), but unpack only the installed version.
# 0.12b dropped the rocm6.3 shim; images split gfx11xx -> gfx110x + gfx115x.
SRC_URI="
	${SHIM_URI_PREFIX}-rocm6.4-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.0-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.1-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.2-shared.tar.gz

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
)
IUSE_TARGETS=( "${IUSE_TARGETS[@]/#/amdgpu_targets_}" )
IUSE="${IUSE_TARGETS[*]/#/+}"

RESTRICT="strip"
QA_PREBUILT="usr/lib*/libaotriton_v2.so.*"

# The manylinux shim needs glibc/GCC; xz decompresses kernel blobs at runtime.
# Keep HIP within the available 6.4-7.2 shims and rebuild on subslot changes.
RDEPEND="
	!!sci-libs/aotriton
	sys-libs/glibc
	sys-devel/gcc
	app-arch/xz-utils
	>=dev-util/hip-6.4:=
	<dev-util/hip-7.3:=
"

src_unpack() {
	# Host-code archives overlap, so unpack only the installed HIP version.
	local hippkg=$(best_version dev-util/hip)
	local rocmver="$(ver_cut 1-2 "${hippkg#*hip-}")"
	local file
	for file in ${A}; do
		[[ $file == *-rocm${rocmver}-*.tar.gz || $file == *-gfx*.tar.gz ]] &&
			unpack "${file}"
	done
}

src_install() {
	doheader -r include/*

	insinto /usr/$(get_libdir)
	doins -r lib/*
}

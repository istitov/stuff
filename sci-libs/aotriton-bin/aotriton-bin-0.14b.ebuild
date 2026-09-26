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

# Fetch all small ROCm shims but unpack only the installed version. ROCm 10
# reports HIP 7.15, and 0.14b was released without a 7.15 shim, so rename the
# 7.14 one to rocm10.0 for selection: it is built against an older HIP than
# the runtime, which is the compatible direction, whereas the 7.16 shim
# assumes a newer HIP than ROCm 10.0 provides. Both link against our HIP, so
# the symbol table cannot distinguish them. gfx1250 has its own image.
# verified 2026-09-21. Upstream added a 7.15 shim to the 0.14b release later
# that day (asset uploaded 2026-09-21 17:43 UTC). 0.14.2b uses its 7.15 shim;
# switching this version would change the rocm10.0 distfile's contents under
# the same name. checked 2026-09-26
SRC_URI="
	${SHIM_URI_PREFIX}-rocm6.4-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.0-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.1-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.2-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.14-shared.tar.gz
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

# manylinux links glibc/gcc; xz decompresses kernels at runtime. HIP's subslot
# forces reinstall, while src_unpack checks this broad range against the sparse
# upstream shim set.
RDEPEND="
	!!sci-libs/aotriton
	sys-libs/glibc
	sys-devel/gcc
	app-arch/xz-utils
	>=dev-util/hip-6.4:=
	<dev-util/hip-11:=
"

src_unpack() {
	# Identically structured shim archives overwrite each other; unpack one.
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

	# Reject HIP versions omitted from upstream's sparse shim set.
	[[ -n ${shim_found} ]] ||
		die "no aotriton shim for dev-util/hip-${rocmver}; SRC_URI lists rocm6.4/7.0/7.1/7.2 and rocm7.14 (as rocm10.0)"
}

src_install() {
	doheader -r include/*

	insinto /usr/$(get_libdir)
	doins -r lib/*
}

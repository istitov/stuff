# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
inherit python-single-r1

DESCRIPTION="ROCm SDK pre-built distribution from TheRock (AMDGPU_TARGETS-selected)"
HOMEPAGE="https://github.com/ROCm/TheRock"

# AMD publishes only a Makeself runfile; GitHub lacks release SDK binaries.
# Extract its shared base and family payload without running the installer;
# $ORIGIN rpaths work under /opt/therock-bin. VERSION says 7.13.0rc2, while AMD
# labels it 7.13.0. MY_BUILD tracks reissued installers.
MY_BUILD="3"
MY_RUN="rocm-installer-${PV}-${MY_BUILD}.run"
SRC_URI="https://repo.radeon.com/rocm/installer/rocm-runfile-installer/rocm-rel-${PV%.*}/${MY_RUN}"
S="${WORKDIR}"

# The SDK combines ROCm subprojects under these licenses; texts ship in share/doc.
LICENSE="MIT BSD Apache-2.0 UoI-NCSA Boost-1.0"
SLOT="0"
KEYWORDS="~amd64"

# Release targets from the runfile. gfx1150/1151/1152 have separate payloads,
# gfx1153 is absent, and the remaining fine arches map to families below.
AMDGPU_ARCHS=(
	gfx1030 gfx1100 gfx1101 gfx1102 gfx1103
	gfx1150 gfx1151 gfx1152
	gfx1200 gfx1201 gfx908 gfx90a gfx942 gfx950
)
IUSE="${AMDGPU_ARCHS[*]/#/amdgpu_targets_}"

# One target may own /opt/therock-bin at a time.
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	^^ ( ${AMDGPU_ARCHS[*]/#/amdgpu_targets_} )
"

# Bundled third-party prebuilt: do not redistribute, mirror, or strip.
RESTRICT="bindist mirror strip"

# Most libraries are vendored as lib/rocm_sysdeps/librocm_sysdeps_*.so; these
# remain system consumers. Recheck with ldd on each bump.
RDEPEND="
	app-arch/zstd:=
	dev-lang/perl
	dev-libs/elfutils
	sys-process/numactl
	virtual/zlib
	virtual/libcrypt:=
	x11-libs/libdrm
	${PYTHON_DEPS}
"

QA_PREBUILT="opt/therock-bin/*"

# Map a fine arch to its release payload.
_therock_family() {
	case $1 in
		gfx1030) echo gfx103x ;;
		gfx110[0-3]) echo gfx110x ;;
		gfx1150) echo gfx1150 ;;
		gfx1151) echo gfx1151 ;;
		gfx1152) echo gfx1152 ;;
		gfx120[01]) echo gfx120x ;;
		gfx908) echo gfx908 ;;
		gfx90a) echo gfx90a ;;
		gfx942) echo gfx94x ;;
		gfx950) echo gfx950 ;;
		*) die "no content family for arch '$1'" ;;
	esac
}

_therock_arch() {
	local a
	for a in "${AMDGPU_ARCHS[@]}"; do
		use "amdgpu_targets_${a}" && { echo "${a}"; return; }
	done
}

src_unpack() {
	local run="${DISTDIR}/${MY_RUN}"
	local arch family
	arch=$(_therock_arch)
	family=$(_therock_family "${arch}")

	# Makeself appends a raw tar; locate it from `filesizes` instead of executing
	# the installer. Dereference Portage's distfile symlink or the offset uses the
	# link length and goes negative.
	local filesizes offset
	filesizes=$(grep -a -m1 '^filesizes=' "${run}") || die "no filesizes marker"
	filesizes=${filesizes#filesizes=\"}
	filesizes=${filesizes%%\"*}
	offset=$(( $(stat -Lc%s "${run}") - filesizes ))

	ebegin "Extracting ROCm content (base + ${family}) for ${arch}"
	tail -c "+$(( offset + 1 ))" "${run}" | tar -xf - -C "${WORKDIR}" \
		"./component-rocm/content-base.tar.xz" \
		"./component-rocm/content-${family}.tar.xz" \
		|| die "runfile payload slice failed"
	tar -xJf "${WORKDIR}/component-rocm/content-base.tar.xz" -C "${WORKDIR}" || die
	tar -xJf "${WORKDIR}/component-rocm/content-${family}.tar.xz" -C "${WORKDIR}" || die
	eend 0
}

src_install() {
	local arch dest="/opt/therock-bin" c
	arch=$(_therock_arch)

	dodir "${dest}"
	# Merge shared and selected-family component roots into one relocatable SDK.
	# Component paths use core-<major.minor>, including for point releases.
	local core="core-${PV%.*}" found=
	for c in "${WORKDIR}"/base/*/rocm/"${core}" \
		"${WORKDIR}/${arch}"/*/rocm/"${core}"; do
		[[ -d ${c} ]] || continue
		cp -a "${c}/." "${ED}${dest}/" || die "merge of ${c} failed"
		found=1
	done
	[[ ${found} ]] || die "no rocm/core-7.13 component trees found for ${arch}"
	fperms 0755 "${dest}"
}

pkg_postinst() {
	elog "TheRock ROCm ${PV} SDK installed to /opt/therock-bin/."
	elog ""
	elog "It coexists with the system ROCm in /usr (no file conflicts). To use"
	elog "TheRock instead of the system ROCm, set per shell:"
	elog ""
	elog "  export ROCM_PATH=/opt/therock-bin"
	elog "  export HIP_PATH=/opt/therock-bin"
	elog "  export PATH=/opt/therock-bin/bin:\${PATH}"
	elog "  export LD_LIBRARY_PATH=/opt/therock-bin/lib:\${LD_LIBRARY_PATH}"
	elog ""
	elog "The GPU target was chosen via AMDGPU_TARGETS at emerge time; re-emerge"
	elog "with a different single amdgpu_targets_* value to switch architectures."
	elog ""
	elog "The bundled rocgdb-py3.10 / rocgdb-py3.12 debuggers expect those exact"
	elog "Python versions; emerge dev-lang/python:3.10 or :3.12 to use rocgdb. The"
	elog "rest of the SDK (hipcc, rocminfo, rocBLAS, ...) has no such requirement."
}

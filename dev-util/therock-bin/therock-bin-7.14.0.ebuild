# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="ROCm SDK pre-built distribution from TheRock (AMDGPU_TARGETS-selected)"
HOMEPAGE="https://github.com/ROCm/TheRock"

# The ROCm 7.14.0 RELEASE ships only as a Makeself runfile installer -- AMD
# publishes no per-arch release tarball (those exist as nightly a<DATE>
# snapshots at rocm.nightlies.amd.com/tarball-multi-arch/ only, and the
# therock-X.Y GitHub releases carry zero assets). The .run (Makeself 2.4.2,
# COMPRESS=none) bundles a shared component-rocm/content-base.tar.xz plus one
# component-rocm/content-gfx<family>.tar.xz per GPU family; each unpacks to
# <component>/rocm/core-7.14/{bin,lib,include,share,libexec}. We slice the
# uncompressed tar payload out of the .run (no install-init.sh run), extract
# base + the selected arch's family, and flatten-merge the rocm/core-7.14
# trees into /opt/therock-bin. The libs are $ORIGIN-rpath relocatable, so no
# patchelf is needed. The .run is internally 7.14.0rc3 (BUILDINFO) but is the
# official ROCm 7.14.0 release; MY_BUILD is the installer revision
# (rocm-installer-${PV}-${MY_BUILD}.run) -- revbump when AMD reissues it.
MY_BUILD="5"
MY_RUN="rocm-installer-${PV}-${MY_BUILD}.run"
SRC_URI="https://repo.radeon.com/rocm/installer/rocm-runfile-installer/rocm-rel-${PV%.*}/${MY_RUN}"
S="${WORKDIR}"

# TheRock bundles ROCm components from many upstream subprojects under their
# respective licenses; the union below matches a ROCm distribution and the
# canonical texts ship inside the tree under share/doc.
LICENSE="MIT BSD Apache-2.0 UoI-NCSA Boost-1.0"
SLOT="0"
KEYWORDS="~amd64"

# GPU targets the 7.14.0 release build ships (fine-grained -- the installer is
# multi-arch, per .gfx-lists). Each maps to a content-gfx<family>.tar.xz whose
# <arch>/ subdir we install (see _therock_family). NB vs the nightly ebuild:
# the release drops gfx900/gfx906/gfx101x and covers the RDNA/CDNA arches here.
AMDGPU_ARCHS=(
	gfx1030 gfx1100 gfx1101 gfx1102 gfx1103
	gfx1150 gfx1151 gfx1152 gfx1153
	gfx1200 gfx1201 gfx908 gfx90a gfx942 gfx950
)
IUSE="${AMDGPU_ARCHS[*]/#/amdgpu_targets_}"

# One runfile carries the whole SDK; only one target lives under
# /opt/therock-bin/ at a time.
REQUIRED_USE="^^ ( ${AMDGPU_ARCHS[*]/#/amdgpu_targets_} )"

# bindist:  conservative -- TheRock bundles many third-party components.
# mirror:   not redistributable from Gentoo mirrors.
# strip:    pre-built; upstream stripping is final.
RESTRICT="bindist mirror strip"

# TheRock vendors most system deps as librocm_sysdeps_*.so under its own
# lib/rocm_sysdeps/, but a subset of binaries still link the system directly.
# Same dep set across arches (same vendoring strategy); re-verify via ldd on a
# bump.
RDEPEND="
	app-arch/zstd:=
	dev-libs/elfutils
	sys-process/numactl
	virtual/libcrypt:=
	x11-libs/libdrm
"

QA_PREBUILT="opt/therock-bin/*"

# Coarse content-gfx<family>.tar.xz for a fine arch (mirrors the runfile's
# component-rocm/.gfx-lists GFX_FINE_TO_COARSE map).
_therock_family() {
	case $1 in
		gfx1030) echo gfx103x ;;
		gfx110[0-3]) echo gfx110x ;;
		gfx115[0-3]) echo gfx115x ;;
		gfx120[01]) echo gfx120x ;;
		gfx908) echo gfx908 ;;
		gfx90a) echo gfx90a ;;
		gfx942) echo gfx94x ;;
		gfx950) echo gfx950 ;;
		*) die "no content family for arch '$1'" ;;
	esac
}

# The single selected fine arch (REQUIRED_USE guarantees exactly one).
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

	# Makeself 2.4.2 with COMPRESS=none appends a raw tar after the shell
	# header; its byte offset = filesize - the header's `filesizes` var.
	# Slicing there extracts the payload without executing the installer and
	# tolerates header-size drift across bumps.
	# NB stat -L: portage symlinks the distfile into the sandbox, and a bare
	# stat -c%s reports the symlink's own size (target path length), not the
	# .run -- dereference it or the offset goes negative.
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
	# Flatten-merge every component's rocm/core-7.14 subtree -- the shared base
	# components plus the selected arch's gfx kernels -- into one relocatable
	# ROCm root. All base + gfx components root uniformly at
	# <component>/rocm/core-7.14/, so stripping that prefix yields the standard
	# /opt/therock-bin/{bin,lib,include,...} layout (same as the nightly ebuild).
	# Component trees root at rocm/core-<major.minor> (core-7.14 for 7.14.x).
	local core="core-${PV%.*}" found=
	for c in "${WORKDIR}"/base/*/rocm/"${core}" \
		"${WORKDIR}/${arch}"/*/rocm/"${core}"; do
		[[ -d ${c} ]] || continue
		cp -a "${c}/." "${ED}${dest}/" || die "merge of ${c} failed"
		found=1
	done
	[[ ${found} ]] || die "no rocm/core-7.14 component trees found for ${arch}"
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

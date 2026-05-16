# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="ROCm SDK pre-built distribution from TheRock"
HOMEPAGE="https://github.com/ROCm/TheRock"

# Upstream version pattern is ${BASE}a${DATE} (e.g. 7.14.0a20260516);
# Gentoo PMS expresses that as ${BASE}_alpha${DATE}.
MY_PV="${PV%_alpha*}a${PV#*_alpha}"
MY_BASE_URI="https://rocm.nightlies.amd.com/tarball/therock-dist-linux"
SRC_URI="
	amdgpu_targets_gfx900? ( ${MY_BASE_URI}-gfx900-${MY_PV}.tar.gz )
	amdgpu_targets_gfx906? ( ${MY_BASE_URI}-gfx906-${MY_PV}.tar.gz )
	amdgpu_targets_gfx908? ( ${MY_BASE_URI}-gfx908-${MY_PV}.tar.gz )
	amdgpu_targets_gfx90a? ( ${MY_BASE_URI}-gfx90a-${MY_PV}.tar.gz )
	amdgpu_targets_gfx1150? ( ${MY_BASE_URI}-gfx1150-${MY_PV}.tar.gz )
	amdgpu_targets_gfx1151? ( ${MY_BASE_URI}-gfx1151-${MY_PV}.tar.gz )
	amdgpu_targets_gfx1152? ( ${MY_BASE_URI}-gfx1152-${MY_PV}.tar.gz )
	amdgpu_targets_gfx1153? ( ${MY_BASE_URI}-gfx1153-${MY_PV}.tar.gz )
	amdgpu_targets_gfx101X-dgpu? ( ${MY_BASE_URI}-gfx101X-dgpu-${MY_PV}.tar.gz )
	amdgpu_targets_gfx103X-all? ( ${MY_BASE_URI}-gfx103X-all-${MY_PV}.tar.gz )
	amdgpu_targets_gfx110X-all? ( ${MY_BASE_URI}-gfx110X-all-${MY_PV}.tar.gz )
	amdgpu_targets_gfx120X-all? ( ${MY_BASE_URI}-gfx120X-all-${MY_PV}.tar.gz )
	amdgpu_targets_gfx94X-dcgpu? ( ${MY_BASE_URI}-gfx94X-dcgpu-${MY_PV}.tar.gz )
	amdgpu_targets_gfx950-dcgpu? ( ${MY_BASE_URI}-gfx950-dcgpu-${MY_PV}.tar.gz )
"
S="${WORKDIR}"

# TheRock bundles ROCm components from many upstream subprojects under
# their respective licenses. The set below is the union typically found
# in a ROCm distribution; the canonical license texts ship inside the
# tarball under share/doc.
LICENSE="MIT BSD Apache-2.0 UoI-NCSA Boost-1.0"
SLOT="0"
KEYWORDS="~amd64"

# AMDGPU_TARGETS catalogue mirrors the per-arch directories produced
# by AMD's nightly pipeline at https://rocm.nightlies.amd.com/tarball/.
# Single-arch values match ::gentoo's canonical amdgpu_targets.desc;
# the six fat-bundle values (gfx101X-dgpu / gfx103X-all / gfx110X-all
# / gfx120X-all / gfx94X-dcgpu / gfx950-dcgpu) are TheRock-specific
# and declared in this overlay's profiles/desc/amdgpu_targets.desc.
IUSE="
	amdgpu_targets_gfx900
	amdgpu_targets_gfx906
	amdgpu_targets_gfx908
	amdgpu_targets_gfx90a
	amdgpu_targets_gfx1150
	amdgpu_targets_gfx1151
	amdgpu_targets_gfx1152
	amdgpu_targets_gfx1153
	amdgpu_targets_gfx101X-dgpu
	amdgpu_targets_gfx103X-all
	amdgpu_targets_gfx110X-all
	amdgpu_targets_gfx120X-all
	amdgpu_targets_gfx94X-dcgpu
	amdgpu_targets_gfx950-dcgpu
"

# Each tarball is the whole SDK rooted at WORKDIR; only one target
# can live under /opt/therock-bin/ at a time.
REQUIRED_USE="
	^^ (
		amdgpu_targets_gfx900
		amdgpu_targets_gfx906
		amdgpu_targets_gfx908
		amdgpu_targets_gfx90a
		amdgpu_targets_gfx1150
		amdgpu_targets_gfx1151
		amdgpu_targets_gfx1152
		amdgpu_targets_gfx1153
		amdgpu_targets_gfx101X-dgpu
		amdgpu_targets_gfx103X-all
		amdgpu_targets_gfx110X-all
		amdgpu_targets_gfx120X-all
		amdgpu_targets_gfx94X-dcgpu
		amdgpu_targets_gfx950-dcgpu
	)
"

# strip:    pre-built tarball; upstream stripping is final.
# mirror:   not redistributable from Gentoo mirrors (nightly artifact).
# bindist:  conservative — TheRock bundles many third-party components.
RESTRICT="bindist mirror strip"

# TheRock vendors most system deps as librocm_sysdeps_*.so under its
# own lib/rocm_sysdeps/, but a subset of binaries still link directly
# against the system. Verified via ldd against the gfx1150 build —
# the dep list is the same across targets (same vendoring strategy).
RDEPEND="
	app-arch/zstd:=
	dev-libs/elfutils
	sys-process/numactl
	virtual/libcrypt:=
	x11-libs/libdrm
"

QA_PREBUILT="opt/therock-bin/*"

src_install() {
	dodir /opt
	# The tarball unpacks flat (bin/, lib/, etc. directly under WORKDIR).
	# Stage the entire tree into /opt/therock-bin/, preserving symlinks
	# and modes; fperms forces a traversable dir mode since cp -a
	# would otherwise carry over WORKDIR's portage-tmpdir 0700.
	cp -a "${WORKDIR}" "${ED}/opt/therock-bin" || die
	fperms 0755 /opt/therock-bin
}

pkg_postinst() {
	elog "TheRock SDK installed to /opt/therock-bin/."
	elog ""
	elog "TheRock coexists with the system ROCm 7.2.3 in /usr — no file"
	elog "conflicts. To use TheRock instead of the system ROCm, set per"
	elog "shell:"
	elog ""
	elog "  export ROCM_PATH=/opt/therock-bin"
	elog "  export HIP_PATH=/opt/therock-bin"
	elog "  export PATH=/opt/therock-bin/bin:\$PATH"
	elog "  export LD_LIBRARY_PATH=/opt/therock-bin/lib:\${LD_LIBRARY_PATH}"
	elog ""
	elog "Hardware target was selected via AMDGPU_TARGETS at emerge time;"
	elog "to switch architectures, re-emerge with a different"
	elog "AMDGPU_TARGETS=... in make.conf or via package.use."
	elog ""
	elog "The bundled rocgdb-py3.10 and rocgdb-py3.12 debugger binaries"
	elog "expect those specific Python versions; emerge dev-lang/python:3.10"
	elog "or :3.12 if you want to use rocgdb. The rest of the SDK (hipcc,"
	elog "rocminfo, rocBLAS, etc.) has no such requirement."
}

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )

inherit python-single-r1

DESCRIPTION="ROCm SDK pre-built distribution from TheRock (AMDGPU_TARGETS-selected)"
HOMEPAGE="https://github.com/ROCm/TheRock"

# From 10.1 AMD publishes per-family tarballs on stable.repo.amd.com next to the
# runfile; each is a complete relocatable SDK prefix with $ORIGIN rpaths, so one
# is unpacked as-is into /opt/therock-bin. verified 2026-11-04
TARBALL_URI="https://stable.repo.amd.com/rocm/core/tarball"

# Offered targets; each maps to one tarball below. gfx101X-dgpu carries
# gfx1010-gfx1012 and gfx125X-dcgpu only gfx1250. verified 2026-11-05
AMDGPU_ARCHS=(
	gfx1010 gfx1011 gfx1012
	gfx1030 gfx1100 gfx1101 gfx1102 gfx1103
	gfx1150 gfx1151 gfx1152 gfx1153
	gfx1200 gfx1201 gfx1250 gfx908 gfx90a gfx942 gfx950
)

# Map a fine arch to the tarball that carries it.
_therock_family() {
	case $1 in
		gfx101[0-2]) echo gfx101X-dgpu ;;
		gfx1030) echo gfx103X-all ;;
		gfx110[0-3]) echo gfx110X-all ;;
		gfx115[0-3]) echo "$1" ;;
		gfx120[01]) echo gfx120X-all ;;
		gfx1250) echo gfx125X-dcgpu ;;
		gfx908|gfx90a) echo "$1" ;;
		gfx942) echo gfx94X-dcgpu ;;
		gfx950) echo gfx950-dcgpu ;;
	esac
}

_therock_tarball() {
	echo "therock-dist-linux-$(_therock_family "$1")-${PV}.tar.gz"
}

for _a in "${AMDGPU_ARCHS[@]}"; do
	SRC_URI+=" amdgpu_targets_${_a}? ( ${TARBALL_URI}/$(_therock_tarball "${_a}") )"
done
unset _a
S="${WORKDIR}/therock"

LICENSE="MIT BSD Apache-2.0 UoI-NCSA Boost-1.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="${AMDGPU_ARCHS[*]/#/amdgpu_targets_}"

# One target may own /opt/therock-bin at a time.
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	^^ ( ${AMDGPU_ARCHS[*]/#/amdgpu_targets_} )
"

# Bundled third-party prebuilt: do not redistribute, mirror, or strip.
RESTRICT="bindist mirror strip"

# Most libraries are vendored as lib/rocm_sysdeps/librocm_sysdeps_*.so (zstd,
# drm, elfutils among them); these remain system consumers: zlib for the
# profilers, libcrypt for rocgdb-py3.10, numactl and libltdl for the rocrtst
# hwloc, perl for hipify-perl. Recheck with scanelf on each bump.
# verified 2026-11-04
RDEPEND="
	dev-lang/perl
	${PYTHON_DEPS}
	dev-libs/libltdl
	sys-process/numactl
	virtual/libcrypt:=
	virtual/zlib:=
"

QA_PREBUILT="opt/therock-bin/*"

_therock_arch() {
	local a
	for a in "${AMDGPU_ARCHS[@]}"; do
		use "amdgpu_targets_${a}" && { echo "${a}"; return; }
	done
}

src_unpack() {
	local arch
	arch=$(_therock_arch)
	mkdir "${S}" || die
	ebegin "Extracting ROCm ${PV} for ${arch}"
	tar -xzf "${DISTDIR}/$(_therock_tarball "${arch}")" -C "${S}"
	eend $? || die "tarball extraction failed"
}

src_install() {
	# Move rather than copy: the unpacked SDK is ~9 GiB.
	dodir /opt
	mv "${S}" "${ED}/opt/therock-bin" || die
	fperms 0755 /opt/therock-bin
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
	# clang adds the SDK's include/ with -idirafter, after /usr/include, so
	# an installed dev-util/hip shadows TheRock's HIP headers.
	# verified 2026-11-05 with 10.1.0's clang++ and hipcc
	elog "With a system ROCm installed, its /usr/include/hip headers take"
	elog "precedence over TheRock's own. To build against TheRock's headers, add:"
	elog ""
	elog "  export HIPCC_COMPILE_FLAGS_APPEND=\"-isystem /opt/therock-bin/include\""
	elog ""
	elog "or pass -isystem /opt/therock-bin/include when calling clang++ directly."
	elog ""
	elog "The GPU target was chosen via AMDGPU_TARGETS at emerge time; re-emerge"
	elog "with a different single amdgpu_targets_* value to switch architectures."
	elog ""
	elog "The bundled rocgdb-py3.10 through rocgdb-py3.14 debuggers expect their"
	elog "matching Python slot; emerge the desired dev-lang/python slot to use one."
	elog "The rest of the SDK (hipcc, rocminfo, rocBLAS, ...) only needs Python 3."
}

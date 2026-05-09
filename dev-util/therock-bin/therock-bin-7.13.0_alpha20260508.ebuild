# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="ROCm SDK pre-built distribution from TheRock (gfx1150 / Strix Point)"
HOMEPAGE="https://github.com/ROCm/TheRock"

# Upstream version pattern is ${BASE}a${DATE} (e.g. 7.13.0a20260508);
# Gentoo PMS expresses that as ${BASE}_alpha${DATE}.
MY_PV="${PV%_alpha*}a${PV#*_alpha}"
MY_TARBALL="therock-dist-linux-gfx1150-${MY_PV}.tar.gz"
SRC_URI="https://rocm.nightlies.amd.com/tarball/${MY_TARBALL}"
S="${WORKDIR}"

# TheRock bundles ROCm components from many upstream subprojects under
# their respective licenses. The set below is the union typically found
# in a ROCm distribution; the canonical license texts ship inside the
# tarball under share/doc.
LICENSE="MIT BSD Apache-2.0 UoI-NCSA Boost-1.0"
SLOT="0"
KEYWORDS="~amd64"

# strip:    pre-built tarball; upstream stripping is final.
# mirror:   not redistributable from Gentoo mirrors (nightly artifact).
# bindist:  conservative — TheRock bundles many third-party components.
RESTRICT="bindist mirror strip"

# TheRock vendors most system deps as librocm_sysdeps_*.so under its
# own lib/rocm_sysdeps/, but a subset of binaries still link directly
# against the system. Verified via ldd 2026-05-09 against the
# 7.13.0a20260508 build.
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
	elog "Hardware target: gfx1150 (AMD Strix Point iGPU). Other gfx"
	elog "targets are not present in this build."
	elog ""
	elog "The bundled rocgdb-py3.10 and rocgdb-py3.12 debugger binaries"
	elog "expect those specific Python versions; emerge dev-lang/python:3.10"
	elog "or :3.12 if you want to use rocgdb. The rest of the SDK (hipcc,"
	elog "rocminfo, rocBLAS, etc.) has no such requirement."
}

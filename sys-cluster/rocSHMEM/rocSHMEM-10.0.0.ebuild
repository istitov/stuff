# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="GPU-centric OpenSHMEM-like partitioned global address space runtime"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocshmem"
# New package; ::gentoo carries nothing of it. rocSHMEM lets device code issue
# its own communication -- puts, gets and collectives called from inside a
# kernel rather than marshalled by the host between launches -- following the
# OpenSHMEM model. sys-cluster alongside the MPI implementations it interops
# with, rather than sci-libs: this is a communication runtime.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the rocshmem.tar.gz asset on the rocm-systems
# therock-<major.minor> release.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rocshmem.tar.gz -> rocshmem-${PV}.tar.gz"
S="${WORKDIR}/rocshmem"

LICENSE="MIT"
# Versioned by the ROCm release rather than upstream's VERSION_STRING (3.6.0
# here), matching the rest of the stack.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="+ipc mpi +single-node sdma"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

# Upstream gates the SDMA backend directory on USE_SDMA but leaves the source
# that CALLS into it, sdma/gin_anvil_sdma_factory.cpp, in the unconditional
# list -- so upstream's own default of USE_SDMA=OFF does not link:
#   undefined reference to `sdma_anvil::initEndpoint()' and friends.
# The patch moves that file next to the implementation it needs, which is what
# makes USE=-sdma buildable at all. verified 2026-08-31.
PATCHES=(
	"${FILESDIR}"/${P}-gate-sdma-factory.patch
)

# Split by what the built library actually links rather than by what CMake
# looks for. objdump -p on librocshmem.so reports only libhsa-runtime64.so.1
# and libamdhip64.so.7; nothing pulls in rocprofiler-register, amd_smi, numa or
# hsakmt at runtime, and the two dlopen/dlsym relocations reference none of them
# by name either.
#
# hsakmt (roct-thunk-interface) and numactl are consumed ONLY by the SDMA
# backend -- CMakeLists.txt links them under $<BOOL:${USE_SDMA}> and
# $<OR:$<BOOL:${USE_GDA}>,$<BOOL:${USE_SDMA}>> respectively -- so they follow
# that flag. amd_smi is a configure-time capability probe ("Looking for
# amdsmi_get_gpu_fabric_info in amd_smi - found") and rocprofiler-register is a
# QUIET lookup whose registration leaves no NEEDED entry, so both are
# build-time only. verified 2026-08-31.
RDEPEND="
	dev-libs/rocr-runtime:${SLOT}
	dev-util/hip:${SLOT}
	mpi? ( virtual/mpi )
	sdma? (
		dev-libs/roct-thunk-interface:${SLOT}
		sys-process/numactl
	)
"
DEPEND="
	${RDEPEND}
	dev-libs/rocprofiler-register:${SLOT}
	dev-util/amdsmi:${SLOT}
"
BDEPEND="
	dev-build/rocm-cmake:${SLOT}
"

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		# Upstream's DEFAULT_GPUS is only gfx90a/gfx1100/gfx1201/gfx942 (plus
		# gfx950 and gfx1250 on newer ROCm), but a user-supplied GPU_TARGETS is
		# honoured: it is validated with rocm_check_target_ids, which tests what
		# the COMPILER supports rather than membership of that default list. So
		# the eclass target set is passed through here and anything the compiler
		# rejects is dropped by upstream's own check. verified 2026-08-31.
		# Upstream determines the ROCm version by find_file()ing .info/version
		# under ROCM_PATH with REQUIRED -- a file only a bundled /opt/rocm
		# install has, so configure dies with "Could not find rocm_version_file
		# using the following files: version". EXPLICIT_ROCM_VERSION is
		# upstream's own documented escape hatch for exactly this. ROCM_PATH is
		# then never derived (it is normally taken from the version file's
		# location) and would be set to the empty string, so it is passed too;
		# the later `set(ROCM_PATH ... CACHE PATH)` cannot clobber a value that
		# already exists in the cache. verified 2026-08-31.
		-DEXPLICIT_ROCM_VERSION="${PV}"
		-DROCM_PATH="${EPREFIX}/usr"
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DUSE_IPC=$(usex ipc ON OFF)
		# "MI300X+" per upstream; needs hsakmt and numa, both of which are
		# already dependencies of this package.
		-DUSE_SDMA=$(usex sdma ON OFF)
		-DUSE_SINGLE_NODE=$(usex single-node ON OFF)
		-DUSE_ROCPROFILER_REGISTER=ON
		-DBUILD_TESTS=OFF
		-DBUILD_EXAMPLES=OFF
		-Wno-dev
	)

	use mpi || mycmakeargs+=( -DUSE_EXTERNAL_MPI=OFF )

	cmake_src_configure
}

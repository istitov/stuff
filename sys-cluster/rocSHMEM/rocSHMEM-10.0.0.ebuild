# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="GPU-centric OpenSHMEM-like partitioned global address space runtime"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocshmem"
# Since ROCm 10, source is the rocshmem.tar.gz asset on rocm-systems'
# therock-X.Y release; the legacy rocm-* line ended at 7.2.4.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rocshmem.tar.gz -> rocshmem-${PV}.tar.gz"
S="${WORKDIR}/rocshmem"

LICENSE="MIT"
# Follow the ROCm stack ABI rather than upstream's 3.6.0 version.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="+ipc mpi +single-node sdma"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

# Upstream gates the SDMA implementation but not its factory caller, breaking
# USE=-sdma at link time. Gate the factory with its backend. verified 2026-08-31
PATCHES=(
	"${FILESDIR}"/${P}-gate-sdma-factory.patch
)

# librocshmem NEEDED entries include only HSA and HIP. SDMA alone adds hsakmt and
# numa; amd_smi is a configure probe and rocprofiler-register leaves no runtime
# dependency. verified 2026-08-31
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
		# Upstream validates explicit GPU_TARGETS against the compiler, not its short
		# default list, so pass the eclass selection. verified 2026-08-31
		# The split /usr layout lacks ROCM_PATH/.info/version. Use upstream's explicit
		# version escape and set the otherwise-empty ROCM_PATH. verified 2026-08-31
		-DEXPLICIT_ROCM_VERSION="${PV}"
		-DROCM_PATH="${EPREFIX}/usr"
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DUSE_IPC=$(usex ipc ON OFF)
		# Upstream limits this backend to MI300X+.
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

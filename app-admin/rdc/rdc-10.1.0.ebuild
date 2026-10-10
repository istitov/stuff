# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="ROCm Data Center Tool: GPU telemetry and job statistics for clusters"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rdc"
# Since ROCm 10, source is the rdc.tar.gz asset on rocm-systems' therock-X.Y
# release; the legacy rocm-* line ended at 7.2.4.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rdc.tar.gz -> rdc-${PV}.tar.gz"
S="${WORKDIR}/rdc"

LICENSE="MIT"
# Follow the ROCm stack ABI rather than upstream's 1.3.1 version.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="+rocr"

# rocr installs upstream-built HSACO images, so exclude them from host stripping
# and declare them prebuilt. They cover gfx700 through gfx942 only: gfx11/12 lack
# librdc_rocr diagnostics, but amd_smi telemetry still works. verified 2026-08-31
QA_PREBUILT="usr/lib*/rdc/hsaco/*/*.hsaco"

# gRPC 1.78.1, libcap, and amd_smi 27.0.0 are required with no bundled fallback;
# default-on ESMI also supplies CPU metrics. verified 2026-08-31
RDEPEND="
	>=net-libs/grpc-1.78.1:=
	dev-util/amdsmi:${SLOT}
	sys-libs/libcap
	rocr? ( dev-libs/rocr-runtime:${SLOT} )
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=net-libs/grpc-1.78.1
"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DBUILD_STANDALONE=ON
		# HSA diagnostic module.
		-DBUILD_RUNTIME=$(usex rocr ON OFF)
		# rocprofiler-sdk is blocked on gotcha/PTL/perfetto; RVS is also unpackaged.
		-DBUILD_PROFILER=OFF
		-DBUILD_RVS=OFF
		-DBUILD_TESTS=OFF
		-DBUILD_EXAMPLES=OFF
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	# STRIP_MASK was unreliable for these upstream HSACO images.
	use rocr && dostrip -x "/usr/$(get_libdir)/rdc/hsaco"

	cmake_src_install

	# Keep the documented collectd and TLS helpers in libexec; drop shipped bytecode.
	find "${ED}" -name '__pycache__' -type d -exec rm -r {} + 2>/dev/null
}

pkg_postinst() {
	elog "rdcd is the telemetry daemon and rdci the client that talks to it."
	elog "No service file is installed: upstream's systemd unit is generated for"
	elog "its .deb only, and it expects a dedicated 'rdc' user this package does"
	elog "not create. To try it out without a service:"
	elog
	elog "    rdcd -u          # unauthenticated, listens on localhost:50051"
	elog "    rdci discovery -l"
	elog
	elog "Run rdcd as root, or as a user with CAP_DAC_OVERRIDE, for full"
	elog "telemetry access. Upstream's sample options file is installed under"
	elog "/usr/share/rdc/conf/ if you want to build a service around it."
}

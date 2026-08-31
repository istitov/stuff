# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="ROCm Data Center Tool: GPU telemetry and job statistics for clusters"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rdc"
# New package; ::gentoo carries nothing of it. RDC exposes GPU telemetry --
# utilisation, power, clocks, ECC counters, per-job statistics -- over a gRPC
# service, so a fleet can be monitored from one place. app-admin rather than
# sci-libs: it is a monitoring tool, and its consumers are Prometheus-style
# collectors rather than compute code.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the rdc.tar.gz asset on the rocm-systems
# therock-<major.minor> release.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rdc.tar.gz -> rdc-${PV}.tar.gz"
S="${WORKDIR}/rdc"

LICENSE="MIT"
# Versioned by the ROCm release rather than upstream's own 1.3.1, matching the
# rest of the stack.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="+rocr"

# USE=rocr installs 48 PREBUILT GPU code objects that upstream ships in the
# source tree (rdc_libs/rdc_modules/kernels/hsaco/<arch>/), not built from the
# .cl sources sitting next to them. They are ELF images for the GPU, so
# portage's strip cannot parse them ("Unable to recognise the architecture of
# the input file"); mask them rather than letting it try, and declare them
# prebuilt. src_install uses dostrip -x for this: STRIP_MASK does not match
# them reliably here, and dostrip is the EAPI 7+ mechanism anyway.
#
# Worth knowing before relying on that module: the shipped set spans gfx700
# through gfx942 and contains NOTHING for gfx11xx or gfx12xx -- so on an RDNA3
# or newer part, including this overlay's usual gfx1150 target, the diagnostic
# kernels have no matching image. Telemetry through amd_smi is unaffected;
# only the librdc_rocr.so diagnostics are. verified 2026-08-31.
QA_PREBUILT="usr/lib*/rdc/hsaco/*/*.hsaco"

# gRPC is the transport between rdcd and rdci and is find_package(gRPC 1.78.1
# CONFIG REQUIRED) -- there is no bundled fallback. libcap is a bare
# find_library(cap REQUIRED), used to drop the daemon's privileges to
# CAP_DAC_OVERRIDE. amd_smi is find_package(amd_smi 27.0.0 CONFIG REQUIRED) and
# supplies the actual telemetry; BUILD_ESMI, on by default, additionally turns
# on its ESMI (CPU-side) entry points. verified 2026-08-31.
RDEPEND="
	>=net-libs/grpc-1.78.1:=
	dev-util/amdsmi:${SLOT}
	sys-libs/libcap
	rocr? ( dev-libs/rocr-runtime:${SLOT} )
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		# Plain `set(... CACHE STRING ...)` with no FORCE upstream, so -D wins.
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		# rdcd + rdci, the whole point of the package.
		-DBUILD_STANDALONE=ON
		# librdc_rocr.so, the HSA-based diagnostic module.
		-DBUILD_RUNTIME=$(usex rocr ON OFF)
		# Left off deliberately. BUILD_PROFILER wants the rocprofiler stack,
		# which this overlay does not carry yet (rocprofiler-sdk is blocked on
		# unpackaged gotcha/PTL/perfetto deps), and BUILD_RVS wants the ROCm
		# Validation Suite, which is not packaged either.
		-DBUILD_PROFILER=OFF
		-DBUILD_RVS=OFF
		-DBUILD_TESTS=OFF
		-DBUILD_EXAMPLES=OFF
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	# Exclude the prebuilt GPU code objects from stripping; see QA_PREBUILT above.
	use rocr && dostrip -x "/usr/$(get_libdir)/rdc/hsaco"

	cmake_src_install

	# Upstream generates DEBIAN/{postinst,prerm} into the SOURCE tree at
	# configure time and stages a systemd unit for CPack, but installs neither
	# -- verified by reading every install() rule, and confirmed against the
	# image. So there is no service file to leak here. rdcd is left for the
	# admin to run or wrap; see pkg_postinst.

	# python_binding/ and authentication/ land in libexec as plain directories;
	# the former carries a collectd integration and the latter a helper that
	# generates TLS material for the gRPC channel. Keep both -- they are the
	# documented way to secure and consume the daemon -- but drop the bytecode
	# cache if the source tree shipped one.
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

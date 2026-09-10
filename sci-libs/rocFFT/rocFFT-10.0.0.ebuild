# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
ROCM_VERSION=${PV}

inherit cmake check-reqs edo multiprocessing python-r1 rocm

DESCRIPTION="Next generation FFT implementation for ROCm"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/rocfft"
# ROCm 10 component assets use therock tags; rocm tags end at 7.2.4.
MY_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)"
SRC_URI="${MY_URI}/rocfft.tar.gz -> rocfft-${PV}.tar.gz"
S="${WORKDIR}/rocfft"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

RDEPEND="
	dev-db/sqlite:3
	dev-util/hip:${SLOT}
	perfscripts? (
		media-gfx/asymptote
		dev-texlive/texlive-latex
		dev-tex/latexmk
		sys-apps/texinfo
		dev-python/sympy[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/pandas[${PYTHON_USEDEP}]
		${PYTHON_DEPS}
	)
"

DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
	benchmark? (
		dev-libs/boost
		sci-libs/hipRAND:${SLOT}
	)
	test? (
		dev-cpp/gtest
		dev-libs/boost
		sci-libs/fftw
		llvm-runtimes/openmp
		sci-libs/hipRAND:${SLOT}
	)
"

BDEPEND="
	dev-build/rocm-cmake:${SLOT}
	dev-db/sqlite
"

CHECKREQS_DISK_BUILD="7G"

IUSE="benchmark perfscripts test"
REQUIRED_USE="perfscripts? ( benchmark ) ${PYTHON_REQUIRED_USE} ${ROCM_REQUIRED_USE}"
RESTRICT="!test? ( test )"

required_mem() {
	if use test; then
		echo "52G"
	else
		if [[ -n "${AMDGPU_TARGETS}" ]]; then
			# Count configured GPU targets.
			local NARCH=$(($(awk -F";" '{print NF-1}' <<< "${AMDGPU_TARGETS}" || die)+1))
		else
			# Upstream's default target count.
			local NARCH=7
		fi
		# Estimate peak memory from parallelism and selected targets.
		echo "$(($(makeopts_jobs)*${NARCH}*25+2200))M"
	fi
}

pkg_pretend() {
	return # Defer the disk check to pkg_setup.
}

pkg_setup() {
	export CHECKREQS_MEMORY=$(required_mem)
	check-reqs_pkg_setup
	python_setup
}

src_prepare() {
	if use perfscripts; then
		pushd scripts/perf || die
		# Guard the version rewrite because sed accepts no matches.
		grep -qF 'rocm_info.strip()' perflib/specs.py ||
			die 'rocm_info.strip() anchor moved in perflib/specs.py'
		sed -e "/\/opt\/rocm/d" -e "/rocmversion/s,rocm_info.strip(),\"${PV}\"," -i perflib/specs.py || die
		# Drop the in-tree sys.path bootstrap from the installed tool.
		# verified 2026-08-30
		grep -q '^top' rocfft-perf || die '^top anchor moved in rocfft-perf'
		sed -e "/^top/,+1d" -i rocfft-perf || die

		grep -q 'perflib' suites.py || die 'perflib anchor moved in suites.py'
		sed -e "s,perflib,${PN}_perflib,g" -i rocfft-perf suites.py perflib/*.py || die

		# Point modules at installed data.
		local f
		for f in perflib/pdf.py perflib/generators.py; do
			grep -q '^top = ' "${f}" || die "^top = anchor moved in ${f}"
		done
		sed -e "/^top = /s,__file__).*$,\"${EPREFIX}/usr/share/${PN}-perflib\")," \
			-i perflib/pdf.py perflib/generators.py || die
		popd || die
	fi

	cmake_src_prepare
}

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-Wno-dev
		-DROCM_SYMLINK_LIBS=OFF
		-DBUILD_CLIENTS_TESTS=$(usex test ON OFF)
		-DBUILD_CLIENTS_BENCH=$(usex benchmark ON OFF)
		-DSQLITE_USE_SYSTEM_PACKAGE=ON
	)

	cmake_src_configure
}

src_test() {
	check_amdgpu
	cd "${BUILD_DIR}/clients/staging" || die
	export LD_LIBRARY_PATH=${BUILD_DIR}/library/src/:${BUILD_DIR}/library/src/device
	HIP_VISIBLE_DEVICES=0 edob ./rocfft-test
}

src_install() {
	cmake_src_install

	if use benchmark; then
		cd "${BUILD_DIR}"/clients/staging || die
		dobin dyna-rocfft-bench rocfft-bench
		dosym dyna-rocfft-bench /usr/bin/dyna-rocfft-rider
		dosym rocfft-bench /usr/bin/dyna-rocfft-rider

		if ! use perfscripts; then
			# Avoid collision with dev-util/perf.
			rm -rf "${ED}"/usr/bin/perf || die
		fi
	fi

	if use perfscripts; then
		cd "${S}"/scripts/perf || die
		python_foreach_impl python_doexe rocfft-perf
		python_moduleinto ${PN}_perflib
		python_foreach_impl python_domodule perflib/*.py
		insinto /usr/share/${PN}-perflib
		doins *.asy suites.py
	fi
}

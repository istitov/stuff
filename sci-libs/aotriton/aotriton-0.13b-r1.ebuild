# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit cmake git-r3 python-any-r1 toolchain-funcs

DESCRIPTION="Ahead of Time (AOT) Triton Math Library"
HOMEPAGE="https://github.com/ROCm/aotriton"
EGIT_REPO_URI="https://github.com/ROCm/aotriton.git"
EGIT_COMMIT="${PV}"
EGIT_SUBMODULES=( '*' )

LICENSE="MIT"
SLOT="0/${PV%b}"
KEYWORDS="-* ~amd64"

IUSE_TARGETS=(
	gfx90a
	gfx942
	gfx950
	gfx1100
	gfx1101
	gfx1102
	gfx1103
	gfx1150
	gfx1151
	gfx1200
	gfx1201
	gfx1250
)
IUSE_TARGETS=( "${IUSE_TARGETS[@]/#/amdgpu_targets_}" )
IUSE="${IUSE_TARGETS[*]/#/+}"

REQUIRED_USE="|| ( ${IUSE_TARGETS[*]} )"

# Triton's isolated wheel build downloads its cmake<4 backend and pinned LLVM,
# while AOTriton's configure step fetches its pinned aiter source.
PROPERTIES="live"
RESTRICT="network-sandbox test"

# dev-util/hip cap: this is a SOURCE build, so it has none of the shim-archive
# constraint that bounds sci-libs/aotriton-bin -- upstream's CMakeLists.txt does
# a bare `find_package(hip REQUIRED)` with no version argument, and nothing else
# in the tree gates on a HIP version. The old <7.3 here was inherited from the
# -bin ebuild, where it tracks which *-rocmX.X-shared.tar.gz shims upstream
# publishes; carried over to the source build it just excluded the ROCm 10.0
# stack for no reason. Match the -bin at the same upstream version instead:
# floor 6.4, cap below 11. verified 2026-08-30 against the 0.13b tag.
RDEPEND="
	!!sci-libs/aotriton-bin
	sys-libs/glibc
	sys-devel/gcc
	app-arch/xz-utils
	>=dev-util/hip-6.4:=
	<dev-util/hip-11:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/cmake-3.26
	>=dev-build/ninja-1.11
	${PYTHON_DEPS}
	virtual/zlib
	virtual/pkgconfig
	$(python_gen_any_dep '
		dev-python/filelock[${PYTHON_USEDEP}]
		dev-python/iniconfig[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/pandas[${PYTHON_USEDEP}]
		dev-python/pip[${PYTHON_USEDEP}]
		dev-python/pluggy[${PYTHON_USEDEP}]
		dev-python/pybind11[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		>=dev-python/setuptools-64[${PYTHON_USEDEP}]
		dev-python/wheel[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}/${P}-include-iostream.patch"
)

python_check_deps() {
	python_has_version "dev-python/filelock[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/iniconfig[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/numpy[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/packaging[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/pandas[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/pip[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/pluggy[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/pybind11[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/pyyaml[${PYTHON_USEDEP}]" &&
		python_has_version ">=dev-python/setuptools-64[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/wheel[${PYTHON_USEDEP}]"
}

src_prepare() {
	cmake_src_prepare

	# Reuse the declared build dependencies in upstream's disposable venv.
	# The local Triton wheel is still installed into that venv below.
	sed -i \
		-e '/execute_process(COMMAND.*-m venv "${VENV_DIR}")/s/-m venv /-m venv --system-site-packages /' \
		-e '/-m pip install "${CMAKE_CURRENT_LIST_DIR}"/s/pip install/pip install --no-build-isolation --no-deps/' \
		CMakeLists.txt || die
}

src_configure() {
	python_setup
	tc-export CC CXX
	local CMAKE_BUILD_TYPE=Release

	local wheel_dir="${T}/triton-wheel"
	mkdir -p "${wheel_dir}" "${T}/home" || die

	# Triton builds LLVM/MLIR-heavy translation units; cap parallelism to
	# avoid exhausting RAM before the AOT kernel build starts.
	local -x MAX_JOBS=4
	local -x HOME="${T}/home"
	local -x PIP_CACHE_DIR="${T}/pip-cache"
	local -x TRITON_BUILD_PROTON=OFF
	local -x TRITON_HOME="${T}/triton-cache"
	"${EPYTHON}" -m pip wheel --no-deps \
		--wheel-dir "${wheel_dir}" "${S}/third_party/triton" ||
		die "failed to build the vendored Triton wheel"

	local triton_wheels=( "${wheel_dir}"/triton-*.whl )
	[[ ${#triton_wheels[@]} -eq 1 && -f ${triton_wheels[0]} ]] ||
		die "expected exactly one Triton wheel"

	local targets=() target
	for target in "${IUSE_TARGETS[@]}"; do
		use "${target}" && targets+=( "${target#amdgpu_targets_}" )
	done
	local target_arch
	printf -v target_arch '%s;' "${targets[@]}"
	target_arch=${target_arch%;}

	local -x PIP_NO_INDEX=1
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${BUILD_DIR}/install_dir"
		-DAOTRITON_GPU_BUILD_TIMEOUT=0
		-DAOTRITON_NO_PYTHON=ON
		-DAOTRITON_TARGET_ARCH="${target_arch}"
		-DAOTRITON_USE_LOCAL_TRITON_WHEEL="${triton_wheels[0]}"
		-DAOTRITON_USE_TORCH=OFF
		-DPython3_EXECUTABLE="${PYTHON}"
	)
	cmake_src_configure
}

src_compile() {
	# Upstream's install target owns the complete generated-kernel build graph.
	:
}

src_install() {
	local -x PIP_NO_INDEX=1
	cmake_build install

	local install_dir="${BUILD_DIR}/install_dir"
	doheader -r "${install_dir}"/include/*
	insinto /usr/$(get_libdir)
	doins -r "${install_dir}"/lib/*
}

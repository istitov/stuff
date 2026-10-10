# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
PYTHON_REQ_USE="sqlite"

inherit cmake flag-o-matic python-any-r1

MY_PN=${PN%*-bin}
MY_P=${MY_PN}-${PV}
# Tag ${PV}. Upstream's CMake asks for both hashes when it is not run from a
# git checkout; the kernel images carry the same pair in __signature__.
# verified 2026-10-10
MY_COMMIT="6e00ef3e335b45dfb49065259533b59c68995bfe"
MY_TREE="0a9c220761603465c794bc6522564452d43ebc23"

DESCRIPTION="Ahead of Time (AOT) Triton Math Library (binary package)"
HOMEPAGE="https://github.com/ROCm/aotriton"

URI_PREFIX="https://github.com/ROCm/${MY_PN}/releases/download/${PV}"
SHIM_URI_PREFIX="${URI_PREFIX}/${MY_P}-manylinux_2_28_x86_64"
IMAGES_URI_PREFIX="${URI_PREFIX}/${MY_P}-images-amd"

# Fetch all small ROCm shims but unpack only the installed version. ROCm 10
# reports HIP 7.15, so rename that shim to rocm10.0 for selection. gfx1250 has
# its own image. # verified 2026-08-30
# The source archive is for a HIP that has no shim, such as ROCm 10.1 (HIP
# 7.16): src_unpack explains. verified 2026-10-10
SRC_URI="
	${SHIM_URI_PREFIX}-rocm6.4-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.0-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.1-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.2-shared.tar.gz
	${SHIM_URI_PREFIX}-rocm7.15-shared.tar.gz
		-> ${MY_P}-manylinux_2_28_x86_64-rocm10.0-shared.tar.gz
	https://github.com/ROCm/${MY_PN}/archive/refs/tags/${PV}.tar.gz
		-> ${MY_P}.tar.gz

	amdgpu_targets_gfx90a? ( ${IMAGES_URI_PREFIX}-gfx90a.tar.gz )
	amdgpu_targets_gfx942? ( ${IMAGES_URI_PREFIX}-gfx942.tar.gz )
	amdgpu_targets_gfx950? ( ${IMAGES_URI_PREFIX}-gfx950.tar.gz )

	amdgpu_targets_gfx1100? ( ${IMAGES_URI_PREFIX}-gfx110x.tar.gz )
	amdgpu_targets_gfx1101? ( ${IMAGES_URI_PREFIX}-gfx110x.tar.gz )
	amdgpu_targets_gfx1102? ( ${IMAGES_URI_PREFIX}-gfx110x.tar.gz )
	amdgpu_targets_gfx1103? ( ${IMAGES_URI_PREFIX}-gfx110x.tar.gz )
	amdgpu_targets_gfx1150? ( ${IMAGES_URI_PREFIX}-gfx115x.tar.gz )
	amdgpu_targets_gfx1151? ( ${IMAGES_URI_PREFIX}-gfx115x.tar.gz )

	amdgpu_targets_gfx1200? ( ${IMAGES_URI_PREFIX}-gfx120x.tar.gz )
	amdgpu_targets_gfx1201? ( ${IMAGES_URI_PREFIX}-gfx120x.tar.gz )
	amdgpu_targets_gfx1250? ( ${IMAGES_URI_PREFIX}-gfx1250.tar.gz )
"
S="${WORKDIR}/${MY_PN}"
CMAKE_USE_DIR="${WORKDIR}/${MY_P}"

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

# Nothing to test: prebuilt files, or a build that has no test target.
RESTRICT="strip test"
QA_PREBUILT="usr/lib*/libaotriton_v2.so.*"

# manylinux links glibc/gcc; xz decompresses kernels at runtime. HIP's subslot
# forces reinstall, and src_unpack then looks for that HIP in the sparse
# upstream shim set.
RDEPEND="
	!!sci-libs/aotriton
	sys-libs/glibc
	sys-devel/gcc
	app-arch/xz-utils
	>=dev-util/hip-6.4:=
	<dev-util/hip-11:=
"
# src_unpack picks the shim matching the HIP this builds against.
DEPEND="
	app-arch/xz-utils
	>=dev-util/hip-6.4:=
	<dev-util/hip-11:=
"
# Only the runtime library build uses these: upstream's requirements.txt for
# its code generator, which runs in a venv that sees the system packages.
BDEPEND="
	virtual/pkgconfig
	${PYTHON_DEPS}
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

# Print the HIP major.minor this builds against, as upstream names its shims.
aotriton_hip_ver() {
	local hippkg=$(best_version -d dev-util/hip)
	ver_cut 1-2 "${hippkg#*hip-}"
}

# True when upstream ships a runtime library for that HIP.
aotriton_has_shim() {
	has "${MY_P}-manylinux_2_28_x86_64-rocm$(aotriton_hip_ver)-shared.tar.gz" ${A}
}

src_unpack() {
	# Identically structured shim archives overwrite each other; unpack one.
	local rocmver=$(aotriton_hip_ver)
	local file
	for file in ${A}; do
		if [[ ${file} == *-rocm${rocmver}-*.tar.gz ||
			${file} == *-gfx*.tar.gz ]]; then
			unpack "${file}"
		fi
	done

	# Upstream's shim set is sparse. For a HIP outside it, PyTorch's
	# aotriton.cmake builds the runtime library from the tagged source and
	# still uses the prebuilt kernel images; do the same.
	if ! aotriton_has_shim; then
		unpack "${MY_P}.tar.gz"
		mkdir -p "${S}" || die
	fi
}

src_prepare() {
	if aotriton_has_shim; then
		default
		return
	fi

	cmake_src_prepare

	# The code generator runs in a venv made at configure time. Let it use
	# the declared build dependencies instead of downloading them.
	sed -i \
		-e '/execute_process(COMMAND.*-m venv "${VENV_DIR}")/s/-m venv /-m venv --system-site-packages /' \
		-e '/-m pip install "${CMAKE_CURRENT_LIST_DIR}"/s/pip install/pip install --no-build-isolation --no-deps/' \
		"${CMAKE_USE_DIR}"/CMakeLists.txt || die
}

src_configure() {
	aotriton_has_shim && return

	local targets=() target
	for target in "${IUSE_TARGETS[@]}"; do
		use "${target}" && targets+=( "${target#amdgpu_targets_}" )
	done
	local target_arch
	printf -v target_arch '%s;' "${targets[@]}"
	target_arch=${target_arch%;}

	# Upstream's shims are release builds.
	append-cppflags -DNDEBUG

	local -x AOTRITON_CI_SUPPLIED_SHA1=${MY_COMMIT}
	local -x AOTRITON_GIT_TREESHA1=${MY_TREE}
	local -x PIP_NO_INDEX=1
	local mycmakeargs=(
		# Staged beside the unpacked kernel images; see src_compile.
		-DCMAKE_INSTALL_PREFIX="${S}"
		-DAOTRITON_NOIMAGE_MODE=ON
		-DAOTRITON_NO_PYTHON=ON
		# Upstream would add its own ccache launcher; Portage wraps the
		# compiler itself when ccache is wanted.
		-DCCACHE_FOUND=OFF
		-DPython3_EXECUTABLE="${PYTHON}"
	)
	# With every target disabled, keep upstream's default list.
	[[ -n ${target_arch} ]] &&
		mycmakeargs+=( -DAOTRITON_TARGET_ARCH="${target_arch}" )
	cmake_src_configure
}

src_compile() {
	aotriton_has_shim && return

	local -x AOTRITON_CI_SUPPLIED_SHA1=${MY_COMMIT}
	local -x AOTRITON_GIT_TREESHA1=${MY_TREE}
	local -x PIP_NO_INDEX=1
	cmake_src_compile

	# Stage the library and headers in ${S}, where a shim archive would have
	# put them, so that src_install is the same for both.
	cmake_build install

	# The exported CMake targets record the staging prefix; point them at the
	# installed tree.
	sed -i \
		-e "s|${S}/lib/|${EPREFIX}/usr/$(get_libdir)/|g" \
		-e "s|${S}|${EPREFIX}/usr|g" \
		"${S}"/lib/cmake/aotriton/aotriton-targets*.cmake || die
}

src_install() {
	doheader -r include/*

	insinto /usr/$(get_libdir)
	doins -r lib/*
}

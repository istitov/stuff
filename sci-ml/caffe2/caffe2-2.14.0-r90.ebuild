# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
# Select ROCm 10 target flags; dependency atoms below constrain the stack.
# verified 2026-08-30
ROCM_VERSION=10.0
inherit python-single-r1 cmake cuda flag-o-matic prefix rocm

MYPN=pytorch
MYP=${MYPN}-${PV}

# Build against upstream's pinned composable-kernel revision.
CK_COMMIT=5a74dec07a894484b9489d0c0e00cd3b52652d18
CK_P=composable_kernel-${CK_COMMIT:0:8}

FLASH_PV=2.7.4
FLASH_PN=flash-attention
FLASH_P=${FLASH_PN}-${FLASH_PV}
FLASH_ATT_URI="https://github.com/Dao-AILab/${FLASH_PN}/archive/refs/tags/v${FLASH_PV}.tar.gz -> ${FLASH_P}.gh.tar.gz"

DESCRIPTION="A deep learning framework"
HOMEPAGE="https://pytorch.org/"
SRC_URI="
	https://github.com/pytorch/${MYPN}/archive/refs/tags/v${PV}.tar.gz -> ${MYP}.tar.gz
	rocm? (
		https://github.com/ROCm/composable_kernel/archive/${CK_COMMIT}.tar.gz
		-> ${CK_P}.tar.gz
	)
	cuda? (
		flash? ( ${FLASH_ATT_URI} )
		memefficient? ( ${FLASH_ATT_URI} )
	)
"

S="${WORKDIR}"/${MYP}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cuda cusparselt distributed fbgemm flash gloo kineto memefficient
	mimalloc mkl mpi nccl nnpack +numpy onednn openblas opencl openmp qnnpack
	rocm xnnpack"
RESTRICT="test"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	mpi? ( distributed )
	gloo? ( distributed )
	?? ( cuda rocm )
	rocm? (
		|| ( ${ROCM_REQUIRED_USE} )
		memefficient? ( flash )
	)
	cusparselt? ( || ( cuda rocm ) )
	flash? ( || ( cuda rocm ) )
	memefficient? ( || ( cuda rocm ) )
	nccl? ( rocm )
"

# The one-argument Quantize API works with FBGEMM 1.4 and 1.7, but 1.7's
# new rounding path is untested; retain the build-verified 1.4 cap.
# verified 2026-09-02
# aotriton-0.13b now matches upstream and supplies ROCm 10's rocm7.15 shim.
# verified 2026-09-02
# torch._C lives here; block older pytorch copies before merge.
RDEPEND="
	${PYTHON_DEPS}
	!!<sci-ml/pytorch-2.13.0
	dev-cpp/abseil-cpp:=
	dev-cpp/gflags:=
	>=dev-cpp/glog-0.5.0:=
	>=dev-libs/cpuinfo-2025.11.14
	dev-libs/libfmt:=
	dev-libs/protobuf:=
	dev-libs/sleef
	sci-ml/onnx
	virtual/lapack
	cuda? (
		dev-libs/cudnn
		>=sci-ml/cudnn-frontend-1.12.0:=
		>=dev-util/nvidia-cuda-toolkit-12.9:=[profiler]
		cusparselt? ( dev-libs/cusparselt )
	)
	fbgemm? ( >=sci-ml/FBGEMM-1.4 <sci-ml/FBGEMM-1.5 )
	gloo? ( >=sci-ml/gloo-2025.06.04[cuda?,rocm?] )
	kineto? ( ~sci-ml/kineto-0.4.0_p20260323 )
	mimalloc? ( dev-libs/mimalloc )
	mpi? ( virtual/mpi )
	nnpack? (
		sci-ml/NNPACK
		dev-libs/pthreadpool
	)
	numpy? ( $(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	') )
	onednn? ( sci-ml/oneDNN )
	opencl? ( virtual/opencl )
	qnnpack? (
		sci-ml/gemmlowp
		dev-libs/pthreadpool
	)
	rocm? (
		nccl? ( >=dev-libs/rccl-6.3:= <dev-libs/rccl-11:= )
		>=dev-util/hip-6.3:=       <dev-util/hip-11:=
		>=dev-util/roctracer-6.3:= <dev-util/roctracer-11:=
		>=sci-libs/hipBLAS-6.3:=   <sci-libs/hipBLAS-11:=[rocsolver(+)]
		>=sci-libs/hipBLASLt-6.3:= <sci-libs/hipBLASLt-11:=
		>=sci-libs/hipFFT-6.3:=    <sci-libs/hipFFT-11:=
		>=sci-libs/hipRAND-6.3:=   <sci-libs/hipRAND-11:=
		>=sci-libs/hipSOLVER-6.3:= <sci-libs/hipSOLVER-11:=
		>=sci-libs/hipSPARSE-6.3:= <sci-libs/hipSPARSE-11:=
		>=sci-libs/miopen-6.3:=    <sci-libs/miopen-11:=
		>=sci-libs/rocBLAS-6.3:=   <sci-libs/rocBLAS-11:=
		>=sci-libs/rocRAND-6.3:=   <sci-libs/rocRAND-11:=
		>=sci-libs/rocSOLVER-6.3:= <sci-libs/rocSOLVER-11:=
		memefficient? ( =sci-libs/aotriton-bin-0.13*:= )
		distributed? ( >=dev-util/rocm-smi-6.3:= <dev-util/rocm-smi-11:= )
		cusparselt? ( >=sci-libs/hipsparselt-6.3:= <sci-libs/hipsparselt-11:= )
	)
	distributed? (
		!rocm? ( sci-ml/tensorpipe[cuda?] )
		dev-cpp/cpp-httplib:=
	)
	xnnpack? (
		>=sci-ml/XNNPACK-2024.11
		dev-libs/pthreadpool
	)
	mkl? ( sci-libs/mkl )
	openblas? ( sci-libs/openblas )
"

DEPEND="
	${RDEPEND}
	dev-cpp/nlohmann_json
	dev-libs/flatbuffers
	dev-libs/FXdiv
	dev-libs/pocketfft
	dev-libs/psimd
	sci-ml/FP16
	$(python_gen_cond_dep '
		<dev-python/pybind11-3.0.5[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
	')
	cuda? ( >=dev-libs/cutlass-3.9.2[tools(+)] )
	onednn? ( sci-ml/ideep )
	rocm? (
		>=sci-libs/hipCUB-6.3:=    <sci-libs/hipCUB-11:=
		>=sci-libs/rocPRIM-6.3:=   <sci-libs/rocPRIM-11:=
		>=sci-libs/rocThrust-6.3:= <sci-libs/rocThrust-11:=
	)
	qnnpack? ( dev-libs/clog )
"

# Rebase against the post-sed source tree and keep shared patch names while
# their context remains exact. All patches apply without fuzz. verified 2026-09-02
PATCHES=(
	"${FILESDIR}"/${P}-unbundle_fmt.patch.xz
	"${FILESDIR}"/${P}-unbundle_kineto.patch.xz
	# Rebased for the Torch_SOURCE_DIR rename.
	"${FILESDIR}"/${P}-unbundle_pocketfft.patch.xz
	"${FILESDIR}"/${PN}-2.5.1-cudnn_include_fix.patch.xz
	"${FILESDIR}"/${P}-cpp-httplib.patch.xz
	"${FILESDIR}"/${PN}-2.5.1-glog-0.6.0.patch.xz
	"${FILESDIR}"/${PN}-2.7.0-glog-0.7.1.patch.xz
	# Use glog's public initialization API; the internal symbol does not link.
	# verified 2026-09-02
	"${FILESDIR}"/${PN}-2.13.0-glog-exception-init.patch.xz
	# Applies after the libaotriton-path rewrite below.
	"${FILESDIR}"/${PN}-2.12.0-aotriton-fixes.patch.xz
	"${FILESDIR}"/${PN}-2.8.0-rocm-minus-flash.patch.xz
	"${FILESDIR}"/${P}-rocm-distributed-link.patch.xz
	# hipFile is discovered but unused by PyTorch's CUDA-only CUFILE path; keep
	# it optional until ROCm storage support exists. verified 2026-09-03
	"${FILESDIR}"/${P}-rocm-hipfile-optional.patch.xz
	"${FILESDIR}"/${PN}-2.9.1-torch_cpu.patch.xz
	# Rebased around the new adjacent perfetto section.
	"${FILESDIR}"/${P}-gentoo.patch.xz
	"${FILESDIR}"/${P}-mimalloc.patch.xz
	# Preserve 2.14's expanded activity list while guarding Kineto.
	"${FILESDIR}"/${P}-removekineto-pr178960.patch.xz

	# Skip the submodule check for tarballs with system/prestaged deps.
	# verified 2026-07-18
	"${FILESDIR}"/${PN}-2.13.0-prebuildsteps-tarball-guard.patch.xz

	# Route install-time header wrapping through DESTDIR. verified 2026-07-18
	"${FILESDIR}"/${PN}-2.13.0-wrap-headers-destdir.patch.xz

	# Remove MKL cluster libs from the public link interface and force GNU OpenMP
	# so downstreams need neither Cluster Edition nor libiomp5. verified 2026-05-08
	"${FILESDIR}"/${PN}-2.12.0-mkl-public-scrub.patch.xz
)

src_prepare() {
	# Decompress patches into T because eapply cannot read xz payloads.
	local p b i
	mkdir -p "${T}"/patches || die
	for p in "${FILESDIR}"/*.patch.xz; do
		b=${p##*/}
		xz -dc "${p}" > "${T}/patches/${b%.xz}" || die
	done
	for i in "${!PATCHES[@]}"; do
		b=${PATCHES[i]##*/}
		PATCHES[i]="${T}/patches/${b%.xz}"
	done

	if use cuda && ( use flash || use memefficient ); then
		mv "${WORKDIR}"/${FLASH_P}/* third_party/${FLASH_PN}/ || die
	fi
	filter-lto #bug 862672

	sed -i \
		-e 's|::fmt-header-only||' \
		c10/CMakeLists.txt \
		cmake/Dependencies.cmake \
		torch/CMakeLists.txt \
		|| die

	# tensorpipe is in system, not a build target of caffe2
	sed -e '/target_compile_options_if_supported(tensorpipe/d' -i cmake/Dependencies.cmake || die

	sed -i \
		-e '/add_subdirectory.*third_party/d' \
		CMakeLists.txt \
		cmake/Dependencies.cmake \
		cmake/ProtoBuf.cmake \
		aten/src/ATen/CMakeLists.txt \
		|| die

	# System cutlass lacks an optional CuTeDSL example; do not fail mirroring.
	# Drop if cutlass starts installing it.
	# verified 2026-08-08
	sed -i -e 's/message(FATAL_ERROR/message(STATUS/' cmake/FileMirroring.cmake || die

	# The bundled fmt targets do not exist with system libfmt.
	# verified 2026-07-18
	sed -i \
		-e '/target_compile_definitions(fmt.*FMT_NO_UNIQUE_ADDRESS/d' \
		cmake/Dependencies.cmake \
		|| die
	sed -i \
		-e "/EXPORT/s|DESTINATION lib)|DESTINATION $(get_libdir))|" \
		c10/cuda/CMakeLists.txt \
		c10/CMakeLists.txt \
		c10/hip/CMakeLists.txt \
		|| die

	sed -i \
		-e "s|}/lib|}/\${CMAKE_INSTALL_LIBDIR}|g" \
		-e "/set(__AOTRITON_LIB/s|lib/|\${CMAKE_INSTALL_LIBDIR}/|g" \
		cmake/External/aotriton.cmake \
		|| die

	# Logging.h is incompatible with -Wextra-semi.
	sed -i 's/-Wextra-semi//' cmake/public/utils.cmake || die

	cmake_src_prepare
	pushd torch/csrc/jit/serialization > /dev/null || die
	flatc --cpp --gen-mutable --scoped-enums mobile_bytecode.fbs || die
	popd > /dev/null || die

	# Prefix hardcoded paths after applying patches.
	hprefixify \
		aten/CMakeLists.txt \
		caffe2/CMakeLists.txt \
		cmake/Metal.cmake \
		cmake/Modules/*.cmake \
		cmake/Modules_CUDA_fix/FindCUDNN.cmake \
		cmake/Modules_CUDA_fix/upstream/FindCUDA/make2cmake.cmake \
		cmake/Modules_CUDA_fix/upstream/FindPackageHandleStandardArgs.cmake \
		cmake/public/LoadHIP.cmake \
		cmake/public/cuda.cmake \
		cmake/Dependencies.cmake \
		torch/CMakeLists.txt \
		CMakeLists.txt

	if use rocm; then
		sed -e "s:/opt/rocm:/usr:" \
			-e "s:lib/cmake:$(get_libdir)/cmake:g" \
			-i cmake/public/LoadHIP.cmake || die

		# Drop when composable-kernel becomes a system dependency.
		sed -e "s:third_party/composable_kernel:../composable_kernel-${CK_COMMIT}:g" \
			-i aten/src/ATen/CMakeLists.txt || die

		# Keep the remaining gfx101x ISA guard missing upstream. bug #959808;
		# verified 2026-09-02
		pushd "${WORKDIR}/composable_kernel-${CK_COMMIT}" > /dev/null || die
		eapply "${T}"/patches/composable-kernel-5a74dec0-expand-isa.patch
		popd > /dev/null || die

		# Work around LLVM issue https://github.com/llvm/llvm-project/issues/100802.
		sed -e 's/std::memcpy/memcpy/g' -i torch/headeronly/util/Half.h || die

		ebegin "HIPifying cuda sources"
		FBCODE_BUILD_TOOL="buck" ${EPYTHON} tools/amd_build/build_amd.py || die
		eend $?
	fi
}

src_configure() {
	if use cuda && [[ -z ${TORCH_CUDA_ARCH_LIST} ]]; then
		ewarn "WARNING: caffe2 is being built with its default CUDA compute capabilities: 3.5 and 7.0."
		ewarn "These may not be optimal for your GPU."
		ewarn ""
		ewarn "To configure caffe2 with the CUDA compute capability that is optimal for your GPU,"
		ewarn "set TORCH_CUDA_ARCH_LIST in your make.conf, and re-emerge caffe2."
		ewarn "For example, to use CUDA capability 7.5 & 3.5, add: TORCH_CUDA_ARCH_LIST=7.5 3.5"
		ewarn "For a Maxwell model GPU, an example value would be: TORCH_CUDA_ARCH_LIST=Maxwell"
		ewarn ""
		ewarn "You can look up your GPU's CUDA compute capability at https://developer.nvidia.com/cuda-gpus"
		ewarn "or by running /opt/cuda/extras/demo_suite/deviceQuery | grep 'CUDA Capability'"
	fi

	local mycmakeargs=(
		-DBUILD_CUSTOM_PROTOBUF=OFF
		-DBUILD_TEST=OFF
		-DLIBSHM_INSTALL_LIB_SUBDIR="${EPREFIX}"/usr/$(get_libdir)
		-DPython_EXECUTABLE="${PYTHON}"
		-DTORCH_INSTALL_LIB_DIR="${EPREFIX}"/usr/$(get_libdir)
		-DUSE_CCACHE=OFF
		-DUSE_CUDA=$(usex cuda)
		-DUSE_DISTRIBUTED=$(usex distributed)
		-DUSE_FBGEMM=$(usex fbgemm)
		-DUSE_FLASH_ATTENTION=$(usex flash)
		-DUSE_GFLAGS=ON
		-DUSE_GLOG=ON
		-DUSE_GLOO=$(usex gloo)
		-DUSE_ITT=OFF
		-DUSE_KINETO=$(usex kineto)
		# KleidiAI and MAGMA are not packaged.
		-DUSE_KLEIDIAI=OFF
		-DUSE_MAGMA=OFF
		-DUSE_MEM_EFF_ATTENTION=$(usex memefficient)
		-DUSE_MIMALLOC=$(usex mimalloc)
		-DUSE_MKLDNN=$(usex onednn)
		-DUSE_MPI=$(usex mpi)
		-DUSE_NCCL=OFF
		-DUSE_NNPACK=$(usex nnpack)
		-DUSE_NUMA=OFF
		-DUSE_NUMPY=$(usex numpy)
		-DUSE_OPENCL=$(usex opencl)
		-DUSE_OPENMP=$(usex openmp)
		-DUSE_PYTORCH_QNNPACK=$(usex qnnpack)
		-DUSE_PYTORCH_METAL=OFF
		-DUSE_ROCM=$(usex rocm)
		-DUSE_SYSTEM_CPUINFO=ON
		-DUSE_SYSTEM_EIGEN_INSTALL=ON
		-DUSE_SYSTEM_FP16=ON
		-DUSE_SYSTEM_FXDIV=ON
		-DUSE_SYSTEM_GLOO=ON
		-DUSE_SYSTEM_NVTX=ON
		-DUSE_SYSTEM_ONNX=ON
		-DUSE_SYSTEM_PSIMD=ON
		-DUSE_SYSTEM_PTHREADPOOL=ON
		-DUSE_SYSTEM_PYBIND11=ON
		-DUSE_SYSTEM_SLEEF=ON
		-DUSE_SYSTEM_XNNPACK=$(usex xnnpack)
		-DUSE_TENSORPIPE=$(usex distributed $(usex !rocm))
		-DUSE_UCC=OFF
		-DUSE_VALGRIND=OFF
		-DUSE_XNNPACK=$(usex xnnpack)
		-DUSE_XPU=OFF
		-Wno-dev
	)

	if use mkl; then
		mycmakeargs+=(-DBLAS=MKL)
	elif use openblas; then
		mycmakeargs+=(-DBLAS=OpenBLAS)
	else
		mycmakeargs+=(-DBLAS=Generic -DBLAS_LIBRARIES=)
	fi

	if use cuda; then
		# Permit CUDA device probing in the sandbox (bugs #867706, #926116).
		cuda_add_sandbox
		addpredict "/dev/char/"

		mycmakeargs+=(
			-DUSE_CUDNN=ON
			-DTORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-3.5 7.0}"
			-DUSE_NCCL=OFF # CUDA NCCL is not packaged; nccl controls RCCL.
			-DCMAKE_CUDA_FLAGS="$(cuda_gccdir -f | tr -d \")"
			-DUSE_CUSPARSELT=$(usex cusparselt)
		)

		[[ -v CUDACXX ]] && export PYTORCH_NVCC="${CUDACXX}"

		if use flash; then
			export FLASH_ATTENTION_FORCE_BUILD="TRUE"
			export FLASH_ATTN_CUDA_ARCHS="${CUDAARCHS:-${TORCH_CUDA_ARCH_LIST:-3.5 7.0}}"
		fi

	elif use rocm; then
		export PYTORCH_ROCM_ARCH="$(get_amdgpu_flags)"

		# LoadHIP assumes an unslotted LLVM path; use Gentoo's HIP clang.
		# verified 2026-07-18
		export HIP_CLANG_PATH="$(hipconfig -l)"

		if use memefficient; then
			export AOTRITON_INSTALLED_PREFIX="${ESYSROOT}/usr"
		fi

		mycmakeargs+=(
			-DUSE_NCCL=$(usex nccl)
			-DUSE_SYSTEM_NCCL=ON
			-DCMAKE_REQUIRE_FIND_PACKAGE_HIP=ON
			-DCMAKE_DISABLE_FIND_PACKAGE_hipsparselt=$(usex !cusparselt) # disable automagic
			-DUSE_ROCM_CK_SDPA=OFF # requires flash + aiter, works only on gfx90a/gfx942/gfx950
		)

		append-cxxflags -Wno-deprecated-declarations -Wno-unused-result -Wno-unused-value
	fi

	if use onednn; then
		mycmakeargs+=(
			-DMKLDNN_FOUND=ON
			-DMKLDNN_LIBRARIES=dnnl
			-DMKLDNN_INCLUDE_DIR="${ESYSROOT}/usr/include/oneapi/dnnl"
		)
	fi

	cmake_src_configure
}

src_compile() {
	PYTORCH_BUILD_VERSION=${PV} \
	PYTORCH_BUILD_NUMBER=0 \
	cmake_src_compile
}

python_install() {
	python_domodule python/torch
	mkdir "${D}"$(python_get_sitedir)/torch/bin || die
	mkdir "${D}"$(python_get_sitedir)/torch/lib || die
	mkdir "${D}"$(python_get_sitedir)/torch/include || die
	ln -s ../../../../../include/torch \
		"${D}$(python_get_sitedir)"/torch/include/torch || die # bug 923269
	ln -s ../../../../../bin/torch_shm_manager \
		"${D}"/$(python_get_sitedir)/torch/bin/torch_shm_manager || die
	ln -s ../../../../../$(get_libdir)/libtorch_global_deps.so \
		"${D}"/$(python_get_sitedir)/torch/lib/libtorch_global_deps.so || die
}

src_install() {
	cmake_src_install

	# Drop the bundled /usr/lib aotriton copy; use the system libdir copy.
	# verified 2026-07-18
	if use rocm && use memefficient; then
		rm -rf "${ED}"/usr/lib/libaotriton_v2* "${ED}"/usr/lib/aotriton.images || die
	fi

	# CMake leaks wheel-layout files into /usr; keep only torch._C in
	# site-packages because pytorch supplies the pure-Python package.
	# verified 2026-07-22
	# Require the extension glob to match: silently deleting torch._C would pass
	# install yet break imports. Its destination has changed across releases.
	local _c_ext=( "${ED}"/usr/_C.cpython-*.so )
	[[ -f ${_c_ext[0]} ]] || die "torch._C not found at ${ED}/usr/ -- upstream moved its install destination"
	local _torchdir="${D}$(python_get_sitedir)/torch"
	mkdir -p "${_torchdir}" || die
	cp -p "${_c_ext[0]}" "${_torchdir}/" || die
	local d
	for d in "${ED}"/usr/*; do
		case ${d##*/} in
			bin|include|lib|lib64|share) ;;
			*) rm -rf "${d}" || die ;;
		esac
	done
	# On lib64 profiles remove leaked /usr/lib symlinks; never do this when
	# lib is the real payload directory.
	if [[ $(get_libdir) != lib && -d ${ED}/usr/lib ]]; then
		find "${ED}"/usr/lib -mindepth 1 -maxdepth 1 ! -name 'python*' \
			-exec rm -rf {} + || die
	fi

	# pytorch reuses this configuration.
	insinto "/var/lib/${PN}"
	doins "${BUILD_DIR}"/CMakeCache.txt

	rm -rf python
	mkdir -p python/torch || die
	cp torch/version.py python/torch/ || die
	python_install
}

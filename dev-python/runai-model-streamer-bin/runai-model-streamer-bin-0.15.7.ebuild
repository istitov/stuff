# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

MY_PN=${PN%-bin}
MY_PV=${PV}
MY_WHEEL_AMD64="${MY_PN//-/_}-${MY_PV}-py3-none-manylinux2014_x86_64.whl"
MY_WHEEL_ARM64="${MY_PN//-/_}-${MY_PV}-py3-none-manylinux2014_aarch64.whl"

DESCRIPTION="Run:ai's fast multi-tensor PyTorch model streamer (binary wheel)"
HOMEPAGE="
	https://github.com/run-ai/runai-model-streamer
	https://pypi.org/project/runai-model-streamer/
"
SRC_URI="
	amd64? (
		https://files.pythonhosted.org/packages/e3/af/f25776903164861b0c18149336abe89426efbd7993b92bf18b7f188345ca/${MY_WHEEL_AMD64}
	)
	arm64? (
		https://files.pythonhosted.org/packages/39/02/a016c73fda016c119fed3ee776605694217e45eca9ac8edf0260b6c4c295/${MY_WHEEL_ARM64}
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

# Upstream publishes architecture-specific manylinux wheels alongside a
# Bazel-based source build. The object-storage extras are split into separate
# upstream wheels that are not packaged yet; local-file loading works without
# them.
RDEPEND="
	>=sci-ml/pytorch-2.0.0[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/pytorch-3[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/humanize[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"
BDEPEND+="
	$(python_gen_cond_dep '
		dev-python/installer[${PYTHON_USEDEP}]
	')
"
EPYTEST_PLUGINS=()
distutils_enable_tests pytest
BDEPEND+="
	test? (
		$(python_gen_cond_dep '
			sci-ml/safetensors[${PYTHON_USEDEP}]
		')
	)
"

QA_PREBUILT="usr/lib/python3.*/site-packages/runai_model_streamer/libstreamer/lib/libstreamer.so"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	local f
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

python_install() {
	local wheels=( "${S}"/wheel/*.whl )
	[[ ${#wheels[@]} -eq 1 && -f ${wheels[0]} ]] ||
		die "expected exactly one wheel"
	${EPYTHON} -m installer --destdir="${D}" "${wheels[0]}" || die
	python_optimize
}

python_test() {
	local wheels=( "${S}"/wheel/*.whl )
	[[ ${#wheels[@]} -eq 1 && -f ${wheels[0]} ]] ||
		die "expected exactly one wheel"
	local test_root="${T}/test-${EPYTHON}"
	${EPYTHON} -m installer --destdir="${test_root}" "${wheels[0]}" || die
	local site_dir="${test_root}$(python_get_sitedir)"
	local -x PYTHONPATH="${site_dir}${PYTHONPATH:+:${PYTHONPATH}}"

	# The wheel omits test_mock.py's required test_files/test.safetensors.
	epytest --ignore="${site_dir}/runai_model_streamer/safetensors_streamer/tests/test_mock.py" \
		"${site_dir}/runai_model_streamer"
}

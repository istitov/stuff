# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

MY_PN=${PN%-bin}
MY_PV=${PV}
MY_WHEEL="${MY_PN//-/_}-${MY_PV}-py3-none-manylinux2014_x86_64.whl"

DESCRIPTION="Run:ai's fast multi-tensor PyTorch model streamer (binary wheel)"
HOMEPAGE="
	https://github.com/run-ai/runai-model-streamer
	https://pypi.org/project/runai-model-streamer/
"
SRC_URI="
	https://files.pythonhosted.org/packages/e3/af/f25776903164861b0c18149336abe89426efbd7993b92bf18b7f188345ca/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"

# Upstream releases only manylinux2014_x86_64 wheels and a Bazel-based
# source build. We ship the wheel so vllm has a working
# runai-model-streamer at runtime; cloud backends ([s3,gcs,azure])
# need google-cloud-storage / azure-identity which aren't packaged
# yet, so they're deferred — vllm's local-file model loading still
# works without them.
RDEPEND="
	dev-python/humanize[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=sci-ml/pytorch-2.0.0[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3.*/site-packages/runai_model_streamer/libstreamer/*"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

src_install() {
	local impl_lib_dir
	python_foreach_impl install_wheel
}

install_wheel() {
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die
}

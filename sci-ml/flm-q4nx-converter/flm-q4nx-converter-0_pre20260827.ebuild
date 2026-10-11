# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-single-r1

# Upstream has no releases or tags; this is the tip of main on 2026-08-27.
MY_COMMIT="d1d5232d0b82871bf5265e990fa2d26cdad22327"

DESCRIPTION="Convert GGUF fine-tunes to FastFlowLM's Q4NX format for the Ryzen AI NPU"
HOMEPAGE="https://github.com/ROCm/FLM_Q4NX_Converter"
SRC_URI="
	https://github.com/ROCm/FLM_Q4NX_Converter/archive/${MY_COMMIT}.tar.gz
		-> ${P}.tar.gz
"
S="${WORKDIR}/FLM_Q4NX_Converter-${MY_COMMIT}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Taken from the imports. Upstream's setup_venv.sh installs more (transformers,
# amd-quark, accelerate, matplotlib), none of which the code uses.
# verified 2026-10-11
RDEPEND="
	${PYTHON_DEPS}
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/einops[${PYTHON_USEDEP}]
		dev-python/gguf[${PYTHON_USEDEP}]
		dev-python/mpmath[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		sci-ml/safetensors[${PYTHON_USEDEP}]
	')
"
# python_optimize runs the interpreter at build time.
BDEPEND="${PYTHON_DEPS}"

PATCHES=(
	# Find the layout configs from any working directory.
	"${FILESDIR}/${P}-configs-path.patch"
	# Dense Qwen3.5 output lacks tensors FastFlowLM requires (issue #22).
	# https://github.com/ROCm/FLM_Q4NX_Converter/pull/23, open 2026-10-11
	"${FILESDIR}/${P}-qwen35-prefill-copies.patch"
	# Qwen3.8-27B, which FastFlowLM ships from 1.0.7 on and upstream cannot
	# convert: first the dense path reads its layout from the GGUF, then the
	# model is added. Not upstream. verified 2026-10-11
	"${FILESDIR}/${P}-qwen35-value-heads.patch.xz"
	"${FILESDIR}/${P}-qwen38-27b.patch.xz"
	# gguf-py stores "Qwen3.8-27B-MyTune" as basename "Qwen3.8" and size label
	# "27B"; matched by basename alone, such a file is taken for plain Qwen3,
	# and a renamed fine-tune for nothing. Try basename-size first and
	# architecture-size last. Not upstream. verified 2026-10-11
	"${FILESDIR}/${P}-detect-size-label.patch"
)

src_prepare() {
	# eapply does not decompress: expand the .xz patches and repoint PATCHES.
	local i p
	for i in "${!PATCHES[@]}"; do
		p=${PATCHES[i]}
		[[ ${p} == *.xz ]] || continue
		PATCHES[i]="${T}/$(basename "${p}" .xz)"
		xz -dc "${p}" > "${PATCHES[i]}" || die
	done
	default
}

src_install() {
	# No pyproject.toml upstream, and convert.py is a top-level script that
	# q4nx imports back, so the tree is kept together outside site-packages.
	local dest="/usr/share/${PN}"
	insinto "${dest}"
	doins -r convert.py q4nx configs
	python_optimize "${ED}${dest}"

	newbin - flm-q4nx-convert <<-EOF
	#!/bin/sh
	exec "${PYTHON}" "${EPREFIX}${dest}/convert.py" "\$@"
	EOF

	# Header comparison against the base model's official weights.
	python_doscript "${FILESDIR}/flm-q4nx-check"

	dodoc README.md
}

pkg_postinst() {
	elog "flm-q4nx-convert repacks the weights of a GGUF file. It cannot build NPU"
	elog "kernels, so the source must be a fine-tune of a model FastFlowLM ships."
	elog "Compare the result with the base model's official file using"
	elog "flm-q4nx-check, then register it with flm-custom-sync from"
	elog "sci-ml/fastflowlm."
}

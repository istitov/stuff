# stuff

A Gentoo ebuild overlay that ships hard-to-package software as
first-class portage citizens — dependency-resolved, built from source,
and managed with `emerge` like everything else on the system, instead
of through manual git builds, vendor `.deb`s, or conda environments
that leave the package manager blind to what's installed.

No single flagship — a curated, multi-niche overlay.
Front-door slices: **local AI & GPU compute** (AMD Ryzen-AI / NPU ·
AMD ROCm · NVIDIA CUDA, with LLM runtimes and the PyTorch / ONNX
ecosystem) · **scientific physics** (SAXS / SANS / XAFS · electron
microscopy · micromagnetism · Rietveld) · **`pf-sources`** (curated
pf-kernel patchset) · **DeaDBeeF** plugins · **TeX Live** · a
**Python 2** legacy preservation layer.

```sh
eselect repository enable stuff
emerge --sync stuff
```

[![Package checks](https://github.com/istitov/stuff/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/istitov/stuff/actions/workflows/pkgcheck.yml)

See [**Overlay:Stuff**](https://wiki.gentoo.org/wiki/Overlay:Stuff) on the
Gentoo Wiki for enabling the overlay and a package-area overview.

## Mirrors

Auto-mirrored on every push:

- [github.com/istitov/stuff](https://github.com/istitov/stuff) (primary)
- [gitlab.com/istitov/stuff](https://gitlab.com/istitov/stuff)
- [codeberg.org/istitov/stuff](https://codeberg.org/istitov/stuff)

## Highlights

### AMD Ryzen-AI / NPU stack

NPU-first LLM tooling for AMD Ryzen AI (XDNA / XDNA2). Application layer plus
the driver and runtime it needs:

- [`sci-ml/fastflowlm`](https://fastflowlm.com/) — NPU-first LLM runtime
  (chat, model pull).
- [`sci-ml/lemonade`](https://lemonade-server.ai/) — AMD Lemonade SDK.
- [`sci-ml/kokoros`](https://github.com/lucasjinreal/Kokoros) — Kokoro
  TTS server (Rust + Python).
- [`sci-ml/amd-gaia`](https://github.com/amd/gaia) — AMD GAIA stack
  with `api / audio / eval / image / mcp / talk / ui` USE flags.
- [`dev-libs/xdna-driver`](https://github.com/amd/xdna-driver),
  `dev-libs/xrt-xdna`, [`dev-util/xrt`](https://github.com/Xilinx/XRT)
  — NPU driver and the XDNA-extended Xilinx Runtime.

### Local LLM tooling

Backend-agnostic servers, model-swap proxy, CLI clients, and web UI.
Pairs with `fastflowlm` / `lemonade` above as well as `vllm` and any
other OpenAI-compatible endpoint:

- [`sci-misc/llama-cpp`](https://github.com/ggml-org/llama.cpp) —
  llama.cpp server / runtime. Bundled web UI provisioned at configure
  time (default on; disable with `USE=-webui`).
- [`sci-ml/ollama`](https://ollama.com) — the Ollama model-server
  (CUDA / ROCm / CPU backends), with `acct-user/ollama` +
  `acct-group/ollama` and systemd / openrc service files.
- [`sci-misc/llama-swap`](https://github.com/mostlygeek/llama-swap) —
  Go HTTP proxy that lifecycle-manages multiple inference backends and
  routes OpenAI/Anthropic-compatible requests to the right one. Optional
  embedded Svelte UI via `USE=ui`; vendored Go modules on extra-stuff.
- [`www-apps/hollama`](https://github.com/fmaclen/hollama) — Minimal
  chat UI (SvelteKit + Node, browser-localStorage state, no
  server-side persistence). Talks to Ollama natively and any
  OpenAI-compatible endpoint. systemd unit + openrc service files;
  loopback-only by default.
- [`dev-util/aichat`](https://github.com/sigoden/aichat) — All-in-one
  LLM CLI (Chat-REPL, shell assistant, RAG, agents); multi-provider,
  single Rust binary.
- [`dev-util/rtk`](https://github.com/rtk-ai/rtk) — "Rust Token Killer"
  CLI proxy that filters dev-command output (cargo, npm, pytest, …)
  before it reaches your LLM session, cutting token consumption.
- [`dev-util/argc`](https://github.com/sigoden/argc) — Bash CLI
  framework + Argcfile.sh task runner; infrastructure for sigoden's
  tooling cluster.
- `sci-ml/lm-eval` (lm-evaluation-harness), `sci-ml/evalplus`
  (HumanEval+ / MBPP+), and
  [`sci-ml/bigcode-eval`](https://github.com/bigcode-project/bigcode-evaluation-harness)
  — harnesses for benchmarking local language / code models.

### Speech / audio ML stack

ASR, speaker diarization, and audio DSP packages:

- [`app-accessibility/whisper-cpp`](https://github.com/ggml-org/whisper.cpp)
  — Whisper.cpp offline ASR.
- [`sci-ml/sherpa-onnx`](https://k2-fsa.github.io/sherpa/onnx/) +
  `sci-ml/sherpa-onnx-bin` — Next-gen-Kaldi ONNX ASR / TTS / speaker-id
  (source build and prebuilt-wheel flavour).
- [`sci-ml/pyannote-audio`](https://github.com/pyannote/pyannote-audio)
  plus the `pyannote-{pipeline,metrics,database,core}` chain and
  [`sci-ml/pyannoteai-sdk`](https://github.com/pyannote/pyannoteAI-python-sdk) — speaker-diarization
  toolkit.
- `sci-ml/torch-audiomentations` + `sci-ml/torch-pitch-shift` +
  [`sci-ml/asteroid-filterbanks`](https://github.com/asteroid-team/asteroid-filterbanks)
  + [`sci-ml/julius`](https://github.com/adefossez/julius) — neural-net
  friendly audio DSP / augmentation building blocks.

### PyTorch / ONNX ecosystem additions

General-purpose ML infrastructure not covered by `::gentoo`,
pulled in alongside the speech stack above and broadly useful on
their own:

- [`sci-ml/lightning`](https://lightning.ai/) + `sci-ml/lightning-utilities`
  — PyTorch Lightning training framework.
- [`sci-ml/torchmetrics`](https://github.com/Lightning-AI/torchmetrics)
  — metric collection for PyTorch training loops.
- [`sci-ml/pytorch-metric-learning`](https://github.com/KevinMusgrave/pytorch-metric-learning)
  — embedding / metric-learning utilities.
- [`sci-ml/torchcodec`](https://github.com/meta-pytorch/torchcodec) — PyTorch
  video / audio decoder.
- [`sci-libs/onnxruntime`](https://onnxruntime.ai/),
  [`sci-libs/dlpack`](https://github.com/dmlc/dlpack),
  [`dev-cpp/safeint`](https://github.com/dcleblanc/SafeInt) — the ONNX
  inference engine plus its in-memory tensor-exchange / overflow-safe-int
  building blocks.
- [`dev-python/optuna`](https://optuna.org/) — hyperparameter
  optimization.
- `sci-libs/faiss` — FAISS: efficient similarity search and clustering of
  dense vectors (the vector-index building block for embeddings / RAG).

### ROCm 7.2.4

Local bumps of the [ROCm](https://rocm.docs.amd.com/) / HIP 7.2 stable
line (7.2.3 and 7.2.4) ahead of `::gentoo`: the full runtime, compiler,
and math / communication libraries (`rocm-core`, `hip`, `hipBLAS` /
`rocBLAS`, `hipFFT` / `rocFFT`, `MIOpen`, `composable-kernel`, `rccl`, …)
plus the `rocm-smi` / `rocminfo` tooling, across `dev-libs/`,
`dev-util/`, `dev-build/`, and `sci-libs/`.

[`dev-util/therock-bin`](https://github.com/ROCm/TheRock) is a
/opt-installed ROCm SDK that pulls AMD's nightly TheRock build for a
per-host `AMDGPU_TARGETS`. Coexists with the /usr ROCm above; an
nvchecker regex source on AMD's CDN tracks new nightlies.

### RAPIDS GPU computing

GPU-accelerated dataframes and distributed compute (RAPIDS 26.6), not
in `::gentoo`: `dev-python/rmm` + `dev-python/librmm` (GPU memory
manager), `dev-python/dask-cuda` (multi-GPU Dask clusters), plus
`dev-python/rapids-logger` and `dev-python/rapids-dask-dependency`.

### 3D generative (Gaussian splatting / mesh)

Image-to-3D and Gaussian-splat / mesh generation — the stack behind
the TRELLIS pipeline, fronted by
[`media-gfx/comfyui-if-trellis`](https://github.com/if-ai/ComfyUI-IF_Trellis):
[`dev-python/diff-gaussian-rasterization`](https://github.com/autonomousvision/mip-splatting)
and [`dev-python/diffoctreerast`](https://github.com/JeffreyXiang/diffoctreerast)
(differentiable rasterizers),
[`dev-python/nvdiffrast`](https://github.com/NVlabs/nvdiffrast)
(differentiable rendering), `dev-python/spconv-cu126` (sparse
convolution), `dev-python/xatlas` + `dev-python/pymeshfix` +
`dev-python/plyfile` (mesh UV-unwrap / repair / I/O), and
[`dev-python/vox2seq`](https://github.com/microsoft/TRELLIS) +
[`dev-python/utils3d`](https://github.com/EasternJournalist/utils3d)
helpers.

### HyperSpy / 4D-STEM electron-microscopy stack

A full [HyperSpy](https://hyperspy.org) ecosystem that is not in `::gentoo`:

`hyperspy`, `hyperspyui`, `hyperspy-gui-traitsui`, `hyperspy-gui-ipywidgets`,
[`rosettasciio`](https://hyperspy.org/rosettasciio/), `emdfile`, `ncempy`,
`exspy`, [`atomap`](https://atomap.org/),
[`pyxem`](https://github.com/pyxem/pyxem),
[`py4dstem`](https://github.com/py4dstem/py4DSTEM).

Packaging follows upstream's split into a core (`hyperspy`) plus GUI backends
and per-domain extensions (`exspy` for EELS/EDS, `atomap` for atomic-column
analysis, `pyxem` / `py4dstem` for 4D-STEM, `ncempy`/`emdfile`/`rosettasciio`
for I/O).

### SANS / SAXS / XAFS analysis

- [`sci-physics/mantid`](https://www.mantidproject.org/) — SANS reduction
  and analysis. Installs under `/opt/mantid` and keeps building against
  the current `::gentoo` by carrying a few local deps (see the
  *Qt5 revival mirror* section below).
- [`sci-physics/sasview`](https://www.sasview.org/) + `dev-python/sasmodels`
  + `dev-python/bumps` + `dev-python/periodictable` — SAS modeling and
  fitting.
- [`sci-libs/ausaxs`](https://github.com/AUSAXS/AUSAXS) +
  [`dev-python/pyausaxs`](https://github.com/AUSAXS/pyAUSAXS) — AUSAXS
  solvent-scattering calculator and its Python bindings.
- [`sci-physics/bornagain`](https://bornagainproject.org/) — simulate and
  fit X-ray / neutron reflectometry and grazing-incidence small-angle
  scattering (GISAS / GISANS), with its `sci-libs/libformfactor` +
  `sci-libs/libheinz` libraries.
- [`sci-physics/xraylarch`](https://xraypy.github.io/xraylarch/) — XAFS
  analysis; modern replacement for the discontinued `ifeffit`.
- [`sci-physics/demeter`](https://github.com/bruceravel/demeter) —
  classic Athena/Artemis XAFS GUIs (Perl).

### DeaDBeeF plugin collection

Twenty-six [`media-plugins/deadbeef-*`](https://deadbeef.sourceforge.io/)
packages, covering audio format
support (`opus`, `vgmstream`, `vfs-rar`, `archive-reader`, `bs2b`),
visualization (`spectrogram`, `musical-spectrum`, `vu-meter`, `dr-meter`,
`waveform-seekbar`), playback/session control
(`playback-order`, `playback-status`, `headerbar`, `quick-search`, `rating`,
`replaygain-control`), file browsing (`fb`, `bookmark-manager`), desktop
integration (`gnome`, `statusnotifier`, `discord-presence`) and output
plumbing (`jack`, `pulse2`, `stereo-widener`, `copy-info`,
`customizable-toolbar`).

### Micromagnetism

[`sci-physics/mumax`](https://mumax.github.io/) (GPU finite-difference,
Go + CUDA), [`sci-physics/oommf`](https://math.nist.gov/oommf/) (Tcl/Tk
reference implementation), and
[`sci-physics/vampire`](https://www-users.york.ac.uk/~rfle500/research/vampire/) (atomistic spin
dynamics).

### Rietveld refinement

X-ray powder diffraction and Rietveld refinement:
[`sci-physics/bgmn`](http://www.bgmn.de/) (the BGMN refinement engine)
and [`sci-physics/profex`](http://www.profex-xrd.org/) (Profex, its Qt6
GUI front-end).

### TeX Live

Current TeX Live, kept ahead of `::gentoo`'s stabilized line: the full
`dev-texlive/*` collection set at the TL2025 and TL2026 releases (recent
tlpdb revisions), with upstream package additions, removals, and
relocations tracked per release — plus `dev-tex/{biber, biblatex,
latexmk, minted, pgf, tex4ht, …}` build tooling.

## Design choices

### Python 2 preservation

`::gentoo` dropped Python 2 from its packaging eclasses in 2024 — its
`distutils-r1` no longer builds py2 modules, though it still ships the
`dev-lang/python:2.7` interpreter. `sci-visualization/gwyddion` 2.x ships
`pygwy`, Python 2 bindings used by user analysis scripts;
Gwyddion 3's GI bindings don't yet cover everything `pygwy` exposes, so
those scripts still need a py2 runtime. This overlay vendors a small
Python 2 surface to keep them working:

- **Locally-vendored eclasses** in `eclass/`: `distutils-r1_py2`,
  `python-r1_py2`, `python-single-r1_py2`, `python-utils-r1_py2`.
  Inheriting one of these is the signal that a package is intentionally
  pinned to py2.
- **py2 forks of core libs** under `dev-python/*-python2`:
  `numpy-python2`, `certifi-python2`, `setuptools-python2`,
  `setuptools_scm-python2`, `pycairo-python2`. Named distinctly so they can
  coexist with the py3 versions from `::gentoo`.
- **py2-only legacy packages** kept as-is: `pygobject-2.28.6`, `pygtk-2.24.0`,
  `unittest-or-fail`.

Expected `pkgcheck` warnings from this corner (`UnderscoreInUseFlag`,
`PythonMismatchedPackageName`, `RequiredUseDefaults`) are suppressed globally
in `metadata/pkgcheck.conf` with a comment explaining why.

### Qt5 revival mirror

`::gentoo` last-rited the entire `dev-qt:5` set on 2026-05-15
(bug #948836) and started treecleaning Qt5 consumers
(`dev-python/pyqt5` went 2026-05-21). `sci-physics/mantid` and a few
other consumers will need Qt5 through 2026 at minimum, so this overlay
carries the full slot:5 set at **v5.15.19-lts-lgpl** with the
[KDE Qt5 Patch Collection](https://invent.kde.org/qt/qt) applied via
the local `qt5-build.eclass`.

- **The full 23-module `dev-qt/*` slot:5 set at 5.15.19** — qtbase
  (`qtcore`, `qtgui`, `qtwidgets`, `qtnetwork`, …) plus the add-on
  modules (`qtdeclarative`, `qtmultimedia`, `qtsvg`, `qtwayland`,
  `qtwebchannel`, …). All keyworded `~arch` except `qtwebchannel`
  (`~amd64 ~x86`, per upstream's narrower history). `dev-qt/qthelp`
  and `dev-qt/qtwebchannel` keep their pre-import 5.15.18 ebuilds
  alongside; the other 21 ship 5.15.19 only.
- **`dev-python/pyqt5` + `dev-python/pyqt5-sip`** — revived at
  PyPI-latest after `::gentoo`'s treeclean.
- **`x11-libs/qscintilla-2.14.1-r1`** (the last Qt5-compatible slot),
  with `=x11-libs/qscintilla-2.14.1-r2` (Qt6-only) masked in
  `profiles/package.mask`.
- **KDE Qt5 Patch Collection bundles** mirrored to
  [extra-stuff](https://github.com/istitov/extra-stuff) as signed-tag-pinned
  `.tar.xz` distfiles; the eclass fans the SRC_URI out across the
  github / codeberg / gitlab raw URLs.
- **`profiles/package.unmask`** overrides `::gentoo`'s bare `dev-qt/*:5`
  masks so these ebuilds stay installable for overlay users.

Drop the mirror once mantid finishes its Qt6 port and the other
consumers follow.

### Other targeted fixes kept in-tree

- `sci-libs/hdf` — local bumps carrying a gcc 15 build fix, plus a
  release ahead of `::gentoo`.
- `x11-libs/gtk+-2.24.33-r99` — gtk+:2 holdover for apps that still need it.
- `dev-python/bokeh` — older 2.x dropped; 3.x kept with the
  deprecated `flaky` test dep removed.
- `dev-python/py4dstem` — carries upstream PR #712 for numpy 2
  compatibility.
- `dev-python/cupy` — ROCm USE flag dropped from cupy 13 (its HIP
  backend is incompatible with ROCm 7.x hipBLAS); cupy 14 dropped ROCm
  support entirely upstream.
- Several `media-plugins/deadbeef-*` plugins carry patches for DeaDBeeF's
  modernized C API.

## Also here

- **XMPP clients** — [`net-im/profanity`](https://profanity-im.github.io/),
  `net-im/stabber`, `net-im/xmppconsole`, `dev-libs/libstrophe`.
- **Collaborative editing** — [`app-editors/gobby`](https://gobby.github.io/),
  `net-libs/libinfinity`, `acct-{group,user}/infinote`.
- **Kernel / low-level** —
  [`sys-kernel/pf-sources`](https://pfkernel.natalenko.name/),
  `sys-kernel/pf-sources-extended` (curated pf-patchset model on top
  of vanilla + Gentoo genpatches), `sys-apps/dkms-gentoo`,
  `sys-kernel/kernel-cleaner`.
- **Visualization** —
  [`sci-visualization/gwyddion`](https://gwyddion.net/),
  `sci-visualization/gwyddion3`.
- **3D printing** — [`media-gfx/orcaslicer`](https://www.orcaslicer.com/),
  the open-source slicer (a PrusaSlicer / Bambu Studio fork), with
  `x11-libs/wxGTK` 3.3 pulled ahead of `::gentoo`'s 3.2 (and a local
  `wxwidgets.eclass` that accepts the new `3.3-gtk3` slot) to build it.
- **Crystallography / atomistic** —
  [`sci-physics/prismatic`](https://prism-em.com/),
  [`sci-libs/nexus`](https://www.nexusformat.org/),
  `sci-libs/pycifrw`.
- **SuiteSparse imports** —
  [`sci-libs/{amd,camd,cholmod,colamd,ccolamd,umfpack,suitesparseconfig}`](https://people.engr.tamu.edu/davis/suitesparse.html).
- **Retro / fun** —
  [`x11-terms/cool-retro-term`](https://github.com/Swordfish90/cool-retro-term),
  [`games-roguelike/adom`](https://www.adom.de/),
  [`games-roguelike/dwarftherapist`](https://github.com/Dwarf-Therapist/Dwarf-Therapist),
  `games-misc/fortune-mod-lorquotes`.
- **Niche tools** — [`dev-lang/tcc`](https://repo.or.cz/w/tinycc.git),
  [`dev-vcs/fossil`](https://fossil-scm.org/),
  [`app-office/mytetra`](http://webhamster.ru/site/page/index/articles/projectcode/138),
  `app-misc/tudu`,
  [`sys-fs/google-drive-ocamlfuse`](https://github.com/astrada/google-drive-ocamlfuse),
  [`app-text/pandoc-crossref-bin`](https://github.com/lierdakil/pandoc-crossref),
  [`app-portage/portconf`](https://github.com/istitov/portconf)
  (`/etc/portage` cleaner; forked to istitov and bumped to the 2.x
  series in this overlay).
- **CUDA / generic ML inference** —
  [`dev-python/cuda-bindings`](https://github.com/NVIDIA/cuda-python),
  `dev-python/cuda-python`, `dev-python/cuda-pathfinder`,
  `dev-python/cuda-tile-bin`,
  [`dev-python/pycuda`](https://documen.tician.de/pycuda/),
  [`dev-util/nvidia-cuda-toolkit`](https://developer.nvidia.com/cuda-toolkit),
  [`dev-python/vllm`](https://github.com/vllm-project/vllm) (optional
  `USE=humming` pulls `dev-python/humming-kernels` for MXFP4
  quantization), and [`dev-util/zluda`](https://github.com/vosen/ZLUDA) —
  a drop-in CUDA runtime for AMD GPUs.
- **Masked but kept**: `net-misc/ipx-utils` (IPX removed from Linux in 4.18),
  `app-portage/portopts` (upstream dormant since 2014). Each mask in
  `profiles/package.mask` carries a comment explaining why and when it
  should lift.

## Repository layout and conventions

- **Thin manifests**, `masters = gentoo` only. Every package depends on
  `::gentoo` being enabled.
- **Profiles** under `profiles/` follow standard PMS layout.
- **Keywording** — packages are primarily `~amd64`; `~arm64`
  keywording is being rolled out across the tree.
- **Patches** live in `<category>/<package>/files/` and are applied via
  `PATCHES=()` or `src_prepare()`.
- **Commit messages** use subject + body form (72-char subject, blank line,
  rationale). Single-line messages only for truly trivial edits.
- **`metadata/pkgcheck.conf`** documents *which* checks are suppressed and
  *why* (not just that they're suppressed).
- **CI** runs `pkgcheck scan` on every PR and push (delta only), plus a
  full repo scan every three days via scheduled workflow. URL-liveness
  checks (`pkgcheck scan --net`) are not part of CI; run them locally
  if you change an upstream URL.
- **Documentation** — [`CONTRIBUTING.md`](CONTRIBUTING.md) (house-style
  checklist, AI/LLM disclosure expectation),
  [`SECURITY.md`](SECURITY.md) (vulnerability reporting via GitHub
  private advisories), [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
- **News items** — `eselect news read` after `emerge --sync stuff`
  surfaces GLEP-42 announcements for migrations, mask windows, and
  CVE-sensitive notices. Items live in
  [`metadata/news/`](metadata/news/).
- **Upstream version tracking** —
  [`scripts/nvchecker/`](scripts/nvchecker/) holds the
  generated `nvchecker.toml` plus a local-cron runner
  (`run.sh`) and the regenerator (`generate.py`). A weekly CI
  job at [`.github/workflows/nvchecker.yml`](.github/workflows/nvchecker.yml)
  runs the same config against the tree as baseline and uploads
  a drift artifact.

## Credits

Originally created by [@megabaks](https://github.com/megabaks) and now
maintained by [Ivan S. Titov](https://wiki.gentoo.org/wiki/User:Istitov); see
the [contributors list](https://github.com/istitov/stuff/graphs/contributors)
for everyone who has contributed since. Thank you.

## License

Original packaging files — ebuilds, eclasses, `metadata.xml`, profiles, and
news items — are distributed under the GNU General Public License v2,
matching `::gentoo`'s per-file header convention and its
[Copyright Policy (GLEP 76)](https://www.gentoo.org/glep/glep-0076.html).

Patches that modify upstream code are derivative works of it and carry that
code's own license, as do the upstream sources themselves; the applicable
license is the one declared in each ebuild's `LICENSE` variable — e.g. the
`dev-python/py4dstem` numpy-2 patch is GPL-3 and the `media-libs/opencv`
patches are Apache-2.0, not GPL-2. This mirrors GLEP 76's Certificate of
Origin, under which a contribution "based upon previous work" is submitted
"under the same free software license" as that prior work.

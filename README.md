# stuff

A Gentoo ebuild overlay.

```sh
eselect repository enable stuff
emerge --sync stuff
```

[![Package checks](https://github.com/istitov/stuff/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/istitov/stuff/actions/workflows/pkgcheck.yml)

## Mirrors

Auto-mirrored on every push:

- [github.com/istitov/stuff](https://github.com/istitov/stuff) (primary)
- [gitlab.com/istitov/stuff](https://gitlab.com/istitov/stuff)
- [codeberg.org/istitov/stuff](https://codeberg.org/istitov/stuff)

## Highlights

### AMD Ryzen-AI / NPU stack

NPU-first LLM tooling for AMD Ryzen AI (XDNA2). Application layer plus
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
- [`sci-ml/torchcodec`](https://github.com/pytorch/torchcodec) — PyTorch
  video / audio decoder.
- [`sci-libs/onnxruntime`](https://onnxruntime.ai/) 1.26.0,
  [`sci-libs/dlpack`](https://github.com/dmlc/dlpack),
  [`dev-cpp/safeint`](https://github.com/dcleblanc/SafeInt) — the ONNX
  inference engine plus its in-memory tensor-exchange / overflow-safe-int
  building blocks.
- [`dev-python/optuna`](https://optuna.org/) — hyperparameter
  optimization.

### ROCm 7.2.3

Local bumps of the [ROCm](https://rocm.docs.amd.com/) 7.2 stable line
ahead of `::gentoo`'s 7.2.0:
`dev-libs/rocm-{core,comgr,device-libs,opencl-runtime}`, `dev-libs/rccl`,
`dev-libs/hipother`, `dev-build/rocm-cmake`,
`dev-util/{hip,hipcc,hipify-clang,rocm-smi,rocminfo,rocm_bandwidth_test}`,
`sci-libs/{hipBLAS,hipBLAS-common,hipBLASLt,hipCUB,hipFFT,hipRAND,hipSOLVER,hipSPARSE,hipsparselt,composable-kernel,miopen,rocBLAS,rocFFT,rocPRIM,rocRAND,rocSOLVER,rocSPARSE,rocThrust}`.

[`dev-util/therock-bin`](https://github.com/ROCm/TheRock) is a
/opt-installed ROCm SDK that pulls AMD's nightly TheRock build for a
per-host `AMDGPU_TARGETS`. Coexists with the /usr ROCm above; an
nvchecker regex source on AMD's CDN tracks new nightlies.

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
  the current `::gentoo` by carrying a few local deps (see *Qt5 revivals*
  below).
- [`sci-physics/sasview`](https://www.sasview.org/) + `dev-python/sasmodels`
  + `dev-python/bumps` + `dev-python/periodictable` — SAS modeling and
  fitting.
- [`sci-libs/ausaxs`](https://github.com/AUSAXS/AUSAXS) +
  [`dev-python/pyausaxs`](https://github.com/AUSAXS/pyAUSAXS) — AUSAXS
  solvent-scattering calculator and its Python bindings.
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
[`sci-physics/vampire`](https://vampire.york.ac.uk/) (atomistic spin
dynamics).

## Design choices

### Python 2 preservation

`::gentoo` removed Python 2 support in 2024. `sci-visualization/gwyddion`
2.x ships `pygwy`, Python 2 bindings used by user analysis scripts;
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

- **23 `dev-qt/*` packages at 5.15.19** — `linguist-tools`,
  `qtconcurrent`, `qtcore`, `qtdbus`, `qtdeclarative`,
  `qtgraphicaleffects`, `qtgui`, `qthelp`, `qtmultimedia`, `qtnetwork`,
  `qtopengl`, `qtprintsupport`, `qtquickcontrols`, `qtquickcontrols2`,
  `qtsql`, `qtsvg`, `qttest`, `qttranslations`, `qtwayland`,
  `qtwebchannel`, `qtwidgets`, `qtx11extras`, `qtxml`. All keyworded
  `~arch` (qtwebchannel limited to `~amd64 ~x86` per upstream's
  narrower keyword history). `dev-qt/qthelp` and `dev-qt/qtwebchannel`
  keep their pre-import 5.15.18 ebuilds alongside; the other 21 ship
  5.15.19 only.
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

- `sci-libs/hdf` 4.2.16 / 4.3.1 — local bumps; 4.2.16 carries a gcc 15
  build fix, 4.3.1 is ahead of `::gentoo`'s 4.2.15-r2.
- `x11-libs/gtk+-2.24.33-r99` — gtk+:2 holdover for apps that still need it.
- `dev-python/bokeh` — 2.4.2 dropped, 3.4.1 and 3.9.0 kept with the
  deprecated `flaky` test dep removed.
- `dev-python/py4dstem` 0.14.18 — carries upstream PR #712 for numpy 2
  compatibility.
- `dev-python/cupy` 13.6.0 / 14.0.1 — ROCm USE flag dropped from 13.6.0
  (cupy 13's HIP backend is incompatible with ROCm 7.x hipBLAS); cupy 14
  dropped ROCm support entirely upstream.
- Several `media-plugins/deadbeef-*` plugins carry patches for DeaDBeeF's
  modernized C API.

## Also here

- **XMPP clients** — [`net-im/profanity`](https://profanity-im.github.io/),
  `net-im/stabber`, `net-im/xmppconsole`, `dev-libs/libstrophe`.
- **Collaborative editing** — [`app-editors/gobby`](https://gobby.github.io/),
  `net-libs/libinfinity`, `acct-{group,user}/infinote`.
- **Kernel / low-level** —
  [`sys-kernel/pf-sources`](https://pfkernel.natalenko.name/),
  [`sys-kernel/flex-sources`](https://codeberg.org/pf-kernel/linux)
  (pf-kernel's "flex" sibling spine, tracking pre-release upstream
  kernels), `sys-apps/dkms-gentoo`, `sys-kernel/kernel-cleaner`.
- **Visualization** —
  [`sci-visualization/gwyddion`](https://gwyddion.net/),
  `sci-visualization/gwyddion3`.
- **Crystallography / atomistic** —
  [`sci-physics/bgmn`](http://www.bgmn.de/),
  [`sci-physics/profex`](http://www.profex-xrd.org/),
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
  (`/etc/portage` cleaner; forked to istitov + bumped to 2.0.0 in
  this overlay).
- **CUDA / generic ML inference** —
  [`dev-python/cuda-bindings`](https://github.com/NVIDIA/cuda-python),
  `dev-python/cuda-python`, `dev-python/cuda-pathfinder`,
  `dev-python/cuda-tile-bin`,
  [`dev-python/pycuda`](https://documen.tician.de/pycuda/),
  [`dev-util/nvidia-cuda-toolkit`](https://developer.nvidia.com/cuda-toolkit),
  [`dev-python/vllm`](https://github.com/vllm-project/vllm).
- **Masked but kept**: `net-misc/ipx-utils` (IPX removed from Linux in 4.18),
  `app-portage/portopts` (upstream dormant since 2014). Each mask in
  `profiles/package.mask` carries a comment explaining why and when it
  should lift.

## Repository layout and conventions

- **Thin manifests**, `masters = gentoo` only. Every package depends on
  `::gentoo` being enabled.
- **Profiles** under `profiles/` follow standard PMS layout.
- **Patches** live in `<category>/<package>/files/` and are applied via
  `PATCHES=()` or `src_prepare()`.
- **Commit messages** use subject + body form (72-char subject, blank line,
  rationale). Single-line messages only for truly trivial edits.
- **`metadata/pkgcheck.conf`** documents *which* checks are suppressed and
  *why* (not just that they're suppressed).
- **CI** runs `pkgcheck scan` on every PR and push (delta only), plus a full
  `--net` scan every three days via scheduled workflow.

## Credits

Originally created by [@megabaks](https://github.com/megabaks); see the
[contributors list](https://github.com/istitov/stuff/graphs/contributors) for
everyone who has contributed since. Thank you.

## License

Ebuilds and associated files are distributed under the GNU General Public
License v2, matching `::gentoo`. Upstream sources retain their own licenses
as declared in each ebuild's `LICENSE` variable.

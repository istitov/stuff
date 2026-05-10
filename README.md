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

### HyperSpy / 4D-STEM electron-microscopy stack

A full HyperSpy ecosystem that is not in `::gentoo`:

`hyperspy`, `hyperspyui`, `hyperspy-gui-traitsui`, `hyperspy-gui-ipywidgets`,
`rosettasciio`, `emdfile`, `ncempy`, `exspy`, `atomap`, `pyxem`, `py4dstem`.

Packaging follows upstream's split into a core (`hyperspy`) plus GUI backends
and per-domain extensions (`exspy` for EELS/EDS, `atomap` for atomic-column
analysis, `pyxem` / `py4dstem` for 4D-STEM, `ncempy`/`emdfile`/`rosettasciio`
for I/O).

### SANS / SAXS / XAFS analysis

- `sci-physics/mantid` — SANS reduction and analysis. Installs under
  `/opt/mantid` and keeps building against the current `::gentoo` by carrying
  a few local deps (see *Qt5 revivals* below).
- `sci-physics/sasview` + `dev-python/sasmodels` + `dev-python/bumps` +
  `dev-python/periodictable` — SAS modeling and fitting.
- `sci-libs/ausaxs` + `dev-python/pyausaxs` — AUSAXS solvent-scattering
  calculator and its Python bindings.
- `sci-physics/xraylarch` — XAFS analysis; modern replacement for the
  discontinued `ifeffit`.
- `sci-physics/demeter` — classic Athena/Artemis XAFS GUIs (Perl).

### DeaDBeeF plugin collection

Twenty-six `media-plugins/deadbeef-*` packages, covering audio format
support (`opus`, `vgmstream`, `vfs-rar`, `archive-reader`, `bs2b`),
visualization (`spectrogram`, `musical-spectrum`, `vu-meter`, `dr-meter`,
`waveform-seekbar`), playback/session control
(`playback-order`, `playback-status`, `headerbar`, `quick-search`, `rating`,
`replaygain-control`), file browsing (`fb`, `bookmark-manager`), desktop
integration (`gnome`, `statusnotifier`, `discord-presence`) and output
plumbing (`jack`, `pulse2`, `stereo-widener`, `copy-info`,
`customizable-toolbar`).

`media-plugins/deadbeef-jack` carries a local patch tracking DeaDBeeF's
modernized C API; `deadbeef-archive-reader` has a build fix.

### Micromagnetism

`sci-physics/mumax` (GPU finite-difference, Go + CUDA), `sci-physics/oommf`
(Tcl/Tk reference implementation), and `sci-physics/vampire` (atomistic spin
dynamics).

### AMD Ryzen-AI / NPU stack

NPU-first LLM tooling for AMD Ryzen AI (XDNA2). Application layer plus
the driver and runtime it needs:

- `sci-ml/fastflowlm` — NPU-first LLM runtime (chat, model pull).
- `sci-ml/lemonade` — AMD Lemonade SDK.
- `sci-ml/kokoros` — Kokoro TTS server (Rust + Python).
- `sci-ml/amd-gaia` — AMD GAIA stack with `api / audio / eval / image /
  mcp / talk / ui` USE flags.
- `dev-libs/xdna-driver`, `dev-libs/xrt-xdna`, `dev-util/xrt` — NPU
  driver and the XDNA-extended Xilinx Runtime.

The consumer chain pins `dev-python/spacy` 3.8.x and `dev-python/thinc`
8.3.x; bumping past these breaks kokoro.

### ROCm 7.2.3

Local bumps of the ROCm 7.2 stable line ahead of `::gentoo`'s 7.2.0:
`dev-libs/rocm-{core,comgr,device-libs,opencl-runtime}`, `dev-libs/rccl`,
`dev-libs/hipother`, `dev-build/rocm-cmake`,
`dev-util/{hip,hipcc,hipify-clang,rocm-smi,rocminfo,rocm_bandwidth_test}`,
`sci-libs/{hipBLAS,hipBLAS-common,hipBLASLt,hipCUB,hipFFT,hipRAND,hipSOLVER,hipSPARSE,hipsparselt,composable-kernel,miopen,rocBLAS,rocFFT,rocPRIM,rocRAND,rocSOLVER,rocSPARSE,rocThrust}`.

`sci-libs/hipsparselt` and (currently) `dev-libs/rccl` block on gfx1150;
rccl recovery depends on upstream gfx1151 enablement reaching a tagged
release.

`dev-util/therock-bin` is a /opt-installed ROCm SDK pinned to a
gfx1150 nightly. Coexists with the /usr ROCm above; gives gfx1150 /
Ryzen-AI APU users a working stack ahead of stable releases that
include the relevant enablement.

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

### Qt5 revivals for mantid

`::gentoo` finished its Qt5→Qt6 migration for `x11-libs/qscintilla` and
`dev-qt/qthelp`, but `sci-physics/mantid` is still a Qt5 consumer
upstream. To keep mantid working, this overlay revives two packages from
`::gentoo`'s attic:

- `x11-libs/qscintilla-2.14.1-r1` (the last Qt5-compatible slot), with
  `=x11-libs/qscintilla-2.14.1-r2` (Qt6-only) masked in
  `profiles/package.mask`.
- `dev-qt/qthelp-5.15.18`.

These masks will lift once mantid finishes its own Qt6 port upstream.

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

- **XMPP clients** — `net-im/profanity`, `net-im/stabber`,
  `net-im/xmppconsole`, `dev-libs/libstrophe`.
- **Collaborative editing** — `app-editors/gobby`, `net-libs/libinfinity`,
  `acct-{group,user}/infinote`.
- **Kernel / low-level** — `sys-kernel/pf-sources`, `sys-apps/dkms-gentoo`,
  `sys-kernel/kernel-cleaner`.
- **Visualization** — `sci-visualization/gwyddion`,
  `sci-visualization/gwyddion3`.
- **Crystallography / atomistic** — `sci-physics/bgmn`, `sci-physics/profex`,
  `sci-physics/prismatic`, `sci-libs/nexus`, `sci-libs/pycifrw`.
- **SuiteSparse imports** — `sci-libs/{amd,camd,cholmod,colamd,ccolamd,`
  `umfpack,suitesparseconfig}`.
- **Retro / fun** — `x11-terms/cool-retro-term`,
  `games-roguelike/adom`, `games-roguelike/dwarftherapist`,
  `games-misc/fortune-mod-lorquotes`.
- **Niche tools** — `dev-lang/tcc`, `dev-vcs/fossil`, `app-office/mytetra`,
  `app-misc/tudu`, `sys-fs/google-drive-ocamlfuse`,
  `app-text/pandoc-crossref-bin`.
- **CUDA / generic ML inference** — `dev-python/cuda-bindings`,
  `dev-python/cuda-python`, `dev-python/cuda-pathfinder`,
  `dev-python/cuda-tile-bin`, `dev-python/pycuda`,
  `dev-util/nvidia-cuda-toolkit`, `dev-python/vllm`.
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

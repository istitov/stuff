# stuff

A Gentoo ebuild overlay.

```sh
eselect repository enable stuff
emerge --sync stuff
```

[![pkgcheck](https://github.com/istitov/stuff/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/istitov/stuff/actions/workflows/pkgcheck.yml)

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

- `sci-physics/mantid` 6.15.0.3 — SANS reduction and analysis. Installs under
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

Twenty-five `media-plugins/deadbeef-*` packages, covering audio format
support (`opus`, `vgmstream`, `vfs-rar`, `archive-reader`, `bs2b`),
visualization (`spectrogram`, `musical-spectrum`, `vu-meter`, `dr-meter`,
`waveform-seekbar`), playback/session control
(`playback-order`, `playback-status`, `headerbar`, `quick-search`, `rating`,
`replaygain-control`), file browsing (`fb`, `bookmark-manager`), desktop
integration (`gnome`, `statusnotifier`, `discord-presence`) and output
plumbing (`jack`, `pulse2`, `stereo-widener`, `copy-info`,
`customizable-toolbar`).

Many carry local patches that track upstream API changes in DeaDBeeF core.

### Micromagnetism

`sci-physics/mumax` (GPU finite-difference, Go + CUDA), `sci-physics/oommf`
(Tcl/Tk reference implementation), and `sci-physics/vampire` (atomistic spin
dynamics).

## Design choices

### Python 2 preservation

`::gentoo` removed Python 2 support in 2024, but `media-gfx/sk1` (a vector
illustrator) is py2-only and has no maintained py3 fork. Rather than drop
`sk1`, this overlay keeps it running:

- **Locally-vendored eclasses** in `eclass/`: `distutils-r1_py2`,
  `python-r1_py2`, `python-any-r1_py2`, `python-utils-r1_py2`. Inheriting one
  of these is the signal that a package is intentionally pinned to py2.
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
`dev-qt/qthelp`, but `sci-physics/mantid` 6.15.0.3 is still a Qt5 consumer
upstream. To keep mantid working, this overlay revives two packages from
`::gentoo`'s attic:

- `x11-libs/qscintilla-2.14.1-r1` (the last Qt5-compatible slot), with
  `=x11-libs/qscintilla-2.14.1-r2` (Qt6-only) masked in
  `profiles/package.mask`.
- `dev-qt/qthelp-5.15.18`.

These masks will lift once mantid finishes its own Qt6 port upstream.

### Other targeted fixes kept in-tree

- `sci-libs/hdf` 4.2.16 — local bump carrying a gcc 15 build fix.
- `x11-libs/gtk+-2.24.33-r99` — gtk+:2 holdover for apps that still need it.
- `dev-python/bokeh` — 2.4.2 dropped, 3.4.1 and 3.9.0 kept with the
  deprecated `flaky` test dep removed.
- `dev-python/py4dstem` 0.14.18 — carries upstream PR #712 for numpy 2
  compatibility.
- `dev-python/cupy` 13.6.0 — ROCm USE flag dropped; cupy 13's HIP backend
  is incompatible with ROCm 7.x hipBLAS, cupy 14 dropped ROCm entirely.
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
  `app-misc/tudu`, `sys-fs/google-drive-ocamlfuse`, `app-editors/gobby`,
  `app-text/pandoc-crossref-bin`.
- **Masked but kept**: `net-misc/ipx-utils` (IPX removed from Linux in 4.18),
  `app-portage/portopts` (upstream dormant since 2014),
  `sci-physics/ifeffit` (upstream deleted; successor in `xraylarch`). Each
  mask in `profiles/package.mask` carries a comment explaining why and when
  it should lift.

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

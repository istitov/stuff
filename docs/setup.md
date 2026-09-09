# Setup

Every guide here assumes the **stuff** overlay is enabled and, on a stable
system, that its testing keywords are accepted. This page is that one-time setup;
each guide then adds only its own package-specific steps.

## Enable the overlay

`eselect repository` (from `app-eselect/eselect-repository`) is the simplest way
to add the overlay; the first command installs it if it is not already present.
As root:

```bash title="root #"
emerge --ask app-eselect/eselect-repository
eselect repository enable stuff
emerge --sync stuff
```

To confirm the sync worked, search for an overlay package — it should resolve:

```bash title="user $"
emerge -s fastflowlm
```

The Gentoo Wiki [**Overlay:Stuff**](https://wiki.gentoo.org/wiki/Overlay:Stuff)
page is the neutral reference for this step, including an alternative
`/etc/portage/repos.conf` method.

## Accept testing keywords

The overlay primarily targets `~amd64` (testing); many packages also carry
`~arm64`, and a smaller compatibility set carries other keywords. Accept the
keyword for the host architecture — the broad amd64 form below takes the whole
overlay; scope it per package if preferred. As root:

```text title="/etc/portage/package.accept_keywords/stuff"
*/*::stuff ~amd64
```

A system already running `ACCEPT_KEYWORDS="~amd64"` globally needs nothing here.
On arm64, use `~arm64` instead and check the chosen package actually carries it.

!!! note "Portage config filenames are arbitrary"
    Files under `/etc/portage/package.accept_keywords/` and
    `/etc/portage/package.use/` are directories of plain-text fragments — the
    filename (`stuff`, `vllm`, `texlive`, …) is purely organisational; portage
    reads them all. The guides use per-topic names, but any name works.

## What to expect

The overlay follows a rolling-release model: only the current `master` is
supported (see the repo's
[SECURITY.md](https://github.com/istitov/stuff/blob/master/SECURITY.md)) — no
point-in-time releases. Most packages are testing-keyworded for their supported
architectures. It is community-driven, with contributions from many people.
Relevant package changes get a pkgcheck diff scan, the full overlay is scanned
roughly every three days, and
upstream-version drift is checked weekly. Production deployments should
validate upgrades before relying on them, and roll back by pinning versions or
checking out an earlier overlay commit. Source builds have their own costs:
heavy HIP/CUDA packages (vLLM in particular) take long, RAM-hungry compiles —
the guides flag these where they bite.

## New to Gentoo?

The [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) is the place to
start — it covers `emerge` (the package manager), **USE flags** (compile-time
feature toggles), and `~arch` **keywords** (the testing branch). Two more terms
the guides use: a **slot** lets incompatible major versions of one package be
installed side by side (Qt5 lives in `dev-qt/*:5`, Qt6 in `:6`), and
**`::gentoo`** means the official Gentoo package repository, which this
overlay layers on top of without replacing.

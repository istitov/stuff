---
title: local AI & GPU compute on Gentoo
---

# stuff overlay

A [Gentoo](https://wiki.gentoo.org/wiki/Main_Page) ebuild overlay that ships
hard-to-package software as first-class Portage citizens — dependency-resolved,
installed and tracked by Portage, and built from source where upstream permits.
Prebuilt components remain explicit in package metadata and these guides; many
use `-bin` names or binary-specific licenses instead of being hidden inside an
unmanaged environment.

`stuff` is a multi-niche overlay. Its primary focuses are: **local
AI & GPU compute** (AMD Ryzen-AI / NPU · AMD ROCm · NVIDIA CUDA, with LLM
runtimes and the PyTorch / ONNX ecosystem) · **materials science** (SAXS / SANS
/ XAFS / XRD / Rietveld · electron microscopy · SPM · micromagnetism) ·
**`pf-sources`** (curated pf-kernel patchset) · **DeaDBeeF** plugins · **TeX
Live** · a **Qt5** revival mirror · a **Python 2** legacy preservation layer.

For readers coming from other distributions, the advantage is that the overlay
extends Gentoo's dependency graph instead of bypassing it. Source-capable
components build against the machine's selected hardware and libraries, with
optional features tailored through USE flags. Prebuilt payloads remain explicit
in package metadata and under Portage's control, but their upstream-fixed
feature sets naturally offer less build-time tailoring. Portage upgrades,
rebuilds, or removes the declared chain through the same interface as the main
Gentoo repository.

Every ebuild is build-tested before it lands, using the relevant supported
path: amd64 systems cover the ROCm and CUDA build configurations, while ebuilds
carrying `~arm64` are validated on arm64. Hardware-dependent runtime checks are
performed where matching devices are available.

**Get started:** [enable the overlay and accept its keywords](setup.md), then
pick a guide below. The Gentoo Wiki
[Overlay:Stuff](https://wiki.gentoo.org/wiki/Overlay:Stuff) page is the neutral
enable reference.

## Guides

Step-by-step walkthroughs for the overlay's headline stacks:

- [**The AI / ML stack**](ai-stack.md) — orientation map: which runtime for
  which hardware (NPU / ROCm / CUDA / CPU).
- [**Check the GPU hardware version**](guides/hardware-targets.md) — detect the
  AMD `gfx*` target or NVIDIA compute capability and configure Portage's build
  variables.
- [**AMD Ryzen AI NPU**](guides/ryzen-ai-npu.md) — the XDNA driver plus an
  NPU-first LLM runtime; from a stock install to a model running on the NPU.
- [**vLLM**](guides/vllm.md) — high-throughput serving on CPU, NVIDIA CUDA, or
  AMD ROCm, with backend-specific build and host setup.
- [**llama.cpp, Ollama & llama-swap**](guides/llama-setup.md) — the lighter local
  inference path across CPU, CUDA, ROCm, and Vulkan, plus model routing with
  llama-swap.
- [**Fine-tuning, Unsloth & RAG**](guides/fine-tuning-rag.md) — QLoRA
  fine-tuning (bitsandbytes / peft / trl), packaged Unsloth + Studio, and a
  local Qdrant vector store.
- [**ComfyUI + TRELLIS**](guides/comfyui.md) — node-based generative-AI
  workflows, plus the TRELLIS image-to-3D pipeline (Gaussian-splat / mesh).
- [**Qt5 LTS**](guides/qt5-lts.md) — the 5.15.19 LTS mirror and KDE patch
  collection, so Qt5 apps keep building after `::gentoo` drops the slot.
- [**TeX Live**](guides/texlive.md) — the current TL2025 / TL2026 collections
  kept ahead of `::gentoo`, with the LaTeX build tooling.

## What's in the overlay

An overview of the major areas. The
[README](https://github.com/istitov/stuff#readme) carries the authoritative,
current package list; this page is the orientation.

### AI & GPU compute

NPU-first LLM tooling for AMD Ryzen AI (`fastflowlm`, `lemonade`, the `amdxdna`
driver and XRT runtime); backend-agnostic local LLM serving (`llama.cpp`,
`ollama`, `vllm`, `koboldcpp`, the `llama-swap` proxy, plus CLI and browser
clients); and a **fine-tuning + RAG stack** (`bitsandbytes`, `peft`, `trl`,
`unsloth`, and the `qdrant` vector database). Also included: a
speech / audio ML stack (Whisper, sherpa-onnx, pyannote diarization); the
surrounding PyTorch / ONNX ecosystem (Lightning, torchmetrics, onnxruntime,
FAISS); the source-built ROCm / HIP **10.0** line (with 7.2.4 retained as a
rollback anchor) ahead of `::gentoo`; and
NVIDIA CUDA, RAPIDS GPU dataframes, and a 3D-generative (Gaussian-splat / mesh)
cluster. Start with the [AI / ML stack map](ai-stack.md), the
[fine-tuning & RAG guide](guides/fine-tuning-rag.md), or the
[ComfyUI + TRELLIS guide](guides/comfyui.md) for image-to-3D.

### Materials science

Electron microscopy — the full HyperSpy / 4D-STEM stack, plus gwyddion for SPM
(AFM / STM); small-angle and X-ray-absorption analysis (`mantid`, `sasview`,
`bornagain`, `xraylarch`, `demeter`); micromagnetism (`mumax`, `oommf`,
`vampire`); and X-ray powder diffraction / Rietveld refinement (`bgmn`,
`profex`).

### Revival mirrors & extras

A **Qt5** 5.15.19-LTS mirror (excluding QtWebEngine) with the KDE Qt5 Patch
Collection, so Qt5 consumers
keep building — see the [Qt5 LTS guide](guides/qt5-lts.md); a current
**[TeX Live](guides/texlive.md)** kept ahead of `::gentoo`; a **Python 2** preservation layer for
gwyddion's `pygwy` bindings; twenty-six **DeaDBeeF** plugins; the
**`pf-sources`** kernel; and a long tail of niche tools (XMPP clients,
collaborative editing, 3D-printing, SuiteSparse, retro / fun). The full list
lives in the [README](https://github.com/istitov/stuff#readme).

## Overlay mirrors

- [github.com/istitov/stuff](https://github.com/istitov/stuff) (primary)

Auto-mirrored on every push:

- [gitlab.com/istitov/stuff](https://gitlab.com/istitov/stuff)
- [codeberg.org/istitov/stuff](https://codeberg.org/istitov/stuff)

*Versions move quickly. After synchronizing the repositories and refreshing the
eix cache, `eix --in-overlay stuff` shows the packages and versions currently
provided by the overlay.*

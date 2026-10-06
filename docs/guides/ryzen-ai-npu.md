---
tags:
  - NPU
  - LLM inference
  - speech-to-text
---

# Running LLMs on the AMD Ryzen AI NPU (Gentoo way)

AMD's **Ryzen AI** APUs ship an on-die **NPU** (Neural Processing Unit, AMD's
**XDNA** / XDNA 2 architecture) that can run LLM inference at low power. On
Linux the driver (`amdxdna`), the XRT runtime, and an NPU-first LLM runtime are
**not in `::gentoo`** — the [**stuff**](https://github.com/istitov/stuff)
overlay packages the whole chain, so a single `emerge` brings it up.

This guide covers bringing the NPU stack up from a stock Gentoo install through
running a model on it.

## Quickstart

!!! tip "Quickstart"
    **Requires a supported XDNA 2 NPU** (see [Hardware](#hardware)); XDNA 1
    parts (Ryzen 7040 / 8040) are not supported.

    With the overlay enabled ([Setup](../setup.md)), install the NPU LLM runtime
    — which pulls the `amdxdna` driver (plus firmware) and the XRT runtime in as
    dependencies — and load the kernel module, as root:

    ```bash title="root #"
    emerge -av sci-ml/fastflowlm
    modprobe amdxdna
    ```

    `flm` needs the locked-memory limit raised — and a re-login for it to take
    effect — or it fails at model load: see
    [Locked memory](#locked-memory-required) below before running the next
    block.

    Then validate the stack, pull a model, and run it on the NPU, as a normal
    user:

    ```bash title="user $"
    flm validate
    flm pull llama3.2:3b
    flm run llama3.2:3b
    ```

## Prerequisites

### Hardware

`fastflowlm` requires AMD's **XDNA 2** NPU. Its current
[upstream support statement](https://github.com/ROCm/FastFlowLM#readme) names
Strix, Strix Halo, Kraken, and Gorgon Point. Product branding spans Ryzen AI 300
/ Max 300 and newer parts, so confirm an individual SKU against the current
upstream support list rather than inferring support from the marketing series
alone:

| Upstream family label | Typical series |
|---|---|
| Strix | Ryzen AI 300 |
| Strix Halo | Ryzen AI Max 300 |
| Kraken (AMD: Krackan Point) | Ryzen AI 300 |
| Gorgon Point | Ryzen AI 400 |

!!! warning "XDNA 1 is not supported"
    The first-generation XDNA NPU in **Ryzen 7000 / 8000** parts (Phoenix
    `7040`, Hawk Point `8040`) is **not** supported by `fastflowlm`, which needs
    XDNA 2. Those chips do carry an NPU that the `amdxdna` driver binds, but no
    LLM-runtime path here uses it. On those machines, run LLMs on the CPU or
    the iGPU instead — `llama.cpp` (CPU by default, `USE=vulkan` for the iGPU);
    see the [AI stack map](../ai-stack.md#runtimes-and-servers).

The stack here is run-verified on **Strix Point** (Ryzen AI 9 HX 370). The
other rows are upstream-supported, not independently tested by this overlay.

`dev-libs/xdna-driver` installs both the out-of-tree kernel module and its
matching NPU firmware under `/lib/firmware/amdnpu`; emerging
`sci-ml/fastflowlm` pulls that package in automatically.

### Kernel

`dev-libs/xdna-driver` builds the `amdxdna` module **out of tree** and installs
it with priority over any in-tree copy. So the in-tree driver
(`CONFIG_DRM_ACCEL_AMDXDNA`) is optional. The packaged out-of-tree module keeps
the driver and firmware pairing tested by this stack; mixing another module or
firmware can expose a different `vbnv` string that XRT rejects. It needs only the
subsystem and the IOMMU from the kernel:

- `CONFIG_DRM_ACCEL` — the compute-accelerator subsystem the NPU registers under
- `CONFIG_AMD_IOMMU` — required for the NPU's DMA

If either option is missing, the kernel must be reconfigured, rebuilt, and the
machine rebooted **before** `modprobe amdxdna` can succeed — the module fails
to load (or the device never appears) on a kernel without them. Switching a
running system between the in-tree and out-of-tree module likewise requires a
reboot.

## The stack, bottom up

`emerge sci-ml/fastflowlm` pulls every lower layer automatically. What it brings
in, and why:

| Package | Role |
|---|---|
| `dev-libs/xdna-driver` | The `amdxdna` kernel module **and** the NPU firmware. |
| `dev-util/xrt` | AMD/Xilinx Runtime (XRT) — the user-space runtime; ships the `xrt-smi` management tool. |
| `dev-libs/xrt-xdna` | The XDNA plugin that teaches XRT to talk to the NPU. |
| `sci-ml/fastflowlm` | **NPU-first LLM runtime** (`flm`) — the piece that actually executes models on the NPU. |

Two optional layers sit on top:

- **`sci-ml/lemonade`** — a local, OpenAI-compatible inference *server*
  (`lemond`, default port **13305**). Built with `USE=system-fastflowlm` it
  routes NPU inference through the packaged fastflowlm, giving any
  OpenAI-style client a local NPU endpoint.
- **`sci-ml/amd-gaia`** — AMD's agent framework. Its default backend is
  lemonade at lemond's default address (`http://localhost:13305/api/v1`); set
  `LEMONADE_BASE_URL` to point it at another lemonade server.

!!! note "What about `onnxruntime` / `amd-quark`?"
    `sci-libs/onnxruntime` in this overlay builds for the CPU, optionally with
    CUDA (`USE=cuda`) — it has no NPU (VitisAI) execution provider, so it is
    **not** an NPU inference path.
    `dev-python/amd-quark-bin` is a model-*quantization* toolkit, not a runtime.
    Neither is needed for the NPU LLM path above.

## Locked memory (required)

The NPU runtime pins memory, so the `memlock` limit must be unlimited or `flm`
fails at load. As root, create a limits file:

```text title="/etc/security/limits.d/99-amdxdna.conf"
*  soft  memlock  unlimited
*  hard  memlock  unlimited
```

Log out and back in for it to take effect (check with `ulimit -l`). The
`fastflowlm` service units (`USE=openrc` / `USE=systemd`) already raise this for
the daemon; the limits file is what covers interactive `flm run`.

## Running a model

Confirm the NPU stack is healthy, download a model, and chat with it — as a
normal user:

```bash title="user $"
flm validate
flm pull llama3.2:3b
flm run llama3.2:3b
```

Below fastflowlm, the NPU can be inspected at the driver/runtime layer with
XRT's `xrt-smi` — `examine` lists the device and firmware, `validate` runs basic
NPU tests:

```bash title="user $"
xrt-smi examine
xrt-smi validate
```

For speech-to-text, pull the Whisper model and start the server with ASR
enabled alongside the chat model:

```bash title="user $"
flm pull whisper-v3:turbo
flm serve llama3.2:3b --asr 1
```

To serve models over an OpenAI-compatible API instead of chatting directly,
install lemonade with its packaged-fastflowlm integration as root:

```bash title="root #"
echo "sci-ml/lemonade system-fastflowlm" \
  >> /etc/portage/package.use/lemonade
emerge -av sci-ml/lemonade
```

Then start the server and use its CLI client, as a normal user:

```bash title="user $"
lemond
lemonade list
lemonade chat MODEL_FROM_LEMONADE_LIST
```

`lemond` starts the server on port 13305. For OpenAI clients, use
`http://127.0.0.1:13305/api/v1` as the base URL (`/v1` is also accepted).
`lemonade list` shows lemonade's own model catalog; `lemonade chat` opens a chat
REPL in the terminal, while `lemonade run` loads a model and opens the web app
in a browser — use a name from `lemonade list` with either.

Lemonade uses its own model catalog, so its model names differ from
fastflowlm's `flm` names. Treat the live output of `lemonade list` as
authoritative rather than copying a model count or ID from this guide.

!!! note "NPU versus the integrated GPU"
    In the [NPU versus Radeon 890M study](../benchmarks/npu-vs-890m.md) on a
    Ryzen AI 9 HX 370, median request time was lower through
    `llama.cpp[vulkan]` on the 890M in all twelve model/input comparisons. The
    NPU drew less socket power in every comparison, but not consistently less
    energy per request, and reached the first answer sooner in three
    longer-context comparisons. FastFlowLM changes both its runtime and weight
    formats quickly, so benchmark the installed version instead of treating
    those results as a hardware constant.

## Running as a service

`fastflowlm` ships service units (`USE=openrc` / `USE=systemd`) so the NPU
endpoint comes up on boot with `memlock` already raised for the daemon (the
interactive limits file then only matters for manual `flm run`).

**OpenRC** — set `FLM_USER` in `/etc/conf.d/fastflowlm` (required; model, port,
and sidecar options have safe defaults), then start and enable the service, as
root:

```bash title="root #"
rc-service fastflowlm start
rc-update add fastflowlm default
```

**systemd** — the unit is a per-user template; override `FLM_MODEL` / `FLM_HOST`
/ `FLM_PORT` / `FLM_PMODE` / `FLM_ASR` / `FLM_EMBED` / `FLM_EXTRA_OPTS` in
`/etc/default/fastflowlm@alice` (replacing `alice` with the serving user) if
the defaults don't fit, then enable it, as root:

```bash title="root #"
systemctl enable --now fastflowlm@alice.service
```

Models live under `~/.config/flm/` (override with `FLM_MODEL_PATH`); the catalog
`flm pull` draws from is `/opt/fastflowlm/share/flm/model_list.json`.
Model files are user data rather than portage-owned distfiles. Read the elog
after FastFlowLM upgrades: an upstream quantization-format change can require a
re-pull before an existing model will load.

## Open kernels: OpenFlowLM

`sci-ml/openflowlm` packages
[OpenFlowLM](https://github.com/Atomic-Germ/OpenFlowLM-Next), a community fork
of FastFlowLM that replaces the closed NPU kernels with open AIE designs
compiled from source. It installs alongside fastflowlm (under
`/opt/openflowlm`, command `oflm`) and needs the same driver, XRT and
[locked-memory](#locked-memory-required) setup.

Upstream has not tagged a release yet, so the package is a live ebuild with no
keywords and has to be accepted explicitly:

```text title="/etc/portage/package.accept_keywords/openflowlm"
sci-ml/openflowlm **
```

```bash title="root #"
emerge -av sci-ml/openflowlm
```

The build compiles the open kernels in a Python virtual environment holding the
mlir-aie and Peano toolchain wheels, so it needs network access and adds a
long kernel-compile step. Two parts are left out:

- the open BERT embedding kernels, whose export needs the NPU itself, so
  `bge-*`, `all-minilm`, `nomic-embed-text` and `gte-multilingual` do not load;
- the `granite42-3b` and `phi4-mini-4b` kernel sets, which currently fail to
  build upstream.

Usage mirrors `flm`, as a normal user:

```bash title="user $"
oflm validate
oflm pull lfm2:1.2b
oflm run lfm2:1.2b
```

Open kernel sets are matched per model, so not every model uses them — Qwen3
4B has one, Qwen3 0.6B does not. Those models, and the families without an
open design (vision, audio, Gemma 4, GPT-OSS, Whisper), run on the closed
FastFlowLM kernels that OpenFlowLM still ships. The open path announces itself
when the model loads, for example
`[OFLM]  LFM2 on the open kernels (…/open_kernels)`; without that line the
closed path ran.

Unless `OFLM_MODEL_PATH` (or fastflowlm's `FLM_MODEL_PATH`) is set, `oflm`
keeps its models in `~/.config/oflm/` if that exists and otherwise in
fastflowlm's `~/.config/flm/`, so models pulled with `flm` serve both
runtimes. Moving that directory to `~/.config/oflm/`, as `oflm`'s notice
suggests, would hide the models from `flm`. The installed `oflm` wrapper also
sets `OFLM_CONFIG_PATH`; leave it set, because `oflm` honours fastflowlm's
`FLM_CONFIG_PATH` too and would otherwise read FastFlowLM's model catalog.
There are no service units yet; `oflm serve MODEL` runs the
OpenAI-compatible server in the foreground.

## Troubleshooting

- **`flm` fails immediately / the NPU isn't found** — check that `ulimit -l`
  reports `unlimited` (see above) and that `lsmod | grep amdxdna` shows the
  module loaded. To confirm XRT sees the NPU device directly, run
  `xrt-smi examine`; the NPU should be listed. The kernel-side driver probe
  shows in `journalctl -kg xdna`.
- **The module won't load after a kernel change** — rebuild it
  (`emerge --oneshot dev-libs/xdna-driver`) and reload with
  `modprobe -r amdxdna && modprobe amdxdna`. Switching between the in-tree and
  out-of-tree module needs a full reboot.
- **`xrt-smi validate` sees the device but every test fails** — the system is
  probably on the stock in-tree module and/or stock firmware. Confirm
  `dev-libs/xdna-driver` is installed (it ships the newer module plus the
  `npu.dev.sbin` firmware the tools expect) and reload the module.
- **`emerge --sync stuff` reports nothing to do** — make sure the overlay was
  added first with `eselect repository enable stuff` (which needs
  `app-eselect/eselect-repository` installed).

## See also

- [fastflowlm.com](https://fastflowlm.com/) — the NPU LLM runtime
- [Atomic-Germ/OpenFlowLM-Next](https://github.com/Atomic-Germ/OpenFlowLM-Next)
  — the open-kernel fork
- [lemonade-server.ai](https://lemonade-server.ai/) — the local AI server
- [amd/xdna-driver](https://github.com/amd/xdna-driver) and
  [Xilinx/XRT](https://github.com/Xilinx/XRT) — driver and runtime upstreams
- [Linux `amdxdna` driver docs](https://docs.kernel.org/accel/amdxdna/amdnpu.html)
  — the kernel-side NPU driver reference
- [Arch Wiki: Neural processing unit](https://wiki.archlinux.org/title/Neural_processing_unit)
  — distro-neutral NPU detection / verification reference

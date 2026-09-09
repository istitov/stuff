# Serving LLMs with vLLM (Gentoo way)

[vLLM](https://docs.vllm.ai/) is the high-throughput serving option in `stuff`:
continuous batching, concurrent requests, a Python API, and an
OpenAI-compatible HTTP server. The ebuild supports three mutually exclusive
inference targets — **CPU**, **NVIDIA CUDA**, and **AMD ROCm** — selected by USE
flag.

vLLM has no Vulkan backend. For Vulkan, broader consumer-GPU support, GGUF
models, or a substantially lighter build, use the
[llama.cpp, Ollama, and llama-swap guide](llama-setup.md).

## Choose a backend

| Hardware | Package setting | Notes |
|---|---|---|
| CPU | `dev-python/vllm cpu` | Builds the native CPU inference target. |
| NVIDIA GPU | `dev-python/vllm cuda` | Builds CUDA extensions with the system CUDA toolkit. |
| AMD GPU | `dev-python/vllm rocm` | Builds HIP extensions for `AMDGPU_TARGETS`; CDNA is the strongest fit. |
| Vulkan-capable GPU | Not supported by vLLM | Use the [llama setup](llama-setup.md) instead. |

The three backend flags are mutually exclusive. Leaving all three disabled
builds vLLM's device-agnostic API surface (`VLLM_TARGET_DEVICE=empty`), which is
useful for development but cannot load a model for inference.

The current overlay ebuild is keyworded `~amd64`. On arm64, use llama.cpp or
Ollama from the [llama setup](llama-setup.md), and check current keywording with
`eix` before installing.

## Quickstart

With the overlay enabled ([Setup](../setup.md)), choose exactly one backend in
`/etc/portage/package.use/vllm`.

### CPU

```text title="/etc/portage/package.use/vllm"
dev-python/vllm cpu
```

### NVIDIA CUDA

First follow
[Check the GPU hardware version](hardware-targets.md#nvidia-find-the-compute-capability)
and set `TORCH_CUDA_ARCH_LIST` for the installed GPU.

```text title="/etc/portage/package.use/vllm"
dev-python/vllm cuda
```

### AMD ROCm

First follow
[Check the GPU hardware version](hardware-targets.md#amd-find-the-gfx-target)
and set `AMDGPU_TARGETS` for the installed GPU.

Then select the ROCm backend:

```text title="/etc/portage/package.use/vllm"
dev-python/vllm rocm
```

### Build and serve

Install vLLM as root. CUDA and ROCm compile large accelerator extensions; the
ebuild defaults their build to `MAX_JOBS=4`. Lower it when memory is tight.

```bash title="root #"
MAX_JOBS=4 emerge -av dev-python/vllm
```

Serve a Hugging Face model through the OpenAI-compatible API as a normal user:

```bash title="user $"
vllm serve facebook/opt-125m --host 127.0.0.1 --port 8000
```

The API is then available at `http://127.0.0.1:8000`. Keep it on loopback
unless authentication, TLS, and deliberate network access controls are in
place.

From another terminal, confirm that the server advertises the loaded model:

```bash title="user $"
curl -fsS http://127.0.0.1:8000/v1/models
```

## CPU setup

`USE=cpu` builds vLLM's native CPU target and pulls the matching source-built
PyTorch/LibTorch stack plus its CPU dependencies. This is the correct setting
for actual CPU inference; the empty target described above is not a lightweight
substitute.

CPU avoids a vendor GPU stack but vLLM remains a large Python and C++ build. For
interactive use on modest hardware, `llama.cpp` is usually the simpler route;
see the [llama setup guide](llama-setup.md#llamacpp-direct-control).

## NVIDIA CUDA setup

`USE=cuda` pulls the system CUDA toolkit and builds vLLM's CUDA, attention, and
quantization extensions for the selected toolchain. The ebuild selects a host
compiler accepted by nvcc, but the build is still long and memory-intensive.
Set `TORCH_CUDA_ARCH_LIST` as described in the
[hardware-version guide](hardware-targets.md#nvidia-find-the-compute-capability)
before building.

```text title="/etc/portage/package.use/vllm"
dev-python/vllm cuda
```

If the compiler is killed with exit code 9, reduce parallelism:

```bash title="root #"
MAX_JOBS=2 emerge -av dev-python/vllm
```

Runtime verification requires an NVIDIA GPU even when the CUDA sources can be
compiled on a system that only has the toolkit.

## AMD ROCm setup

`stuff` carries a coherent source-built ROCm 10 cohort under `/usr`, with 7.2.4
retained as a rollback anchor. Enabling `vllm[rocm]` pulls the required HIP and
PyTorch components from that stack.

### Hardware and permissions

The kernel needs `CONFIG_DRM_AMDGPU` and `CONFIG_HSA_AMD_SVM`. The user running
vLLM must be able to access `/dev/kfd` and `/dev/dri`, normally through the
`video` and `render` groups:

```bash title="root #"
local_user="alice"  # replace with the login that will run vLLM
gpasswd -a "${local_user}" video
gpasswd -a "${local_user}" render
```

Re-login after changing group membership.

### `AMDGPU_TARGETS`

ROCm packages compile for the GPU architectures listed in `AMDGPU_TARGETS`.
Detect the token, configure single- or multi-GPU hosts, and understand the
portability tradeoff in
[Check the GPU hardware version](hardware-targets.md#amd-find-the-gfx-target).

### Build cost and hardware fit

The ROCm 10 stack pulls AMD's LLVM fork; its ebuild requires at least **30 GiB**
of free build space before compilation. vLLM then compiles its own HIP kernels,
whose template instantiations can each consume several GiB of RAM. Reduce
`MAX_JOBS` before retrying an OOM-killed build.

vLLM's ROCm path is strongest on **CDNA** data-center GPUs. It can build and run
on supported consumer **RDNA** hardware, but single-user local inference often
fits the llama stack better.

!!! note "Vulkan can beat ROCm on some AMD GPUs"
    vLLM itself cannot use Vulkan, but this affects the choice of server. On the
    recorded Strix Point llama.cpp workload, Vulkan was faster than ROCm. This
    is hardware- and workload-dependent, not a general ranking. Benchmark both
    paths on the target machine; the
    [llama setup guide](llama-setup.md#vulkan-versus-rocm-on-amd) records the
    measured result, upstream limitation, and relevant USE choices.

### Unsupported architecture overrides

`HSA_OVERRIDE_GFX_VERSION` can sometimes map a close same-family ISA variant to
a supported target. It cannot make a GPU from an unsupported architecture
family compatible with the selected ROCm release. For older or unsupported AMD
GPUs, Vulkan through llama.cpp or Ollama is the safer route.

## Optional vLLM features

Two non-backend USE flags expose more specialized paths:

- `USE=rust` builds the optional `vllm-rs` serving frontend. It is orthogonal
  to the selected inference backend and is enabled at runtime with
  `VLLM_USE_RUST_FRONTEND=1`.
- `USE=humming` adds Humming CUDA kernels and therefore requires `USE=cuda`.
  Leave it disabled unless the intended model and quantization path use those
  kernels.

## Troubleshooting

- **No model loads after a default build** — enable exactly one of `cpu`,
  `cuda`, or `rocm`; the no-flag build is the empty target.
- **Build killed with exit code 9** — lower `MAX_JOBS`, especially for CUDA or
  ROCm builds.
- **ROCm reports no device** — confirm `rocminfo` lists the GPU, `amdgpu` is
  loaded, `CONFIG_HSA_AMD_SVM` is enabled, and the user has `video` and
  `render` access.
- **ROCm REQUIRED_USE failure** — set at least one supported `AMDGPU_TARGETS`
  value in `make.conf`; the [hardware-version guide](hardware-targets.md)
  shows how to detect it.
- **A consumer Radeon works poorly with vLLM** — try llama.cpp or Ollama with
  both Vulkan and ROCm builds and compare on the same model and workload.

Versions move quickly. After synchronizing and refreshing the eix cache,
`eix --in-overlay stuff --and --exact dev-python/vllm` shows the versions
currently provided by the overlay.

## See also

- [vLLM documentation](https://docs.vllm.ai/) — serving, models, and runtime
  configuration.
- [vLLM on GitHub](https://github.com/vllm-project/vllm) — source and upstream
  issue tracker.
- [Check the GPU hardware version](hardware-targets.md) — configure AMD and
  NVIDIA compilation targets before emerging the stack.
- [llama.cpp, Ollama, and llama-swap](llama-setup.md) — lighter serving and the
  Vulkan fallback.

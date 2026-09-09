# Setting up llama.cpp, Ollama, and llama-swap (Gentoo way)

The llama stack is the flexible local-inference path in `stuff`. It covers
plain CPU inference, NVIDIA CUDA, AMD ROCm, and cross-vendor Vulkan without
requiring vLLM's heavier serving build.

Compared with `::gentoo` and GURU, `stuff` provides a broader, coordinated
set. `::gentoo` carries Ollama for `~amd64`, built against the separately
packaged system `ggml`, but not llama.cpp or llama-swap. GURU carries
llama.cpp, but its latest pinned snapshot trails the one in `stuff` and is
`~amd64`-only; its released Ollama ebuilds also trail `::gentoo` and `stuff`,
and it does not carry llama-swap. The `stuff` ebuilds expose CPU/BLAS, CUDA,
ROCm, Vulkan, OpenCL, and SYCL choices where the upstream projects support
them, include optional web and service integration, and cover both `~amd64`
and `~arm64`. These paths are build-tested across the overlay's AMD/ROCm,
NVIDIA/CUDA, and arm64 host stacks.

Three packages serve different roles:

| Package | Choose it for |
|---|---|
| `sci-misc/llama-cpp` | Direct control over GGUF models, backend USE flags, `llama-server`, and an optional embedded web UI. |
| `sci-ml/ollama` | A model catalog and simple `pull` / `run` workflow, with optional OpenRC or systemd service integration. |
| `sci-misc/llama-swap` | One OpenAI/Anthropic-compatible endpoint that starts, stops, and routes between multiple llama.cpp, vLLM, or other servers on demand. |

For high request concurrency and continuous batching on CUDA or ROCm, compare
the [vLLM guide](vllm.md). vLLM has no Vulkan backend.

## Choose a backend

### CPU

llama.cpp uses CPU by default. Select one optional BLAS implementation when
desired:

```text title="/etc/portage/package.use/llama-cpp"
sci-misc/llama-cpp openblas webui
```

Ollama always builds its CPU backend, so it needs no accelerator USE flag.

### Vulkan

Vulkan is the broad, comparatively light GPU path. It avoids installing ROCm
or CUDA and works with supported Vulkan devices from multiple vendors:

```text title="/etc/portage/package.use/local-llm"
sci-misc/llama-cpp vulkan webui
sci-ml/ollama vulkan
```

KoboldCpp and stable-diffusion.cpp also expose Vulkan in this overlay, but this
guide focuses on the llama.cpp/Ollama serving pair.

### AMD ROCm

Use [Check the GPU hardware version](hardware-targets.md#amd-find-the-gfx-target)
to identify the `gfx*` agent and set `AMDGPU_TARGETS`, then enable the ROCm
backend:

```text title="/etc/portage/package.use/local-llm"
sci-misc/llama-cpp rocm webui
sci-ml/ollama rocm
```

The kernel needs `CONFIG_HSA_AMD_SVM`, and the serving user needs access to the
`video` and `render` groups. The [vLLM ROCm section](vllm.md#amd-rocm-setup)
contains the shared ROCm host setup and example `gfx` tokens.

### NVIDIA CUDA

Use
[Check the GPU hardware version](hardware-targets.md#nvidia-find-the-compute-capability)
to query the NVIDIA compute capability and set `CUDAARCHS`. llama.cpp and
Ollama honor that CMake environment variable; their ebuilds select a
CUDA-compatible host compiler, so no manual `CUDAHOSTCXX` setting is needed.

```text title="/etc/portage/package.use/local-llm"
sci-misc/llama-cpp cuda webui
sci-ml/ollama cuda
```

These USE settings pull the system CUDA toolkit and compile the corresponding
GPU backends. Ollama and llama.cpp can be built with more than one accelerator
backend, but a single intended path keeps dependencies and build time smaller.

## Vulkan versus ROCm on AMD

ROCm is not automatically the fastest llama.cpp backend on every AMD GPU.
Vulkan can be faster on some integrated and consumer GPUs, while ROCm may win on
other architectures, models, or prompt shapes.

On the recorded Strix Point (`gfx1150`, Radeon 890M) llama.cpp workload, Vulkan
delivered about **2.5×** ROCm's prompt-processing rate and **1.3×** its decode
rate. The result is scoped to that APU and workload and is associated with the
current ROCm GTT-allocation limitation tracked in
[llamacpp-rocm#57](https://github.com/lemonade-sdk/llamacpp-rocm/issues/57).
It is not a general ranking.

For an AMD machine, build or test both paths against the same GGUF, context
size, prompt, and generation settings before choosing. Vulkan is also the
practical fallback when a GPU is outside the current ROCm support matrix.

## llama.cpp: direct control

Install the selected build as root:

```bash title="root #"
emerge -av sci-misc/llama-cpp
```

`llama-server` accepts either a local GGUF file or a Hugging Face GGUF
repository. The latter downloads the model on first use. Run one of these
commands:

```bash title="user $"
llama-server -m /srv/models/model.gguf --host 127.0.0.1 --port 8080
# or
llama-server -hf ggml-org/Qwen3.5-0.8B-GGUF \
  --host 127.0.0.1 --port 8080
```

The server provides an OpenAI-compatible API. With `USE=webui`, it also embeds
the upstream browser interface; that USE flag permits the upstream UI asset
fetch during the build.

From another terminal, confirm that the API is ready:

```bash title="user $"
curl -fsS http://127.0.0.1:8080/v1/models
```

Useful backend choices include:

- CPU with OpenBLAS, BLIS, or FlexiBLAS.
- `USE=vulkan` for a cross-vendor GPU backend.
- `USE=rocm` for HIP on supported AMD GPUs.
- `USE=cuda` for NVIDIA GPUs.
- `USE=opencl` or `USE=sycl` for the narrower hardware paths described by the
  ebuild metadata.

## Ollama: managed model workflow

Install Ollama with the chosen backend and optional service integration:

The example below selects systemd; use `openrc` in its place on an OpenRC
system.

```text title="/etc/portage/package.use/ollama"
sci-ml/ollama vulkan systemd
```

```bash title="root #"
emerge -av sci-ml/ollama
```

### Interactive session

Start a per-user server in one terminal and run a model from another:

```bash title="user $"
ollama serve
```

```bash title="user $"
ollama run llama3
ollama list
```

This mode keeps the server and its downloaded models under the interactive
user's account.

### System service

The ebuild always provides the CPU backend and adds CUDA, ROCm, or Vulkan with
the corresponding USE flags. `USE=openrc` installs an OpenRC service;
`USE=systemd` installs `ollama.service`.

The packaged service runs as the dedicated `ollama` account. It has a different
home and model store from a manually started per-user server, so stop the
manual server before switching modes and expect the service to download its
own copy of a model when first requested.

For ROCm or Vulkan, give the service account access to the GPU device nodes:

```bash title="root #"
gpasswd -a ollama video
gpasswd -a ollama render
```

```bash title="root #"
rc-update add ollama default
rc-service ollama start
```

or:

```bash title="root #"
systemctl enable --now ollama.service
```

Use only the init system selected at build time.

Once the service is running, `ollama list` checks the connection; `ollama run
llama3` downloads the model into the service account's store when necessary and
starts an interactive session.

## llama-swap: one endpoint for many models

llama-swap is a proxy and process manager. It does not execute a model itself;
its configuration defines backend commands for llama.cpp, vLLM, or another
compatible server. It starts the requested backend on demand, stops idle ones,
and exposes one endpoint to clients.

Install it with optional service and UI support:

```text title="/etc/portage/package.use/llama-swap"
sci-misc/llama-swap systemd ui
```

`USE=ui` builds the embedded Svelte interface and requires a network-enabled
npm build. Leave it disabled when the API alone is sufficient.

```bash title="root #"
emerge -av sci-misc/llama-swap
```

The packaged example is a complete configuration reference. Keep a copy beside
the shorter working configuration below:

```bash title="user $"
mkdir -p ~/.config
cp /usr/share/llama-swap/config.example.yaml \
  ~/.config/llama-swap.reference.yaml
${EDITOR:-vi} ~/.config/llama-swap.yaml
```

```yaml title="~/.config/llama-swap.yaml"
models:
  local-gguf:
    cmd: >
      /usr/bin/llama-server
      --model /srv/models/model.gguf
      --host 127.0.0.1
      --port ${PORT}
    proxy: http://127.0.0.1:${PORT}
```

Change the model path, validate the configuration, then start the proxy as a
normal user:

```bash title="user $"
llama-swap --config ~/.config/llama-swap.yaml --validate
llama-swap --config ~/.config/llama-swap.yaml --listen 127.0.0.1:8080
```

From another terminal, check the model registry exposed by the proxy:

```bash title="user $"
curl -fsS http://127.0.0.1:8080/v1/models
```

With `USE=systemd`, the ebuild installs a system-level `llama-swap@.service`
template whose instance runs as the named user. For example, an instance for
the user `alice` reads `/etc/default/llama-swap@alice`:

```text title="/etc/default/llama-swap@alice"
LLAMA_SWAP_CONFIG=/home/alice/.config/llama-swap.yaml
```

```bash title="root #"
systemctl enable --now llama-swap@alice.service
```

With `USE=openrc`, set `LLAMA_SWAP_USER` and the optional config/listen values
in `/etc/conf.d/llama-swap`, then enable the service:

```bash title="root #"
rc-service llama-swap start
rc-update add llama-swap default
```

Keep model servers bound to loopback unless authentication and network exposure
have been configured deliberately. After enabling a service, verify its listen
address with `ss -ltnp` rather than assuming an upstream default is private.

## Benchmarks

For measured generation-speed tuning, see
[Speculative decoding on Radeon 890M](../benchmarks/speculative-decoding-on-890M.md).
It compares MTP configurations on four models using llama.cpp's Vulkan backend.

## Troubleshooting

- **The AMD GPU is slower with ROCm than expected** — compare the Vulkan build
  on the same model and workload; the relative result is hardware-dependent.
- **llama.cpp cannot open the GPU backend** — verify the matching loader and
  device permissions, then inspect startup output to confirm which backend was
  selected.
- **Ollama uses CPU unexpectedly** — confirm it was built with the intended
  accelerator USE flag and inspect `ollama serve` startup logs.
- **llama-swap starts no model** — return to the minimal configuration above,
  run its backend command directly, and use `llama-swap --validate` before
  putting that command behind the proxy.

Versions and model catalogs move quickly. After synchronizing and refreshing
the eix cache, use `eix --in-overlay stuff` for the current package versions and
read each package's elog after upgrades.

## See also

- [llama.cpp](https://github.com/ggml-org/llama.cpp) — source, backend
  documentation, and server usage.
- [Ollama](https://ollama.com/) · [model library](https://ollama.com/library) ·
  [GitHub](https://github.com/ollama/ollama) — project site, model catalog, and
  source.
- [llama-swap](https://github.com/mostlygeek/llama-swap) — source and complete
  configuration reference.

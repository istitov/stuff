# ComfyUI + TRELLIS image-to-3D (Gentoo)

[**ComfyUI**](https://www.comfy.org/) is a node-based diffusion / generative-AI
workflow GUI and inference engine. `stuff` packages it as `media-gfx/comfyui`
(CUDA or ROCm backend, built on the overlay's PyTorch stack), together with its
flagship custom node — **TRELLIS** image-to-3D
([`media-gfx/comfyui-if-trellis`](https://github.com/if-ai/ComfyUI-IF_Trellis))
— and the whole CUDA extension cluster TRELLIS needs. Neither is in `::gentoo`.
Packaging it keeps the application and dependency graph under portage; some
extensions build against the system PyTorch / CUDA stack, while explicitly
named packages such as `spconv-cu126` and the Comfy CUDA wheels remain prebuilt.
There is no private `pip` virtualenv or Docker image to keep in sync by hand,
and `emerge` drives every packaged upgrade.

## Quickstart

!!! tip "Quickstart"
    With the overlay enabled ([Setup](../setup.md)), install ComfyUI with the
    CUDA backend (the default), as root:

    ```bash title="root #"
    emerge -av media-gfx/comfyui
    ```

    Launch it as a normal user and open the UI at `http://127.0.0.1:8188`:

    ```bash title="user $"
    comfyui
    ```

    The UI starts empty — add a model checkpoint (see [Models](#models)) before
    generating anything.

## Prerequisites

### GPU backend

ComfyUI builds against one accelerator backend, set by USE flag (`cuda` and
`rocm` are mutually exclusive; neither = CPU, which is slow):

| USE | Backend | Notes |
|---|---|---|
| `cuda` (default) | NVIDIA | needs a CUDA 12.8+ runtime; the `comfy_aimdo` VRAM allocator + `comfy_kitchen` kernels use their CUDA wheels |
| `rocm` | AMD | builds `caffe2[rocm]`; `comfy_kitchen.apply_rope` runs on `dev-python/triton-bin`'s AMD Triton backend |
| neither | CPU | pure-Python fallbacks, no GPU offload — slow |

Before emerging an accelerated build, follow
[Check the GPU hardware version](hardware-targets.md): set `AMDGPU_TARGETS` for
an AMD GPU or `TORCH_CUDA_ARCH_LIST` for the NVIDIA GPU that will run the
PyTorch stack. The guide also covers `CUDAARCHS` for CMake-built CUDA
extensions.

!!! warning "TRELLIS is CUDA-only"
    The image-to-3D pipeline below requires an **NVIDIA / CUDA** GPU — its
    renderers (`spconv`, `nvdiffrast`, `diff-gaussian-rasterization`) are CUDA
    extensions. Base ComfyUI runs on AMD via `USE=rocm`, but TRELLIS does not.
    AMD users still get the full node-based image workflow on ROCm — only the
    3D-generative (Gaussian-splat / mesh) pipeline stays CUDA-bound until its
    renderers grow HIP ports upstream.

### Layout

`media-gfx/comfyui` installs the application **read-only under `/opt/comfyui`**.
Per-user writable state lives under **`COMFYUI_BASE`** (default
`~/.local/share/comfyui`): `models/`, `custom_nodes/`, `input/`, `output/`,
`user/`, `temp/`. Export `COMFYUI_BASE` to relocate it (e.g. to a larger disk).

## Installing ComfyUI

The default `USE=cuda` build is in the Quickstart above. The USE flags:

| USE | Effect |
|---|---|
| `+cuda` | NVIDIA/CUDA torch backend (default) |
| `rocm` | AMD/ROCm backend (mutually exclusive with `cuda`) |
| `compile` | pull `dev-python/triton-bin` for `torch.compile` / inductor nodes |
| `+templates` | bundled example-workflow gallery (~330 MiB of preview assets) |
| `extra` | `spandrel` (upscalers) + `kornia` (CV nodes) |
| `opengl` | `comfy-angle` + `pyopengl` for GLSL shader nodes |
| `audio` | `torchaudio` for the audio nodes (must match the installed PyTorch) |

!!! tip "Faster sampling with `USE=compile`"
    `USE=compile` pulls `dev-python/triton-bin`, enabling `torch.compile` /
    Inductor custom nodes and `comfy_kitchen`'s Triton kernel backend — worth it
    on a capable GPU for repeated workflows.

The launcher passes ComfyUI's own flags straight through — for example, to
listen on all interfaces and a custom port:

```bash title="user $"
comfyui --listen --port 8189
```

`--listen` exposes ComfyUI to other hosts. Use it only on a trusted network or
behind an authenticated reverse proxy and firewall; the loopback default is the
safe choice for a workstation.

### Custom nodes

ComfyUI auto-loads nodes from two directories: per-user
`$COMFYUI_BASE/custom_nodes` (git-cloned by the user) and the system-wide
`/usr/share/comfyui/custom_nodes` (where overlay-packaged nodes are installed).
A node from upstream is added per-user, as a normal user:

```bash title="user $"
git clone https://github.com/city96/ComfyUI-GGUF \
  ~/.local/share/comfyui/custom_nodes/ComfyUI-GGUF
```

This manually cloned node is outside portage and must be updated or removed by
the user. (`dev-python/gguf` is packaged, so GGUF-quantized checkpoints load once
the `ComfyUI-GGUF` node is present.)

### Models

ComfyUI loads models from per-type subdirectories of `$COMFYUI_BASE/models` —
`checkpoints/`, `loras/`, `vae/`, `clip/`, `controlnet/`, `upscale_models/`, and
so on. Drop a checkpoint in `~/.local/share/comfyui/models/checkpoints/` and it
appears in the loader node after a refresh.

To reuse an existing model collection (e.g. a shared Stable-Diffusion-WebUI tree)
instead of copying files, point ComfyUI at it with the launcher's pass-through
`--extra-model-paths-config` flag, as a normal user:

```bash title="user $"
comfyui --extra-model-paths-config ~/extra_model_paths.yaml
```

where the YAML maps each model type onto the external base directory:

```yaml title="~/extra_model_paths.yaml"
a1111:
    base_path: /data/stable-diffusion-webui/models
    checkpoints: Stable-diffusion
    vae: VAE
    loras: Lora
```

## TRELLIS image-to-3D

[TRELLIS](https://github.com/microsoft/TRELLIS) turns a single image into a 3D
asset (a Gaussian-splat `.ply`, optionally a textured `.glb` mesh). The overlay
ships it as a packaged custom node plus its CUDA dependency cluster
(`spconv-cu126`, `nvdiffrast`, `diff-gaussian-rasterization`, …). Install it as
root:

```bash title="root #"
emerge -av media-gfx/comfyui-if-trellis
```

The node installs to `/usr/share/comfyui/custom_nodes/ComfyUI-IF_Trellis`. Its
pretrained weights are **not** bundled — download `microsoft/TRELLIS-image-large`
(its `pipeline.json` + `ckpts/`) into the models tree with `huggingface-cli`
(from `dev-python/huggingface-hub`), as a normal user:

```bash title="user $"
huggingface-cli download microsoft/TRELLIS-image-large \
  --local-dir ~/.local/share/comfyui/models/checkpoints/TRELLIS-image-large
```

Restart ComfyUI; the IF_Trellis nodes appear in the node menu, and the example
workflow shipped with the node loads an image and produces a `.ply`.

!!! note "Gaussian `.ply` works out of the box; mesh `.glb` needs `USE=mesh`"
    The Gaussian-splat (`.ply`) export path works with the default build. Textured
    **mesh** (`.glb`) export needs the post-processing deps — rebuild with
    `USE=mesh`, which pulls `dev-python/xatlas`, `dev-python/pyvista`,
    `dev-python/python-igraph`, and `dev-python/pymeshfix` (note `pyvista` drags
    in the heavy `sci-libs/vtk`):

    ```bash title="root #"
    echo "media-gfx/comfyui-if-trellis mesh" \
      >> /etc/portage/package.use/comfyui
    emerge -av media-gfx/comfyui-if-trellis
    ```

## Troubleshooting

- **`comfyui` runs on CPU / no GPU detected** — confirm the build has a backend:
  `USE=cuda` needs an NVIDIA CUDA 12.8+ runtime, `USE=rocm` needs the ROCm stack
  (see the [vLLM ROCm setup](vllm.md#amd-rocm-setup)), and verify the configured
  target with the [hardware-version guide](hardware-targets.md). A
  `-cuda -rocm` build is CPU-only.
- **TRELLIS nodes missing after install** — restart ComfyUI so it re-scans
  `/usr/share/comfyui/custom_nodes`, and confirm `media-gfx/comfyui-if-trellis`
  is installed (the node ships there, not under `$COMFYUI_BASE`).
- **TRELLIS fails to load the model** — the weights must sit at
  `$COMFYUI_BASE/models/checkpoints/TRELLIS-image-large/` with `pipeline.json`
  and `ckpts/` present; TRELLIS weights are `spconv`-format, which is why
  `dev-python/spconv-cu126` is a hard dependency.
- **`media-gfx/comfyui` won't emerge with `USE=audio`** — `sci-ml/torchaudio`
  must match the installed `sci-ml/pytorch`; it can lag the current stack, so
  leave `audio` off until it resolves.

## See also

- [The AI / ML stack in stuff](../ai-stack.md) — where ComfyUI fits among the
  AI packages.
- [ComfyUI](https://github.com/comfy-org/comfyui) ·
  [TRELLIS](https://github.com/microsoft/TRELLIS) ·
  [ComfyUI-IF_Trellis](https://github.com/if-ai/ComfyUI-IF_Trellis) — upstreams.

# Check the GPU hardware version

GPU source builds need the compiler target for the installed hardware, not
only its marketing name. Set the target before emerging an AMD ROCm or NVIDIA
CUDA stack so Portage builds device code for the right architecture.

## AMD: find the `gfx` target

Install AMD's inspection tools:

```bash title="root #"
emerge -av dev-util/amdsmi dev-util/rocminfo
```

Then inspect the ASIC and the HSA agents as a normal user:

```bash title="user $"
amd-smi static --asic
rocminfo | grep gfx
```

`amd-smi` identifies the GPU and, when the driver exposes it, reports
`TARGET_GRAPHICS_VERSION`. `rocminfo` provides the `gfx*` agent token that
Gentoo's ROCm ebuilds expect. Put that token in `/etc/portage/make.conf`:

```text title="/etc/portage/make.conf"
AMDGPU_TARGETS="gfx1150"
```

For multiple AMD architectures, use a space-separated list such as
`AMDGPU_TARGETS="gfx1100 gfx1150"`. Each additional target increases build
time and disk use. If `rocminfo` does not expose a usable GPU agent, do not
guess a nearby target; use a Vulkan backend where the application provides
one, or check the ROCm support status for that GPU.

## NVIDIA: find the compute capability

With the NVIDIA driver loaded, query every installed GPU:

```bash title="user $"
nvidia-smi --query-gpu=name,compute_cap --format=csv,noheader
```

The command reports a compute capability such as `8.6`. Gentoo packages use
that value in several forms:

| Build family | Portage environment variable | Example for capability 8.6 |
|---|---|---|
| CMake CUDA builds, including llama.cpp and Ollama | `CUDAARCHS` | `CUDAARCHS="86"` |
| PyTorch / LibTorch and consumers such as vLLM and ComfyUI | `TORCH_CUDA_ARCH_LIST` | `TORCH_CUDA_ARCH_LIST="8.6"` |
| CuPy 13.x | `NVPTX_TARGETS` | `NVPTX_TARGETS="sm_86"` |

For the common local-AI stack, set the first two in
`/etc/portage/make.conf`:

```text title="/etc/portage/make.conf"
CUDAARCHS="86"
TORCH_CUDA_ARCH_LIST="8.6"
```

If CuPy 13.x is also installed, add `NVPTX_TARGETS="sm_86"`. Multiple CMake
targets are semicolon-separated (`CUDAARCHS="86;89"`); multiple PyTorch
targets are space-separated (`TORCH_CUDA_ARCH_LIST="8.6 8.9"`). Restricting a
build to the hardware that will run it saves compile time and package size,
but a resulting binary package may no longer be portable to omitted GPU
architectures.

These variables select generated GPU code. They do not enable acceleration by
themselves: the package still needs its `cuda` or `rocm` USE flag. Individual
packages can document additional target variables, so check the emerge output
and package metadata when moving beyond this stack.

## See also

- [AMD SMI documentation](https://rocm.docs.amd.com/projects/amdsmi/en/latest/)
- [NVIDIA compute capabilities](https://docs.nvidia.com/cuda/cuda-programming-guide/05-appendices/compute-capabilities.html)
- [CMake `CUDAARCHS`](https://cmake.org/cmake/help/latest/envvar/CUDAARCHS.html)

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
| PyTorch / LibTorch (`sci-ml/caffe2`) and PyTorch-based CUDA extensions | `TORCH_CUDA_ARCH_LIST` | `TORCH_CUDA_ARCH_LIST="8.6"` |
| CuPy 13.x and 14.x | `NVPTX_TARGETS` | `NVPTX_TARGETS="sm_86"` |

### Apply the environment to the packages that compile CUDA code

In `stuff`'s split PyTorch packaging, **`sci-ml/caffe2` builds LibTorch and
its CUDA kernels**. An environment assigned only to `sci-ml/pytorch`, vLLM
or ComfyUI does not configure that dependency's build. Portage applies
`package.env` entries to the matching packages, not recursively to their
dependencies.

`make.conf` can supply machine-wide defaults. To make the package scope
explicit, create a shared environment file and map each relevant source
package to it. This example is for a GPU reporting capability **8.6**;
substitute the target of the machine that will run the resulting binaries.

```text title="/etc/portage/env/cuda-sm86"
CUDAARCHS="86"
TORCH_CUDA_ARCH_LIST="8.6"
NVPTX_TARGETS="sm_86"
```

Add the applicable entries to `/etc/portage/package.env`, or to a file inside
it if it is already a directory. Preserve any existing environment mappings:

```text title="/etc/portage/package.env"
sci-ml/caffe2::stuff cuda-sm86
dev-python/vllm::stuff cuda-sm86
sci-misc/llama-cpp::stuff cuda-sm86
sci-ml/ollama::stuff cuda-sm86
dev-python/cupy::stuff cuda-sm86
dev-python/nvdiffrast::stuff cuda-sm86
```

These mappings do not install packages or enable CUDA. Extend the list to
the source-built CUDA extensions used by the application; the ComfyUI stack,
for example, needs the `caffe2` mapping and mappings for its compiled custom
extensions, not merely an entry for `media-gfx/comfyui`. The `::stuff`
qualifiers deliberately limit this example to the overlay's ebuilds.

For multiple architectures, CMake targets are semicolon-separated
(`CUDAARCHS="86;89"`), while PyTorch and CuPy targets are space-separated
(`TORCH_CUDA_ARCH_LIST="8.6 8.9"`, `NVPTX_TARGETS="sm_86 sm_89"`). Keep the
lists consistent. Restricting a build to its intended hardware reduces build
time and package size, but a binary package may not run on omitted GPU
architectures.

### Rebuild after changing targets

These are **build-time settings**, not runtime switches for an already
installed PyTorch. After changing them, explicitly rebuild `caffe2` and the
installed CUDA extensions whose targets changed; `--newuse` alone does not
describe an environment-variable change.

For example, to rebuild the overlay's PyTorch core from source:

```bash title="root #"
emerge --ask --verbose --oneshot --usepkg=n --getbinpkg=n sci-ml/caffe2::stuff
```

Review the proposed version against the PyTorch line required by the
application. Use an exact version atom if needed to rebuild the installed
line rather than upgrade it. Rebuilding only `sci-ml/pytorch` is not a
substitute for rebuilding the CUDA core. Rebuild affected source extensions
separately; their installed binaries do not change when the environment file
is edited. These variables also cannot retarget prebuilt wheels, including
the CUDA wheel components described in the [ComfyUI guide](comfyui.md#gpu-backend).

### Package-specific exceptions

CuPy 13.x uses `NVPTX_TARGETS`. The overlay's CuPy 14.x ebuilds prefer that
variable too, but fall back to `CUDAARCHS` when it is unset. For an explicit
target list, the 14.x build checks `nvcc --list-gpu-code` and fails if none
are supported. A stale `NVPTX_TARGETS` value therefore takes precedence over a
new `CUDAARCHS` value.

Standalone `dev-python/flash-attn` uses **`FLASH_ATTN_CUDA_ARCHS`**, with
the packaged 2.8.3_p1 ebuild defaulting to `"80;90"`. Its architecture
selectors are package-specific: do not derive an override merely by removing
the decimal point from the GPU capability. Check the source for the version
being built (see the [upstream 2.8.3 selection logic](https://github.com/Dao-AILab/flash-attention/blob/v2.8.3/setup.py))
before overriding it, and keep any override in a separate environment mapped
only to `dev-python/flash-attn`. `TORCH_CUDA_ARCH_LIST` is not a substitute
for that selector. PyTorch's and vLLM's bundled attention builds are separate
from this standalone package.

Architecture variables do not enable optional GPU backends: select the
package's `cuda` or `rocm` USE flag where the ebuild provides one. CUDA-only
packages may not offer a backend flag. Check the emerge output and package
metadata for additional package-specific requirements.

## See also

- [AMD SMI documentation](https://rocm.docs.amd.com/projects/amdsmi/en/latest/)
- [NVIDIA compute capabilities](https://docs.nvidia.com/cuda/cuda-programming-guide/05-appendices/compute-capabilities.html)
- [CMake `CUDAARCHS`](https://cmake.org/cmake/help/latest/envvar/CUDAARCHS.html)
- [Portage per-package environments](https://wiki.gentoo.org/wiki/Handbook:Parts/Portage/Advanced#Per-package_environment_variables)

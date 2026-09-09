# The AI / ML stack in `stuff`

Currently, `::gentoo` carries the ML foundations — including
PyTorch 2.14 and the usual Python libraries — but less of the local-inference
application layer: no Ryzen AI NPU stack or vLLM, and its coherent ROCm line
tops out at 7.2. (`llama.cpp` is available from GURU, not the main tree.)
`stuff` complements that base with four actively packaged accelerator paths:
AMD's Ryzen AI **NPU**, AMD GPUs through **ROCm 10**, NVIDIA through **CUDA**,
and cross-vendor **Vulkan** — plus plain CPU. It supplies LLM runtimes, serving
layers, chat clients, a deep speech/audio stack, and additional PyTorch / ONNX
packaging.

## List of guides

| Hardware | Accelerator | Runtimes | Guide |
|---|---|---|---|
| AMD Ryzen AI system (supported XDNA 2 family) | NPU (`amdxdna`) | `fastflowlm`, `lemonade` | [Ryzen AI NPU](guides/ryzen-ai-npu.md) |
| AMD GPU (RDNA / CDNA) | ROCm 10.0 | `llama.cpp[rocm]`, `vllm[rocm]` (CDNA-first) | [vLLM](guides/vllm.md) · [llama setup](guides/llama-setup.md) |
| NVIDIA GPU | CUDA | `llama.cpp[cuda]`, `vllm[cuda]` | [vLLM](guides/vllm.md) · [llama setup](guides/llama-setup.md) |
| Vulkan-capable GPU | Vulkan | `llama.cpp[vulkan]`, `ollama[vulkan]`, `koboldcpp[vulkan]` | [llama setup](guides/llama-setup.md) |
| No discrete GPU | CPU | `llama.cpp` (OpenBLAS / BLIS), `vllm[cpu]` | [vLLM](guides/vllm.md) · [llama setup](guides/llama-setup.md) |

!!! tip "Match accelerator builds to the installed GPU"
    Before building a GPU stack, follow
    [Check the GPU hardware version](guides/hardware-targets.md). It maps AMD's
    `gfx*` token to `AMDGPU_TARGETS` and NVIDIA compute capability to the
    `CUDAARCHS`, `TORCH_CUDA_ARCH_LIST`, and `NVPTX_TARGETS` forms used by the
    packages below.

!!! tip "Cross-vendor shortcuts"
    `llama.cpp[vulkan]` runs on both AMD and NVIDIA GPUs with no ROCm or CUDA
    installed. Vulkan can also be faster than ROCm on some AMD hardware and
    workloads; the
    [llama setup guide](guides/llama-setup.md#vulkan-versus-rocm-on-amd)
    scopes the recorded result and explains how to compare them.
    [ZLUDA](https://github.com/vosen/ZLUDA) (`dev-util/zluda`) runs CUDA-only
    software on AMD GPUs.

## Hardware backends

- **NPU** — `dev-libs/xdna-driver` (the `amdxdna` module + firmware),
  `dev-util/xrt`, `dev-libs/xrt-xdna`. Full setup in the
  [Ryzen AI NPU guide](guides/ryzen-ai-npu.md).
- **AMD GPU — ROCm 10.0** — the complete source-built ROCm 10.0 cohort
  (`dev-libs/rocm-*`, `sci-libs/{roc,hip}*` — rocBLAS, hipBLAS, rocFFT,
  rocSOLVER, `sci-libs/miopen`, `sci-libs/composable-kernel`, `dev-libs/rccl`,
  …), with AMD's matching `llvm-core/rocm-llvm` fork where the math stack needs
  it. The final 7.x release, 7.2.4, remains available as a rollback anchor.
  `dev-util/therock-bin` installs
  AMD's prebuilt ROCm SDK under `/opt` for a per-host `AMDGPU_TARGETS` — note
  these are **pre-built AMD binaries** (the ebuild sets the matching
  `RESTRICT`); for production, prefer the source-built `/usr` stack.
- **NVIDIA GPU — CUDA** — `dev-util/nvidia-cuda-toolkit`,
  `dev-python/cuda-python` / `cuda-bindings`, `dev-python/cupy`,
  `dev-python/pycuda`.
- **Cross-vendor GPU — Vulkan** — a lighter backend available in
  `sci-misc/llama-cpp`, `sci-ml/ollama`, `sci-misc/koboldcpp`, and
  `sci-misc/stable-diffusion-cpp`; it avoids installing the ROCm or CUDA
  compute stack.
- **ZLUDA** — `dev-util/zluda`, a drop-in CUDA implementation for AMD GPUs.

## Runtimes and servers

- **`sci-misc/llama-cpp`** — the universal runtime: CPU (OpenBLAS / BLIS), ROCm,
  CUDA, Vulkan, SYCL, or OpenCL by USE flag, with a bundled web UI
  (`USE=webui`).
- **[`dev-python/vllm`](guides/vllm.md)** — high-throughput serving engine;
  `cpu`, `cuda`, and
  `rocm` backends (the ROCm path is happiest on CDNA / server GPUs — on consumer
  cards `llama.cpp` is the smoother route). Its serving ecosystem is packaged
  too: `dev-python/flashinfer-python`, `xgrammar`, `llguidance`,
  `lm-format-enforcer`.
- **`sci-ml/lemonade`** — local OpenAI-compatible server for AMD NPU + GPU.
- **`sci-ml/fastflowlm`** — NPU-first LLM runtime (see the NPU guide).
- **`sci-misc/koboldcpp`** — all-in-one local AI server (LLM, image, speech,
  TTS) on the ggml/llama.cpp engine; Vulkan by default (`USE=+vulkan`), so it
  runs on AMD and NVIDIA GPUs with neither ROCm nor CUDA installed.
- **[`sci-misc/llama-swap`](guides/llama-setup.md)** — model-swapping proxy that sits in front of
  llama.cpp / vllm and routes OpenAI-compatible requests to the right backend.

## Clients, UIs and proxies

- **`dev-util/aichat`** — all-in-one LLM CLI (chat REPL, shell assistant, RAG,
  agents; multi-provider).
- **`www-apps/hollama`** — minimal browser chat UI; talks to any
  OpenAI-compatible endpoint.
- **`sci-ml/amd-gaia`** — AMD's agent framework (`api` / `mcp` / `talk` / `ui` …
  USE flags).
- **`dev-util/rtk`** — proxy that trims dev-command output before it reaches an
  LLM, cutting token use.
- **`dev-python/mcp`** — Model Context Protocol SDK.

## Speech and audio ML

- **ASR** — `app-accessibility/whisper-cpp`, `dev-python/openai-whisper`,
  `sci-ml/sherpa-onnx` (+ `sherpa-onnx-bin`).
- **Speaker diarization** — `sci-ml/pyannote-audio` and the
  `pyannote-{core,pipeline,metrics,database}` chain, plus
  `sci-ml/pyannoteai-sdk`.
- **TTS** — `sci-ml/kokoros` (Kokoro-82M server, Rust, OpenAI-compatible API).
- **Audio DSP** — `sci-ml/torch-audiomentations`, `torch-pitch-shift`, `julius`,
  `asteroid-filterbanks`.

## PyTorch / ONNX ecosystem

`::gentoo` and `stuff` both package PyTorch, but arrange its C++ and Python
halves differently. Currently:

- **`::gentoo`** carries `sci-ml/pytorch` 2.14 as a complete Python + C++
  build with CPU, CUDA, and ROCm USE paths. Its separately useful
  `sci-ml/caffe2` (LibTorch/C++) remains at 2.12, and the main-tree PyTorch
  ROCm dependency window is below 7.3.
- **`stuff`** carries a matched 2.14 split. `sci-ml/caffe2` builds LibTorch,
  `torch._C`, and the selected CPU/CUDA/ROCm backend; `sci-ml/pytorch`
  packages the Python trees and exact-depends on the matching `caffe2`. This
  avoids building LibTorch twice and lets the Python stack use the overlay's
  ROCm 10 cohort.

Around that base, the overlay also carries:

- **Media tensors** — `sci-ml/torchaudio`, `sci-ml/torchcodec`.
- **Inference** — `sci-libs/onnxruntime`, `sci-libs/dlpack`.
- **Training & metrics** — `sci-ml/lightning` (+ `lightning-utilities`),
  `sci-ml/torchmetrics`, `sci-ml/pytorch-metric-learning`.
- **Embeddings & retrieval** — `sci-ml/sentence-transformers`, `sci-libs/faiss`.
- **Hyperparameter tuning** — `dev-python/optuna`.

## Fine-tuning and RAG

`stuff` ships `sci-ml/bitsandbytes`, `sci-ml/peft`, `sci-ml/trl`, and
`sci-ml/unsloth` for fine-tuning, plus `app-misc/qdrant`,
`sci-ml/sentence-transformers`, and `sci-libs/faiss` for retrieval-augmented
generation. See the
[fine-tuning, Unsloth & RAG guide](guides/fine-tuning-rag.md) for a complete
walkthrough:

- **Fine-tuning** — `sci-ml/bitsandbytes` (k-bit quantization for QLoRA, 8-bit
  optimizers; CPU by default, ROCm/HIP with `USE=rocm`), `sci-ml/peft`
  (LoRA / QLoRA adapters), `sci-ml/trl` (SFT / DPO / GRPO trainers), on the
  `sci-ml/transformers` + `datasets` + `accelerate` substrate.
- **Guided training** — `sci-ml/unsloth` plus `dev-python/unsloth-zoo`; optional
  `USE=studio` builds the browser UI and serves it from the system Python stack
  with `unsloth-studio`, rather than bootstrapping a private environment.
- **Vector store / RAG** — `app-misc/qdrant`, the vector database as a system
  service (OpenRC + systemd units, loopback-bound by default), pairing with
  `sci-ml/sentence-transformers` for embeddings.

## Evaluation and model formats

- **Eval harnesses** — `sci-ml/lm-eval`, `sci-ml/evalplus`,
  `sci-ml/bigcode-eval`.
- **Formats** — `dev-python/gguf`, `dev-python/compressed-tensors`.
- **Fast loading** — `dev-python/tensorizer`, `dev-python/fastsafetensors`,
  `dev-python/runai-model-streamer-bin`.

## Notes

- Every package assumes `::gentoo` is enabled (`masters = gentoo`); the overlay
  layers on top, it doesn't replace.
- Versions move quickly. After synchronizing the repositories and refreshing
  the eix cache, `eix --in-overlay stuff` shows the current packages and
  versions provided by the overlay. The overlay's
  [README](https://github.com/istitov/stuff#readme) provides the maintained
  overview; this page is a curated orientation, not an exhaustive index.

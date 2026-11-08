# sci-ml — local AI and machine learning

This category holds the overlay's machine-learning packages: the AMD Ryzen AI
NPU stack, the PyTorch and Hugging Face libraries, fine-tuning, speech and
evaluation. Thirteen of them also exist in `::gentoo`, where the overlay
carries newer versions or patched forks. The
[AI stack overview](https://istitov.github.io/stuff/ai-stack/) covers how they
fit together with the runtimes, GPU backends and clients in other categories.

## AMD Ryzen AI NPU

`fastflowlm` is an NPU-first LLM runtime for XDNA2 processors. `openflowlm` is
its community fork, which builds the open LLM kernels from source around
FastFlowLM's prebuilt engine. `flm-q4nx-converter` repacks a GGUF fine-tune of
a model FastFlowLM already ships into FastFlowLM's format. `lemonade` is a
local AI server for the NPU and GPU, and the agent framework `amd-gaia` uses
it as its default backend. See the
[Ryzen AI NPU guide](https://istitov.github.io/stuff/guides/ryzen-ai-npu/).

## PyTorch and Hugging Face

- PyTorch: `pytorch`, `caffe2`, `torchvision`, `torchaudio`, `torchcodec`,
  `torchao`, `xformers`, `kineto`, `lightning`, `lightning-utilities`.
- Hugging Face: `transformers`, `tokenizers`, `huggingface_hub`, `hf_xet`,
  `diffusers`, `accelerate`, `sentence-transformers`.
- Also `onnx`, `sentencepiece`, `ollama`, and the ModelScope clients
  `modelscope` and `modelscope-hub`.

## Fine-tuning

`peft`, `trl`, `bitsandbytes` and `unsloth`, plus the Unsloth desktop UI as
`unsloth-desktop` and a masked `unsloth-desktop-bin`. See
[fine-tuning and RAG](https://istitov.github.io/stuff/guides/fine-tuning-rag/).

## Speech and audio

Speaker diarization with `pyannote-audio` and its `pyannote-*` libraries (plus
`pyannoteai-sdk` for the hosted pyannoteAI API), speech-to-text and TTS with
`sherpa-onnx` (or `sherpa-onnx-bin`), the Kokoro TTS server `kokoros`, and
audio helpers for PyTorch: `torch-audiomentations`, `torch-pitch-shift`,
`julius`, `asteroid-filterbanks`.

## Evaluation

`lm-eval`, `evalplus`, `bigcode-eval`, `evaluate`, `torchmetrics` and
`pytorch-metric-learning`. Measurements made with the overlay's own packages
are on the [benchmarks page](https://istitov.github.io/stuff/benchmarks/).

To enable the overlay, see the [setup guide](https://istitov.github.io/stuff/setup/)
or the [overlay README](../README.md).

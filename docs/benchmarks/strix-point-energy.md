---
tags:
  - AMD iGPU
  - NPU
  - Vulkan
  - ROCm
  - speech-to-text
  - LLM inference
---

# Socket power and energy on Strix Point

## Abstract

This study measures socket power and energy on a Framework 13 with an AMD
Ryzen AI 9 HX 370 (Strix Point) running Gentoo Linux, for two workloads. The
first is Whisper speech-to-text with the turbo model on the XDNA 2 NPU and on
the Radeon 890M through Vulkan and ROCm. The second is llama.cpp prefill and
decode on the Radeon 890M, comparing Vulkan with ROCm on four models. All
measurements were taken on AC power during one night in September 2026.

For speech-to-text, the NPU path drew about 56% of the socket power of the
Vulkan path but took about three times as long, so it used 1.5–1.7 times as
much energy per minute of audio. For llama.cpp, socket power was close to 33 W
on both backends, so energy per token followed speed. Vulkan was faster than
ROCm in every test up to 4,096 prompt tokens. At 16,384 and 32,768 prompt
tokens ROCm was 5–10% faster on the mixture-of-experts model only.

Socket power is the firmware-reported figure for the whole processor package.
It is not wall power or battery drain.

## Experimental methods

### Platform and software

| Item | Measured configuration |
|---|---|
| Host | Framework 13, Ryzen AI 9 HX 370, Radeon 890M (`gfx1150`), XDNA 2 NPU, on AC power |
| System | Linux 7.2.0-pf6, Mesa 26.2.3 (RADV), ROCm/HIP 10.0.0 |
| Speech-to-text | whisper.cpp 1.9.4; FastFlowLM 1.0.6 behind Lemonade 11.9.0 |
| LLM | llama.cpp 0.5.0 (build 11146), `llama-bench` |

The measured Gentoo packages were `app-accessibility/whisper-cpp`,
`sci-misc/llama-cpp`, `sci-ml/fastflowlm` and `sci-ml/lemonade` from the
`stuff` overlay. The Vulkan runs used the installed packages. The ROCm runs
used the same ebuilds compiled with HIP for `gfx1150` and run from their build
directories, without installation.

### Power measurement

Power is `average_socket_power` from the amdgpu `gpu_metrics` interface,
sampled every 0.5 s. Energy is the trapezoidal integral over each measured
window, with linear interpolation at the window boundaries and no idle
subtraction.

Before each cell a gate required AC power, a battery that was not discharging,
a hottest thermal zone below 70 °C and a one-minute load average below 1.0. It
then waited until every socket sample stayed below 8 W for 30 consecutive
seconds. The idle readings recorded before the speech-to-text cells were
5.1–6.6 W.

### Speech-to-text workload

The corpus, models and scoring are those of the
[Whisper on FLEURS study](whisper-on-fleurs.md): 100 English and 100 Russian
FLEURS recordings, 15.9 and 19.6 minutes of audio. Only the turbo model was
measured, on three paths: whisper.cpp on Vulkan, whisper.cpp on ROCm, and
FastFlowLM on the NPU. Each path and language was measured three times, for 18
cells. The power window of a cell is the transcription itself. The NPU model
was loaded before the idle wait.

### llama.cpp workload

| Model | File |
|---|---|
| Qwen3.5-2B | `Qwen3.5-2B-Q4_K_M.gguf` |
| Qwen3.5-4B | `Qwen3.5-4B-Q4_K_M.gguf` |
| Gemma-4-E4B-it | `gemma-4-E4B-it-Q4_1.gguf` |
| Qwen3.6-35B-A3B | `Qwen3.6-35B-A3B-Q4_K_M.gguf` |

These are the model files of the
[NPU versus Radeon 890M study](npu-vs-890m.md). Their SHA-256 values are in
the evidence notes; they were computed after the run.

Each model and backend was one `llama-bench` call with all layers on the GPU
(`-ngl 99`) and flash attention on. A discarded 32-token prefill came first
and absorbed model loading. The first run then measured prefill of 512 and
4,096 tokens and decode of 128 tokens with five repetitions. A second run
measured prefill of 16,384 and 32,768 tokens with three repetitions. Backend
order alternated per model.

Each test has its own power window, which includes llama-bench's warm-up for
that test. Energy per token is the mean socket power of the window divided by
llama-bench's mean tokens per second. Prefill and decode here are synthetic
`llama-bench` tests, not served requests.

## Results

### Speech-to-text

Means of three repetitions.

| Path | WER, English / Russian | × realtime, English / Russian | Socket power (W), English / Russian | Energy per audio minute (J), English / Russian |
|---|---:|---:|---:|---:|
| Radeon 890M, Vulkan | 5.65% / 5.85% | 11.3 / 11.3 | 33.0 / 32.7 | 175 / 174 |
| Radeon 890M, ROCm | 5.61% / 6.01% | 9.4 / 10.2 | 32.8 / 32.7 | 210 / 192 |
| NPU, FastFlowLM | 9.14% / 33.76% | 3.7 / 4.1 | 18.6 / 18.2 | 300 / 268 |

The NPU path drew about 56% of the socket power of the Vulkan path and ran
2.8–3.0 times as long. It therefore used 1.5–1.7 times as much energy per
minute of audio. About 1.3 W of its 18 W was reported in the NPU power domain;
the remainder was the rest of the package.

ROCm used 10–20% more energy per audio minute than Vulkan at the same socket
power, because it was slower. Energy per audio minute varied between
repetitions by under 1% on Vulkan, under 2% on the NPU and up to 7% on ROCm.

The NPU path was also the least accurate. Its error rates are those of the
Whisper on FLEURS study, where the
[NPU transcripts](whisper-on-fleurs.md#npu-transcripts) are analyzed.

### llama.cpp speed

Mean tokens per second, listed as Vulkan / ROCm.

| Model | Prefill 512 | Prefill 4,096 | Decode 128 |
|---|---:|---:|---:|
| Qwen3.5-2B | 1,811 / 1,254 | 1,747 / 1,326 | 52.2 / 42.4 |
| Qwen3.5-4B | 732 / 529 | 692 / 548 | 24.9 / 21.4 |
| Gemma-4-E4B-it | 793 / 617 | 758 / 599 | 24.1 / 20.1 |
| Qwen3.6-35B-A3B | 449 / 372 | 424 / 397 | 25.6 / 21.0 |

Vulkan was faster than ROCm in all twelve comparisons: by 16–23% in decode, by
7–32% in 4,096-token prefill and by 21–44% in 512-token prefill. The smallest
difference was the 4,096-token prefill of Qwen3.6-35B-A3B, the
mixture-of-experts model.

### llama.cpp energy per token

Joules per token, listed as Vulkan / ROCm.

| Model | Prefill 4,096 | Decode 128 |
|---|---:|---:|
| Qwen3.5-2B | 0.021 / 0.026 | 0.63 / 0.78 |
| Qwen3.5-4B | 0.049 / 0.061 | 1.32 / 1.54 |
| Gemma-4-E4B-it | 0.044 / 0.056 | 1.37 / 1.64 |
| Qwen3.6-35B-A3B | 0.078 / 0.083 | 1.29 / 1.49 |

Mean socket power during decode was 33.0 W for every model and backend except
Qwen3.6-35B-A3B on ROCm, at 31.4 W. During 4,096-token prefill it was
33.0–36.5 W. With power nearly equal, energy per token followed speed.

The 512-token prefill windows lasted 1.9–8.5 s. Their power readings, from
29.6 to 41.5 W, are dominated by the transition from the previous test, and no
energy figure is reported for them.

### Long prefill

Mean tokens per second and joules per token, listed as Vulkan / ROCm.

| Model | Prefill 16,384 (t/s) | Prefill 32,768 (t/s) | Energy per token at 32,768 (J) |
|---|---:|---:|---:|
| Qwen3.5-2B | 1,503 / 1,243 | 1,282 / 1,055 | 0.026 / 0.031 |
| Qwen3.5-4B | 600 / 486 | 512 / 424 | 0.064 / 0.078 |
| Gemma-4-E4B-it | 654 / 428 | 535 / 277 | 0.062 / 0.113 |
| Qwen3.6-35B-A3B | 340 / 358 | 260 / 287 | 0.127 / 0.115 |

The two Qwen3.5 models kept a Vulkan advantage of 21–24% at both lengths.
Gemma-4-E4B-it on ROCm fell behind as the prompt grew: Vulkan was 27% faster
at 4,096 tokens, 53% at 16,384 and 94% at 32,768. The cause was not
investigated.

Qwen3.6-35B-A3B reversed. ROCm was 5% faster at 16,384 tokens and 10% faster
at 32,768, and used correspondingly less energy per token. Decode on the same
model was still 22% faster on Vulkan.

These windows lasted 44–504 s. Socket power was 33.0–34.2 W in every long
window except Gemma-4-E4B-it on ROCm at 32,768 tokens, at 31.3 W.

## Discussion and limitations

Socket power covers the processor package: CPU cores, integrated GPU, NPU and
their shared logic. It is not wall power and not battery drain, and no idle
power was subtracted. A path that leaves the machine idle sooner is credited
only for the measured window.

The near-constant 33 W under Radeon 890M load is consistent with a sustained
package power limit. Throttle counters were not logged in this run, so the
limit is inferred and not measured.

The speech-to-text comparison is between complete paths. The NPU path differs
from whisper.cpp in runtime and model format (FastFlowLM `q4nx` against
whisper.cpp `q8_0`) as well as in device. The result does not show that the
NPU hardware is inefficient; it shows that this path used more energy for this
workload. It also does not cover a case where the NPU runs alongside a GPU
job, which was not measured.

The ROCm builds were uninstalled test builds of the overlay ebuilds on
`gfx1150` with ROCm 10.0.0. Other ROCm versions, other GPUs and tuned builds
may behave differently. The llama.cpp tests measure throughput only and say
nothing about answer quality.

The measurements come from one laptop on one night. Three or five repetitions
are repeated measurements, not independent hardware samples.

## Conclusion

On this Framework 13, Vulkan on the Radeon 890M was the fastest measured path
for Whisper and for llama.cpp, and because socket power was nearly the same
across Radeon 890M workloads it was also the one that used the least energy.
ROCm was slower in every llama.cpp test except long prefill on the
mixture-of-experts model. The NPU path for Whisper drew less power but used
more energy per minute of audio.

## Data availability and reproducibility

The [speech-to-text table](data/strix-point-energy-2026-09-25-whisper.csv) has
one row per cell with WER, speed, mean socket power, socket energy, energy per
audio minute, NPU and graphics domain power and the idle reading before the
cell. The [llama.cpp table](data/strix-point-energy-2026-09-25-llama.csv) has
one row per model, backend and test with tokens per second, its standard
deviation, window length, mean socket power and joules per token.

The [sanitized energy evidence archive](https://raw.githubusercontent.com/istitov/stuff-benchmarks/d22bc593998930fa6cee4e0340c2555b4b48a284/data/strix-point-energy-2026-09-25.tar.7z)
and its [method and verification notes](https://github.com/istitov/stuff-benchmarks/blob/d22bc593998930fa6cee4e0340c2555b4b48a284/docs/STRIX-ENERGY.md)
are pinned to signed commit `d22bc59`. The archive keeps the raw power
records of every cell, the transcripts, the llama-bench output and the exact
command of each cell. Verification rescores the speech-to-text cells,
recomputes their energy from the raw samples, checks the llama.cpp rates
against the llama-bench output and regenerates both tables. The llama.cpp
windows were saved as durations only, so their start is rebuilt from the
power samples; the recomputed mean power matches the recorded values to
within 0.02%.

## References and setup guides

- [whisper.cpp](https://github.com/ggml-org/whisper.cpp)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [FastFlowLM](https://github.com/ROCm/FastFlowLM)
- [Ryzen AI NPU setup on Gentoo](../guides/ryzen-ai-npu.md)
- [llama.cpp, Ollama and llama-swap setup](../guides/llama-setup.md)
- [GPU hardware identification](../guides/hardware-targets.md)

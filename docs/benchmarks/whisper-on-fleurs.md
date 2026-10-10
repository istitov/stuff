---
tags:
  - AMD iGPU
  - NVIDIA GPU
  - Intel iGPU
  - NPU
  - CPU
  - Vulkan
  - ROCm
  - CUDA
  - speech-to-text
---

# Whisper accuracy and speed on FLEURS

## Abstract

This study measures speech-to-text accuracy and speed for Whisper on two
laptops running Gentoo Linux: a Framework 13 with an AMD Ryzen AI 9 HX 370 and
a laptop with an NVIDIA RTX A4500. The September 2026 experiment
transcribed 100 English and 100 Russian
[FLEURS](https://huggingface.co/datasets/google/fleurs) test recordings on 15
backend and model combinations, three times each, for 90 cells in total.
Fourteen combinations use whisper.cpp; one uses FastFlowLM on the XDNA 2 NPU.

With whisper.cpp, word error rate followed the model and not the backend: for
a given model and language it spanned at most 0.23 percentage points across
CPU, Vulkan, ROCm and CUDA on both machines. Speed differed widely. CUDA on
the RTX A4500 reached about 42× realtime with the turbo model, Vulkan on the
Radeon 890M about 11×, and both CPUs about 1×. FastFlowLM's NPU Whisper ran at
about 4× realtime and had a much higher error rate, especially in Russian,
where it returned shortened transcripts for 28 of 100 recordings.

The corpus contains short read-speech clips only. The results say nothing
about long recordings, silence or music, and they do not rank the hardware
for other workloads.

## Experimental methods

### Platforms and software

| Label | Hardware | Software |
|---|---|---|
| Framework 13 | Ryzen AI 9 HX 370, Radeon 890M (`gfx1150`), XDNA 2 NPU | Linux 7.2.0-pf6, Mesa 26.2.3 (RADV), ROCm/HIP 10.0.0, whisper.cpp 1.9.4, FastFlowLM 1.0.6 behind Lemonade 11.9.0 |
| RTX A4500 laptop | Core i9-12950HX, RTX A4500 Laptop 16 GB, Intel UHD Graphics (ADL-S GT1) | Linux 7.2.0-pf6, NVIDIA driver 615.71.09, CUDA 13.4.2, Mesa 26.2.3, whisper.cpp 1.9.4 built with CUDA and Vulkan |

The measured Gentoo packages were `app-accessibility/whisper-cpp`,
`sci-ml/fastflowlm` and `sci-ml/lemonade` from the `stuff` overlay.

| Host | Backend | How it was run |
|---|---|---|
| Framework 13 | Vulkan | Installed whisper.cpp with `USE=vulkan`, Radeon 890M, 8 threads |
| Framework 13 | ROCm | The same ebuild compiled with `USE="hip -vulkan"` and run from its build directory, not installed; 8 threads |
| Framework 13 | CPU | The installed build with the GPU disabled (`-ng`), 12 threads |
| Framework 13 | NPU | FastFlowLM `whisper-v3:turbo` served through Lemonade's transcription endpoint |
| RTX A4500 laptop | CUDA | Installed whisper.cpp with `USE="cuda vulkan"`, RTX A4500, 8 threads |
| RTX A4500 laptop | Vulkan | The same binary on the RTX A4500 and, separately, on the Intel iGPU; 8 threads |
| RTX A4500 laptop | CPU | The same binary with `-ng`, 16 threads |

Every whisper.cpp backend ran two models: `ggml-large-v3-turbo-q8_0.bin`
(turbo) and `ggml-large-v3-q8_0.bin` (large-v3, quantized locally from the
full-precision model). The same two files, identified by SHA-256, were used on
both hosts. The NPU ran only the turbo model. FastFlowLM uses its own `q4nx`
conversion, so the NPU row differs from the others in runtime and model format
as well as in device.

### Corpus

The corpus is 100 test recordings per language from FLEURS (CC-BY-4.0), one
recording per sentence, at dataset revision
`70bb2e84b976b7e960aa89f1c648e09c59f894dd`.

| Language | Recordings | Audio | Reference words | Clip length | Speakers (female / male) |
|---|---:|---:|---:|---:|---:|
| English | 100 | 15.9 min | 2,211 | 4.3–19.6 s | 66 / 34 |
| Russian | 100 | 19.6 min | 1,931 | 5.4–27.0 s | 48 / 52 |

The audio is not redistributed with the evidence. The evidence repository
lists each clip's FLEURS sentence ID, reference transcription and the SHA-256
of the exact WAV file, and includes a script that rebuilds all 200 clips byte
for byte from the two official FLEURS archives.

### Procedure

Each whisper.cpp cell was one `whisper-cli` call over all 100 clips of a
language, with whisper-cli's default decoding (beam size 5, best-of 5,
temperature 0 with fallback) and no voice-activity detection. The model was
loaded once per cell. Each NPU cell was 100 sequential requests after one
excluded warm-up request, with the model already loaded.

Each backend, model and language was measured three times. Backend order was
rotated and language order alternated between repetitions. Before each cell a
gate waited for AC power, a battery that was not discharging, a hottest thermal
zone below 70 °C and a one-minute load average below 2.5. On the RTX A4500 laptop
it also required NVIDIA utilization below 5%.

### Measurement and analysis

Word error rate (WER) and character error rate (CER) are corpus-level: summed
edits divided by summed reference words or characters. Text was lowercased and
stripped of punctuation, and Russian `ё` was mapped to `е`. Numerals were not
normalized, so "25 to 30" against "25-30" counts as errors. Absolute error
rates therefore depend on this scorer and should not be compared with
published leaderboards.

Speed is seconds of audio per second of wall-clock time ("× realtime"). For
whisper.cpp it includes one model load per cell. For the NPU it includes the
HTTP request and Lemonade overhead but not model loading. Speed values are
medians of the three repetitions.

## Results

### Reproducibility

All three repetitions of every cell produced identical transcripts, so the
error rates have no run-to-run spread. Wall-clock time for repeated cells
differed by at most 15%.

### Framework 13

| Backend, model | English WER / CER | Russian WER / CER | English × realtime | Russian × realtime |
|---|---:|---:|---:|---:|
| Vulkan, turbo | 5.65% / 2.52% | 5.85% / 1.60% | 11.3 | 11.3 |
| Vulkan, large-v3 | 5.29% / 2.59% | 5.49% / 1.57% | 6.5 | 5.8 |
| ROCm, turbo | 5.61% / 2.55% | 6.01% / 1.63% | 9.1 | 10.2 |
| ROCm, large-v3 | 5.16% / 2.44% | 5.44% / 1.51% | 5.2 | 4.8 |
| CPU, turbo | 5.74% / 2.54% | 5.96% / 1.66% | 1.0 | 1.3 |
| CPU, large-v3 | 5.16% / 2.43% | 5.64% / 1.54% | 0.9 | 1.0 |
| NPU (FastFlowLM), turbo | 9.14% / 6.14% | 33.76% / 27.89% | 3.8 | 4.1 |

Vulkan was the fastest backend on the Radeon 890M. With the turbo model it ran
1.24 times as fast as ROCm in English and 1.11 times in Russian; with
large-v3, 1.26 and 1.22 times. The turbo model was 1.7–1.9 times as fast as
large-v3 on Vulkan. The CPU transcribed at roughly realtime, 9 to 11 times
slower than Vulkan with the turbo model.

### RTX A4500 laptop

| Backend, model | English WER / CER | Russian WER / CER | English × realtime | Russian × realtime |
|---|---:|---:|---:|---:|
| CUDA on RTX A4500, turbo | 5.65% / 2.58% | 5.96% / 1.61% | 42.4 | 41.6 |
| CUDA on RTX A4500, large-v3 | 5.16% / 2.44% | 5.49% / 1.53% | 22.6 | 19.2 |
| Vulkan on RTX A4500, turbo | 5.56% / 2.53% | 6.01% / 1.63% | 38.8 | 37.8 |
| Vulkan on RTX A4500, large-v3 | 5.20% / 2.44% | 5.49% / 1.52% | 16.1 | 13.4 |
| Vulkan on Intel UHD, turbo | 5.52% / 2.54% | 5.90% / 1.64% | 1.3 | 1.5 |
| Vulkan on Intel UHD, large-v3 | 5.20% / 2.43% | 5.59% / 1.52% | 0.9 | 0.9 |
| CPU, turbo | 5.74% / 2.58% | 6.06% / 1.67% | 1.3 | 1.6 |
| CPU, large-v3 | 5.29% / 2.63% | 5.54% / 1.54% | 1.0 | 1.1 |

CUDA was the fastest backend on the RTX A4500. It was 1.09–1.10 times as fast
as Vulkan on the same card with the turbo model and 1.40–1.44 times with
large-v3. CUDA with the turbo model was 3.7 times as fast as Vulkan on the
Radeon 890M. The Intel iGPU through Vulkan was slightly slower than the CPU of
the same machine.

### Accuracy across whisper.cpp backends

| Model | English WER, 7 backends | Russian WER, 7 backends |
|---|---:|---:|
| turbo | 5.52–5.74% | 5.85–6.06% |
| large-v3 | 5.16–5.29% | 5.44–5.64% |

The backends did not produce identical text, but for a given model and
language their WER spanned at most 0.23 percentage points, which is about five
words out of roughly 2,000. The large-v3 model scored 0.3–0.6 points better
than turbo on the same backend, a difference of about 6 to 13 words. That is
too small to establish an accuracy advantage on this corpus.

### NPU transcripts

FastFlowLM returned a transcript with fewer than 80% of the reference word
count for 28 of the 100 Russian recordings and 4 of the 100 English ones. No
whisper.cpp cell on either machine produced such a transcript. On the
recordings the NPU transcribed in full, its WER was 15.8% in Russian and 6.7%
in English, against 6.0% and 5.7% for Vulkan with the turbo model on the same
recordings. The NPU result is therefore worse both because transcripts are cut
short and because the complete ones contain more errors.

The NPU requests passed the language as a form field. Whether Lemonade and
FastFlowLM used it was not checked, although every Russian output was in
Russian.

## Discussion and limitations

The rows compare complete paths as packaged: runtime, model format, driver and
device together. The NPU row in particular uses a different runtime and a
different model conversion, so it does not isolate the NPU hardware.

The corpus is short read speech. Long-form throughput, silence and music
handling, repeated-text loops and voice-activity detection were not measured.
A difference of a few tenths of a WER point corresponds to about a dozen words
or fewer and is not evidence of a real accuracy difference.

Each laptop is a single unit. Three repetitions are repeated measurements on
that unit, not independent hardware samples. Power was not measured in this
study; the [Strix Point energy study](strix-point-energy.md) adds socket power
for the turbo model on the Framework 13.

The ROCm rows used an uninstalled test build of the same ebuild. They show how
that build behaved on `gfx1150` with ROCm 10.0.0, not a tuned ROCm
configuration.

## Conclusion

On these two laptops, whisper.cpp gave the same accuracy on every backend, so
the backend can be chosen on speed alone: CUDA on the RTX A4500 and Vulkan on
the Radeon 890M. On those two GPUs the turbo model was 1.7–2.8 times as fast
as large-v3, for a WER difference this corpus cannot resolve. FastFlowLM's NPU
Whisper was slower than Vulkan on the same machine and substantially less
accurate, most of all in Russian.

## Data availability and reproducibility

The [30-row summary](data/whisper-fleurs-2026-09-24.csv) has one row per host,
backend, model and language. The
[90-row cell table](data/whisper-fleurs-2026-09-24-cells.csv) has one row per
repetition with audio seconds, wall seconds, speed, WER and CER.

The [sanitized Whisper evidence archive](https://raw.githubusercontent.com/istitov/stuff-benchmarks/d22bc593998930fa6cee4e0340c2555b4b48a284/data/whisper-fleurs-2026-09-24.tar.7z)
and its [method and verification notes](https://github.com/istitov/stuff-benchmarks/blob/d22bc593998930fa6cee4e0340c2555b4b48a284/docs/WHISPER-FLEURS.md)
are pinned to signed commit `d22bc59`. The archive holds every transcript, the
per-clip whisper.cpp output, timings, the exact command of each cell and the
harness that ran it. Verification recomputes every transcript from the
per-clip output, rescores all 90 cells against the FLEURS references and
regenerates both tables. It does not run a model or download audio.
Recomputing the scores does not authenticate the original capture.

## References and setup guides

- [whisper.cpp](https://github.com/ggml-org/whisper.cpp)
- [FastFlowLM](https://github.com/ROCm/FastFlowLM)
- [FLEURS dataset](https://huggingface.co/datasets/google/fleurs)
- [Ryzen AI NPU setup on Gentoo](../guides/ryzen-ai-npu.md)
- [GPU hardware identification](../guides/hardware-targets.md)
- [AI-stack overview](../ai-stack.md)

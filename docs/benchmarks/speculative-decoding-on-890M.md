---
tags:
  - AMD iGPU
  - Vulkan
  - LLM inference
---

# Speculative decoding on Radeon 890M

On this Radeon 890M, MTP speculative decoding substantially increased
generation speed for the two dense models tested. The two mixture-of-experts
(MoE) models gained less. Tuning the speculative settings added another
**2–6% on average** over the reference configuration, with different settings
winning for different models.

A separate [Muse Glimmer-30B DFlash follow-up](#muse-glimmer-30b-dflash-follow-up)
measured **1.64× and 1.50× median decode speedups** at two input lengths.
Faster generation did not translate directly into faster first answers:
on first long requests, later first-visible output largely offset the shorter
reasoning-to-answer interval.

These are **September 2026 measurements**. They cover llama.cpp's Vulkan backend
on a Framework 13 with a Ryzen AI 9 HX 370 (`gfx1150`, Strix Point).

For installation and backend selection, see
[Setting up llama.cpp, Ollama, and llama-swap](../guides/llama-setup.md).
The runtime is packaged as `sci-misc/llama-cpp` in `stuff`; these results
measure runtime configurations and do not compare overlays.

## MTP results

Multi-token prediction (MTP) uses a prediction head or a separate drafter to propose tokens that the
target model then verifies. Here, `n` is the maximum draft length and `p` is
the drafter probability threshold. The reference is **n=3, p=0.75** throughout
this MTP comparison. It is the reference used in the experiment, not a claim
about today's server defaults.

| Model | Best observed setting | Reference vs no speculation | Selected vs reference | Selected vs no speculation |
|---|---|---:|---:|---:|
| Qwen3.6-35B-A3B | n=1, p=0 | +9.76% | +5.88% | +16.21% |
| Qwen3.8-27B | n=2, p=0.5 | +58.71% | +2.41% | +62.52% |
| Gemma-4-26B-A4B | n=2, p=0.75 | +6.00% | +2.95% | +9.12% |
| Gemma-4-31B | n=3, p=0.5 | +81.81% | +2.58% | +86.62% |

Each percentage is the arithmetic mean of four context-specific comparisons.
For each context, the comparison divides the median of six measured decode
rates by the corresponding reference median. The four contexts have equal
weight; this is not a production-traffic-weighted result. Calculate each
column from its named reference rather than adding the percentages.

The Qwen models used their in-file MTP heads. The Gemmas used separate
drafter files. These settings were best **among those tested**, on this
workload; they are starting points for another measurement, not universal
defaults.

### Absolute generation speed

The table below gives median decode speed in **tokens per second (t/s)** for
each measured input length. Each value is the median of six requests. The
reference and selected settings are those in the results table above; input
length includes cached tokens. These are generation rates, not end-to-end
request speeds or prefill rates.

| Model | Actual input tokens | No speculation (t/s) | Reference (t/s) | Selected (t/s) |
|---|---:|---:|---:|---:|
| Qwen3.6-35B-A3B | 217 | 21.72 | 23.57 | 25.25 |
| Qwen3.6-35B-A3B | 897 | 21.61 | 23.87 | 25.16 |
| Qwen3.6-35B-A3B | 3,738 | 21.37 | 23.63 | 24.91 |
| Qwen3.6-35B-A3B | 16,183 | 20.42 | 22.37 | 23.62 |
| Qwen3.8-27B | 217 | 4.49 | 6.87 | 7.15 |
| Qwen3.8-27B | 895 | 4.48 | 7.12 | 7.48 |
| Qwen3.8-27B | 3,726 | 4.44 | 7.53 | 7.60 |
| Qwen3.8-27B | 16,142 | 4.30 | 6.61 | 6.58 |
| Gemma-4-26B-A4B | 217 | 26.88 | 29.52 | 30.67 |
| Gemma-4-26B-A4B | 870 | 26.12 | 27.98 | 28.77 |
| Gemma-4-26B-A4B | 3,698 | 25.65 | 27.55 | 28.06 |
| Gemma-4-26B-A4B | 16,164 | 23.91 | 23.83 | 24.59 |
| Gemma-4-31B | 217 | 4.06 | 7.79 | 8.20 |
| Gemma-4-31B | 870 | 3.96 | 7.29 | 7.43 |
| Gemma-4-31B | 3,698 | 3.91 | 7.02 | 7.24 |
| Gemma-4-31B | 16,164 | 3.74 | 6.43 | 6.43 |

## MTP workload and software

| Item | Measured configuration |
|---|---|
| Host | Framework 13, Ryzen AI 9 HX 370, Radeon 890M (`gfx1150`) |
| Memory configuration | 64 GB (2 × 32 GB) [DDR5-5600 SO-DIMM](https://frame.work/products/ddr5-5600?v=FRANRM0001X2), 5,600 MT/s, dual-channel (128-bit aggregate data width) |
| Memory bandwidth | 89.6 GB/s theoretical peak; achieved CPU/GPU memory throughput was not measured |
| Runtime identifier | llama.cpp `b10809-v0.4.0` / `0.4.0-dev` ([ebuild](https://github.com/istitov/stuff/blob/de725103a40bdbb6c1974d830bd5cc1c9f52b584/sci-misc/llama-cpp/llama-cpp-0.4.0.ebuild), [overlay commit](https://github.com/istitov/stuff/commit/de725103a40bdbb6c1974d830bd5cc1c9f52b584)) |
| Backend | Vulkan, GPU offload requested with `-dev Vulkan0 -ngl 99` |
| Kernel | `7.2.0-pf6` ([pf-sources ebuild](https://github.com/istitov/stuff/blob/dbba2a4124c6c4cf4894296c7caf7759b1acb3b7/sys-kernel/pf-sources/pf-sources-7.2_p6.ebuild), [overlay commit](https://github.com/istitov/stuff/commit/dbba2a4124c6c4cf4894296c7caf7759b1acb3b7)) |
| Power settings | AC connected; `performance` CPU governor; `balanced` platform profile |
| Thermal procedure | Wait for CPU Tctl ≤52°C before each configuration's server launch in each block; all recorded gates passed |
| Serving | One slot, context allocation 65,536 tokens; `kv_unified=false` |
| KV cache / attention | `-ctk q8_0 -ctv q8_0 -fa on` |
| Request | Temperature 0; `enable_thinking: false` in `chat_template_kwargs` |
| Input | One Russian text corpus, sliced/repeated to four sizes, with a long analytical-commentary instruction |
| Output ceiling | 768 tokens for Qwen3.6 and Gemma-26B; 512 for Qwen3.8 and Gemma-31B |
| Repetitions | Two blocks with reversed configuration order; three requests per configuration and context |

Memory bandwidth is a key constraint for single-stream LLM decoding on an
integrated GPU: weights and KV-cache traffic use system RAM shared with the CPU.
Compare memory configurations as well as GPU names when interpreting the t/s
figures. The theoretical ceiling here is **5,600 MT/s × 16 bytes = 89.6 GB/s**
(decimal GB/s), not a measured Vulkan transfer rate or bandwidth reserved for
the GPU. This experiment did not isolate memory bandwidth as the bottleneck.

All **480 requests** in this four-model comparison produced answer text,
recorded zero reasoning characters, and reached their configured output
ceiling with `finish_reason=length`. This measures capped generation,
not the time needed to finish a natural answer. The experiment did not
score answer quality.

At each input length, the repetitions use the same prompt and temperature-zero
request settings, with substantial cache reuse. They are repeated timing
observations, not six different tasks. The thermal gate applies before server
launch, not before every request or throughout generation.

### Model artifacts

The quantization labels differ between models. Comparisons are within each
model and use the same target artifact across its configurations.

| Model | Target GGUF filename | Separate drafter |
|---|---|---|
| Qwen3.6-35B-A3B | `Qwen3.6-35B-A3B-UD-Q4_K_M.gguf` | None |
| Qwen3.8-27B | `Qwen3.8-27B-UD-Q4_K_M.gguf` | None |
| Gemma-4-26B-A4B | `gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf` | `mtp-gemma-4-26B-A4B-it.gguf` |
| Gemma-4-31B | `gemma-4-31B-it-Q4_K_M.gguf` | `mtp-gemma-4-31B-it.gguf` |

### Actual prompt lengths

The harness aimed at 256, 1,024, 4,096, and 16,384 tokens. Its sizing
approximation fell short by up to 15.23%. The actual counts were
constant across configurations and repetitions within each model, as listed
in the [absolute generation speed table](#absolute-generation-speed).

Each configuration/context/block has one initial request followed by two
heavily cached repeats. Some initial requests also reuse a prefix. On repeats,
llama.cpp evaluates only four or five new prompt tokens; the rest remain in
cache. Full input length is the evaluated count plus the cached count.
The figures here describe **decode**, not cold-prompt prefill or first-token
latency.

## How consistent were the tuning gains?

The selected configuration retains the best average in each block and in
both the initial-request and cached-repeat subsets for all four models.

| Model | Block 1 gain | Block 2 gain | Initial requests only | Cached repeats only |
|---|---:|---:|---:|---:|
| Qwen3.6-35B-A3B | +5.72% | +6.04% | +8.18% | +5.23% |
| Qwen3.8-27B | +2.35% | +2.22% | +3.49% | +2.05% |
| Gemma-4-26B-A4B | +3.04% | +2.85% | +1.60% | +3.13% |
| Gemma-4-31B | +2.80% | +2.35% | +2.31% | +3.22% |

There are context-specific exceptions. Qwen3.8's selected configuration is
about 0.47% slower than the reference at 16,142 tokens. Gemma-31B's tuning
gain is effectively zero at 16,164 tokens. For Gemma-26B at that context,
the reference configuration is about 0.34% slower than disabling speculation;
the selected n=2 configuration is a separate comparison.

Two blocks on one corpus provide limited replication. The same observations
were used to select and evaluate the settings. These are descriptive results,
without a claim that small differences will persist across workloads or hosts.

## Muse Glimmer-30B: DFlash follow-up

A separate September 2026 experiment compared Muse Glimmer-30B with no
speculation against `draft-dflash` with maximum draft length **n=3**. This
was a two-arm comparison, not a draft-length search; n=3 is the tested setting,
not an established optimum. Its 48 requests are not pooled with the four-model
MTP results above.

### Generation speed

Each value below is the median of 12 requests; parentheses give the observed
minimum–maximum. The speedup divides the DFlash median by the baseline median
at the same input length. These rates include both reasoning and answer tokens.

| Actual input tokens | No speculation (t/s) | DFlash n3 (t/s) | Median decode speedup |
|---|---:|---:|---:|
| 874 | 4.82 (3.93–4.86) | 7.91 (6.90–8.32) | 1.64× |
| 16,255 | 4.78 (2.20–4.81) | 7.15 (6.63–7.24) | 1.50× |

DFlash had the higher within-block median in all four blocks at both input
lengths. The within-block speedup ranged from **1.51–1.70×** at 874 tokens and
**1.49–2.13×** at 16,255 tokens. Omitting one block at a time and recalculating
the pooled long-input ratio gives **1.49–1.86×**. The direction of the gain is
consistent, but its exact magnitude is less stable. These are descriptive
block and sensitivity ranges, not confidence intervals.

Baseline performance varied: the slowest long-context request reached
2.20 t/s, while the short-context minimum was 3.93 t/s. All slow observations
remain included. The experiment does not establish the cause of that variation.

### Time to an answer

Each block included a first request at each input length followed by two
heavily cached repeats. There are four first requests and eight repeats per
arm and input length. The first short request had no cached input; the first
long request reused a 49-token prefix. Repeats reused 869 or 16,250 input
tokens, leaving five to evaluate.

| Actual input tokens | Request category | n per arm | Median request time, baseline → DFlash | Median first-answer time, baseline → DFlash |
|---|---|---:|---:|---:|
| 874 | First in context | 4 | 117.39 → 75.06 s | 27.87 → 16.51 s |
| 874 | Cached repeat | 8 | 105.79 → 64.85 s | 19.55 → 7.28 s |
| 16,255 | First in context | 4 | 271.18 → 246.85 s | 188.98 → 187.72 s |
| 16,255 | Cached repeat | 8 | 134.06 → 72.74 s | 31.47 → 13.16 s |

Request time runs from sending the request to receiving the completed stream;
it excludes server startup and model loading. First-answer time is the arrival
of the first answer text, not the first reasoning token. All responses stopped
at the output cap, so this is not time to a naturally completed answer.

For the first long request, median request time fell from about 271 to 247
seconds, but first-answer time was almost unchanged. Median first-visible text
arrived **later** with DFlash (165.49 → 175.66 s), while the median interval
from that text to the first answer shortened (23.50 → 12.03 s). Prompt processing
dominated the initial wait; these opposing changes explain the near-tie.
The medians are calculated separately and need not add exactly. DFlash's first
answer was later in two of the four matched blocks, not consistently earlier.

Cached long repeats benefited much more, but varied substantially: request
times ranged from 107.17–233.20 s without speculation and 71.93–78.27 s with
DFlash. Keep cache categories separate when judging interactive responsiveness;
the [request and grouped data](data/muse-dflash-2026-09-09.md) retain all
observations and their ranges.

### Configuration and verification

The follow-up used the same Framework 13 / Radeon 890M hardware and memory
configuration described above, with llama.cpp identifying itself as
`0.4.0-dev (build 10809, commit v0.4.0)` and the Vulkan backend. Its workload
and thermal procedure differed from the MTP study:

| Item | Muse follow-up configuration |
|---|---|
| Target | `Muse-Glimmer-30B-KQuant-17GB-Q4_K_M.gguf` |
| Separate drafter | `dflash-Muse-Glimmer-30B-Q4_K_M.gguf` |
| Captured Vulkan driver | Mesa 26.2.1, RADV (`RADV STRIX1`); `media-libs/vulkan-loader-1.4.357.0` |
| Running kernel | `7.2.0-pf6`, recorded throughout in-arm telemetry |
| Observed llama threadpool | 12 threads in all eight server instances; no thread-count flag was supplied |
| DFlash options | `--spec-type draft-dflash --spec-draft-n-max 3 -md /path/to/drafter.gguf -ngld 99` |
| Shared server settings | `-dev Vulkan0 -ngl 99 --ctx-size 65536 --parallel 1 -ctk q8_0 -ctv q8_0 -fa on` |
| Request | Temperature 0; 512-token cap; `reasoning_effort: minimal` in `chat_template_kwargs` |
| Input | The same Russian corpus/question at two lengths, verified as 874 and 16,255 input tokens |
| Repetitions | Four blocks with alternating arm order; three requests per arm and input length in each block |
| Power | AC online throughout recorded in-arm samples; `performance` governor; `balanced` platform profile; battery-care cycling allowed around the 80% charge limit |
| Cooldown | CPU Tctl ≤65°C before each arm's server launch; no additional temperature abort during generation; firmware protections unchanged |

For the baseline, the server was restarted without the drafter or speculative
options. Unlike the MTP study's requests, **all 48 Muse responses contained
reasoning as well as answer text**. Each reached the 512-token cap. These are
repeated timing observations on one workload, not 48 independent tasks or an
answer-quality evaluation.

At each input length, reasoning text was identical across both arms and all
repetitions, but answer text differed in **all 24 matched trials** (same block,
input length and repetition). Answer variation also occurred within the
baseline: each arm produced three distinct answers per input length, even
after normalizing whitespace. For a given arm and input length, each
repetition's answer was identical across all four blocks. The capture does not
isolate the cause of these differences. The decode gains therefore do not
demonstrate unchanged answers or quality; textual differences alone do not
establish quality loss either.

Peak device-wide GTT allocation was about **9.1 GiB without speculation versus
12.0 GiB with DFlash**; peak VRAM allocation stayed around 7.9 GiB in both arms.
These are amdgpu accounting peaks during model loading and requests, including
other users of the device—not isolated process totals or a minimum-RAM
requirement. On this integrated GPU, do not add them to process memory figures
as if each represented separate physical RAM. Per-block peaks are in the
[memory CSV](data/muse-dflash-2026-09-09-memory.csv).

The [data and reproduction notes](data/muse-dflash-2026-09-09.md) give the full
captured launch commands, request settings, model hashes, and numeric exports:
48 requests, four arm/input cells, 16 block summaries and eight cache-category
summaries, with medians and observed ranges.

The audit reconciled every request with its saved stream and server-log
timings, checked input and output counts, and confirmed DFlash activation.
Executable, library, and weight hashes matched before and after the run.
These hashes identify the new follow-up; they do not recover the weights or
runtime used by earlier historical measurements.

Telemetry retained 11,668 samples with a maximum sampling gap of 0.542 seconds.
Recorded peaks were 92.5°C CPU Tctl and 99°C on the GPU sensor labelled `edge`.
Throttle-reason flags were not recorded, so temperatures alone establish
neither throttling nor its absence. GPU-client visibility was incomplete;
exclusive GPU use was not proven. Memory bandwidth was not measured.

The [sanitized Muse evidence archive](https://raw.githubusercontent.com/istitov/stuff-benchmarks/d22bc593998930fa6cee4e0340c2555b4b48a284/data/muse-dflash-2026-09-09.tar.7z)
and [methods and verification notes](https://github.com/istitov/stuff-benchmarks/blob/d22bc593998930fa6cee4e0340c2555b4b48a284/docs/FOLLOWUPS.md#muse-dflash)
are published in the signed evidence release. They cover this follow-up
separately from the four-model MTP study.

## Applying the finding

For the measured MTP build, the relevant llama-server options are:

```text
--spec-type draft-mtp --spec-draft-n-max N --spec-draft-p-min P
```

Use the table's `n` and `p` as values to compare with your baseline. The
Gemma runs also supplied the matching drafter with `-md` and requested its
GPU offload with `-ngld 99`. Confirm the supported options with your installed
`llama-server --help`; the model must have the corresponding MTP support.
Compare against a run with no speculation options or separate drafter.

For example, the selected Qwen3.6 setting can be used with this standalone
server command. Replace the model path, confirm that `Vulkan0` is your intended
GPU, and use an unused port with no competing GPU workload:

```sh
llama-server \
  -m /path/to/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf \
  -dev Vulkan0 -ngl 99 --ctx-size 65536 --parallel 1 \
  -ctk q8_0 -ctv q8_0 -fa on \
  --host 127.0.0.1 --port 52700 \
  --spec-type draft-mtp --spec-draft-n-max 1 --spec-draft-p-min 0
```

For the no-speculation baseline, restart with the final three speculative
options omitted and no separate drafter. Keep the same model, prompt, output
ceiling and cache conditions. Temperature zero and `enable_thinking: false`
are request settings, not set by this launch command. Gemma additionally needs
its matching drafter; the Qwen command does not apply to it unchanged.

Optimizing acceptance rate alone would miss the Qwen3.6 result: its selected
arm accepted 77.07% of draft tokens, against 92.14% for the reference, yet
generated faster. These acceptance rates pool tokens across all 24 requests
per configuration: 8,006 accepted / 10,388 proposed for the selected setting,
versus 9,310 / 10,104 for the reference. They are not the equally weighted
context averages used for the speedup percentages. Measure generation time
for the workload you use.

## MTP data and limits

Download the [80-cell results CSV](data/speculative-decoding-2026-09-06.csv).
It contains all five tested configurations per model, actual context sizes,
six-request medians and ranges, and the block/cache splits. The
[data description](data/speculative-decoding-2026-09-06.md) explains the
columns and the retained source records.

The [MTP evidence archive](https://raw.githubusercontent.com/istitov/stuff-benchmarks/d22bc593998930fa6cee4e0340c2555b4b48a284/data/september-mtp-2026-09-06.tar.7z)
and its analysis tools are published at signed commit
[`d22bc59`](https://github.com/istitov/stuff-benchmarks/commit/d22bc593998930fa6cee4e0340c2555b4b48a284).
The [verification instructions](https://github.com/istitov/stuff-benchmarks/blob/d22bc593998930fa6cee4e0340c2555b4b48a284/README.md#verify-and-reproduce-the-calculations)
use Python and 7-Zip to unpack the archive and reproduce the table without
running models. Public logs and manifests are
sanitized derivatives: private filesystem paths are replaced and model-authored
chat-template bodies are omitted, with their hashes retained. Measurements,
the historical corpus, and harness snapshots are unchanged.

The audit reconciled all 480 requests with server logs and regenerated every
published aggregate from them. Recovered Portage records show llama.cpp 0.4.0
with Vulkan, OpenMP and FlexiBLAS enabled, `-O2 -march=znver5 -mtune=znver5`,
CMake `RelWithDebInfo`, and Mesa 26.2.1. The retained llama.cpp source archive
identifies upstream commit
[`5266f24`](https://github.com/ggml-org/llama.cpp/commit/5266f24da75dc449bd56cbed7addb9c8e4a6a73e).
These are recovered **installed-package records**, not a capture of the
executable, loaded libraries or Vulkan driver used by each request.

The run manifests did not record model hashes or complete process-time build
and driver identification. Exact historical execution therefore cannot be
reconstructed from the table alone. Treat absolute token rates as results of
this particular build. Build choices may affect relative gains as well.

The pattern of larger dense-model gains and smaller MoE gains holds for
these four models and quantizations. It does not establish a general rule
for model architectures. Multi-request concurrency, other GPUs, ROCm, CUDA,
and NPU execution were not measured in this comparison.

## See also

Links to the respective model pages on Hugging Face:

- [Qwen3.6-35B-A3B GGUFs](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF)
- [Qwen3.8-27B GGUFs](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF)
- [Gemma-4-26B-A4B QAT GGUFs](https://huggingface.co/unsloth/gemma-4-26B-A4B-it-qat-GGUF)
- [Gemma-4-31B GGUFs](https://huggingface.co/unsloth/gemma-4-31B-it-GGUF)
- [Muse Glimmer-30B target GGUF](https://huggingface.co/meta-models/Muse-Glimmer-30B-GGUF/blob/main/Muse-Glimmer-30B-KQuant-17GB-Q4_K_M.gguf)
- [Muse Glimmer-30B DFlash drafter GGUF](https://huggingface.co/meta-models/Muse-Glimmer-30B-GGUF/blob/main/dflash-Muse-Glimmer-30B-Q4_K_M.gguf)

Please, note: these are model-repository links, not checksum-pinned copies of
the historical weights; the measured filenames are listed above.

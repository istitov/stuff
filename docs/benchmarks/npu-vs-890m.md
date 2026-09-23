# AMD Ryzen AI 300 NPU versus Radeon 890M

## Abstract

This study evaluates single-request LLM inference on the XDNA 2 NPU and
Radeon 890M integrated GPU of an AMD Ryzen AI 9 HX 370 system running Gentoo
Linux. The September 2026 experiment comprises 288 requests across four model
pairs and three input lengths, using FastFlowLM on the NPU and llama.cpp with
Vulkan on the GPU. Models were loaded before request timing began.

Median request duration was 4.9–49.2% lower on the Vulkan backend across all
twelve model/input comparisons. The NPU backend had lower median socket
power in every comparison, but not consistently lower estimated request
energy. It also achieved lower first-answer latency in three longer-context
comparisons. These results characterize the tested runtime, model-format and
hardware configurations; they do not establish an intrinsic NPU/GPU performance
ranking or equivalent answer quality.

## Experimental methods

### Platform and software

The test platform was a Framework 13 equipped with an
[AMD Ryzen AI 9 HX 370](https://www.amd.com/en/products/processors/laptop/ryzen/ai-300-series/amd-ryzen-ai-9-hx-370.html),
from the Ryzen AI 300 series. Throughout this report, **NPU** denotes
FastFlowLM on XDNA 2 and **Vulkan** denotes llama.cpp on Radeon 890M.
The measured Gentoo packages were `sci-ml/fastflowlm` and
`sci-misc/llama-cpp` from the `stuff` overlay.

| Item | Measured configuration |
|---|---|
| Host | Framework 13, Ryzen AI 9 HX 370, XDNA 2 NPU and Radeon 890M (`gfx1150`, Strix Point) |
| Memory | 64 GB (2 × 32 GB) [DDR5-5600 SO-DIMM](https://frame.work/products/ddr5-5600?v=FRANRM0001X2), 5,600 MT/s, dual-channel, 128-bit aggregate data width |
| Bandwidth ceiling | 89.6 GB/s theoretical: 5,600 MT/s × 16 bytes; not a measured rate reserved for either accelerator |
| Runtime | FastFlowLM 1.0.4; llama.cpp package 0.4.0, build 10809 (`v0.4.0`), GNU 16.2.0, Vulkan/RADV; Mesa 26.2.1 |
| Kernel / NPU stack | `7.2.0-pf6`; xdna-driver `2.21.75-r2`, xrt-xdna `2.21.75-r1`, XRT `2.21.75`; reported NPU firmware `1.1.2.64` |
| Serving | Direct backend servers, one at a time; no Lemonade routing overhead; one request at a time |
| Context | 65,536-token allocation on both backends |
| Vulkan settings | `-dev Vulkan0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 12 -tb 12 --parallel 1 --fit off` |
| FLM settings | `--ctx-len 65536 --prefill-chunk-len 4096 --pmode performance`, ASR/embedding/preemption disabled |

Complete launch arguments and selected installed build records are provided
in the [reproduction record](data/npu-vs-890m-2026-09-11.md#reproduction-record).
The configurations represent the measured settings, not the outcome of an
exhaustive tuning study.

Both accelerators use system memory. The DDR transfer rate and channel
configuration therefore form part of the experimental specification.
Firmware DRAM-traffic counters were retained, but sustained memory bandwidth
was not independently measured. Neither a bandwidth bottleneck nor an
accelerator-exclusive share of the theoretical ceiling was established.

### Models and workload

Four model pairs were selected using the closest practical profiles available
for the two runtimes.

| Model | FLM registry profile | Measured Vulkan GGUF |
|---|---|---|
| Qwen3.5-2B | Q4_K, `flm_q4k_high_precision` | `Qwen3.5-2B-Q4_K_M.gguf` |
| Qwen3.5-4B | Q4_K, `flm_q4k_high_precision` | `Qwen3.5-4B-Q4_K_M.gguf` |
| Qwen3.6-35B-A3B | Q4_K, `flm_q4k_high_precision` | `Qwen3.6-35B-A3B-Q4_K_M.gguf` (ordinary, not UD) |
| Gemma-4-E4B-it | Q4_1 | `gemma-4-E4B-it-Q4_1.gguf` |

The pairs match architecture dimensions and shared vocabulary token IDs;
their offline rendered prompt bytes agree. However, exact base-checkpoint
revisions and cross-format tensor equivalence are not established. Nominal
quantization labels do not imply identical tensor precision. The Gemma GGUF
labelled Q4_1, for example, contains several tensor types; its composition is
documented in the [artifact-comparability notes](data/npu-vs-890m-2026-09-11.md#artifact-comparability).
The common context allocation also does not establish identical KV-cache
layouts: llama.cpp used f16 K/V, while FLM exposes bf16 accessors without an
independently established internal layout or precision.

The workload used one fixed Russian corpus and an analytical-commentary
instruction, sized to full rendered inputs of 1,024, 8,192 and 32,768 tokens.
Generation used temperature zero, neutral repetition/frequency/presence
penalties, disabled reasoning and speculation, and no EOS suppression.
Every request evaluated the full prompt: llama.cpp reported zero cached
tokens, and FLM cache-miss/context-clear records were checked.

The target output budget was 256 emitted tokens. All responses reached the
output cap. The Gemma/FLM path required a native cap of 255 for a source-inferred
256 emitted tokens; complete-answer re-tokenization corroborated that count
in the historical audit but did not recover original sampled token IDs.
The [token-accounting notes](data/npu-vs-890m-2026-09-11.md#native-token-accounting)
describe this build-specific adjustment and the limits of its verification.

### Experimental design and operating conditions

The design comprised four model pairs × two backends × three input lengths
× four counterbalanced blocks × three repetitions, giving 288 requests.
Model and context order were rotated, and backend-first order alternated.
Each backend/model used a fresh server in each block. The twelve observations
per model/backend/input cell are therefore repeated timings within four
server runs on one host, not twelve independent workloads.

CPU Tctl was at most 65°C before each server launch. During the experiment,
the CPU governor remained `performance` and the platform profile remained
`balanced`; firmware power and thermal protections were unchanged. AC was
online in every recorded sample. Battery-care charging and discharging
around the configured charge limit were included in the observations.
The pre-launch temperature criterion did not impose an unthrottled operating
condition during inference. Incomplete process visibility also precludes
establishing exclusive accelerator use.

All 288 scheduled requests were retained. The 48 preflight requests and six
separate Gemma diagnostics were excluded from the performance dataset.
No request was excluded from the primary results on the basis of its
observed performance.

### Measurement and analysis

First-answer latency is the client interval from request submission to the
first answer text. Request duration is the interval to stream completion.
Both exclude server startup and model loading. These client-defined intervals
are the primary cross-backend timing measures. Native decode rates are
reported separately because the runtimes use different token-count and timer
boundaries; their ratio is not an isolated hardware speedup.

Power measurements use the same firmware-reported socket domain on both
backends, including CPU/APU consumption rather than only an accelerator rail.
Per-request mean power is time-weighted; estimated socket energy is the
integral over the client request window. The one-second-filtered sensor
samples had a maximum gap of 1.082 s, with bracketing samples for every
request. Integration uses linear interpolation at request boundaries and
the trapezoidal rule. No idle subtraction is applied, and model loading,
cooldown and the post-request idle tail are excluded.

Memory measurements are sampled process RSS and device-wide amdgpu VRAM/GTT
allocation counters. Reported peaks cover loading and all four server runs
per backend/model with the 65,536-token context allocation; they are not
per-request incremental allocations.

Unless stated otherwise, each timing, power or energy value is the median of
twelve request-level observations. Power and energy medians are calculated
independently, so median power multiplied by median duration need not equal
median energy. Block summaries use three-request medians. Observed ranges and
sensitivity analyses are descriptive, not confidence intervals.

## Results

### Request latency

The following table reports median first-answer latency and request duration
in seconds. All inputs underwent full prefill; these are not cached-repeat
measurements.

| Model | Input tokens | NPU first answer (s) | Vulkan first answer (s) | NPU request (s) | Vulkan request (s) |
|---|---:|---:|---:|---:|---:|
| Qwen3.5-2B | 1,024 | 1.14 | 0.66 | 10.89 | 5.95 |
| Qwen3.5-2B | 8,192 | 6.06 | 5.62 | 17.02 | 11.24 |
| Qwen3.5-2B | 32,768 | 27.58 | 28.98 | 42.64 | 35.57 |
| Qwen3.5-4B | 1,024 | 2.50 | 1.65 | 19.82 | 12.39 |
| Qwen3.5-4B | 8,192 | 13.58 | 14.20 | 33.01 | 25.68 |
| Qwen3.5-4B | 32,768 | 63.96 | 72.42 | 90.74 | 86.31 |
| Qwen3.6-35B-A3B | 1,024 | 8.97 | 2.89 | 24.63 | 12.51 |
| Qwen3.6-35B-A3B | 8,192 | 38.24 | 25.28 | 55.69 | 35.49 |
| Qwen3.6-35B-A3B | 32,768 | 159.35 | 152.99 | 183.21 | 165.02 |
| Gemma-4-E4B-it | 1,024 | 2.46 | 1.51 | 24.70 | 12.87 |
| Gemma-4-E4B-it | 8,192 | 14.14 | 12.84 | 40.29 | 24.94 |
| Gemma-4-E4B-it | 32,768 | 72.42 | 67.83 | 112.32 | 82.19 |

Median request duration on Vulkan was 4.9–49.2% lower than on the NPU
backend. Its within-block request median was also lower in all 48 paired
model/input/block comparisons. Conversely, the NPU achieved lower
first-answer latency for Qwen3.5-2B at 32,768 tokens and Qwen3.5-4B at
8,192 and 32,768 tokens. Each of these first-answer differences occurred
in all four blocks. Request duration and first-answer latency therefore
identify different performance trade-offs.

Temperature zero did not ensure identical generated sequences. For example,
Vulkan Qwen3.5-2B produced six distinct answers across its twelve 1,024-token
input requests. The experiment fixes the prompt and target output budget,
not the generated token sequence, and does not measure naturally completed
answers.

### Native decode throughput

Values are median runtime-reported decode rates in tokens per second (t/s),
listed as NPU / Vulkan. The native timer and token-count definitions differ
between runtimes; cross-backend latency comparisons use the client intervals
above rather than ratios of these rates.

| Model | 1,024 input tokens | 8,192 input tokens | 32,768 input tokens |
|---|---:|---:|---:|
| Qwen3.5-2B | 26.53 / 48.33 | 23.50 / 45.31 | 17.05 / 38.62 |
| Qwen3.5-4B | 14.79 / 23.75 | 13.17 / 22.20 | 9.52 / 18.33 |
| Qwen3.6-35B-A3B | 16.35 / 26.49 | 14.59 / 24.95 | 10.68 / 21.16 |
| Gemma-4-E4B-it | 11.59 / 22.42 | 9.82 / 21.08 | 6.43 / 17.78 |

### Socket power and estimated energy

Power values are medians of time-weighted request means; energy values are
medians of independently integrated request windows. Both use the same
firmware socket domain.

| Model | Input tokens | Mean socket power, NPU / Vulkan (W) | Estimated socket energy, NPU / Vulkan (J) |
|---|---:|---:|---:|
| Qwen3.5-2B | 1,024 | 14.07 / 25.28 | 153.5 / 150.7 |
| Qwen3.5-2B | 8,192 | 15.32 / 25.05 | 260.8 / 282.4 |
| Qwen3.5-2B | 32,768 | 16.71 / 25.04 | 713.5 / 891.2 |
| Qwen3.5-4B | 1,024 | 14.24 / 25.06 | 282.0 / 310.8 |
| Qwen3.5-4B | 8,192 | 15.71 / 25.05 | 519.0 / 643.4 |
| Qwen3.5-4B | 32,768 | 16.90 / 25.05 | 1533.9 / 2163.4 |
| Qwen3.6-35B-A3B | 1,024 | 17.41 / 25.05 | 421.3 / 313.4 |
| Qwen3.6-35B-A3B | 8,192 | 20.98 / 25.04 | 1169.8 / 889.4 |
| Qwen3.6-35B-A3B | 32,768 | 22.75 / 25.08 | 4179.1 / 4137.8 |
| Gemma-4-E4B-it | 1,024 | 14.28 / 25.08 | 353.3 / 323.6 |
| Gemma-4-E4B-it | 8,192 | 15.73 / 25.05 | 633.2 / 624.9 |
| Gemma-4-E4B-it | 32,768 | 16.86 / 25.07 | 1893.7 / 2061.0 |

The NPU backend had lower median socket power in all twelve comparisons,
but estimated energy depended on request duration. At 32,768 input tokens,
Qwen3.5-4B required approximately 29% less estimated socket energy on the
NPU despite its longer request duration. At 8,192 tokens, Qwen3.6-35B-A3B
required approximately 32% more. Small differences, including Qwen3.5-2B at
1,024 tokens, Gemma at 8,192 tokens and Qwen3.6-35B-A3B at 32,768 tokens,
do not establish a reliable energy-efficiency ranking.

A transient was observed in the first Vulkan Qwen3.5-2B block: its three
1,024-token input requests averaged 33.1–36.2 W, compared with approximately
25 W in subsequent blocks. Across all twelve requests in that cell, estimated
socket energy ranged from 147.5 to 210.2 J, with a median of 150.7 J. All
observations were retained. The pre-launch temperature criterion did not
produce identical power behavior across blocks.

Shifting both integration boundaries by one second changed the most sensitive
individual energy estimate by 12.8%, for the shortest Vulkan Qwen3.5-2B
request. This boundary-sensitivity result is not a calibrated uncertainty
interval. Some observed request-level energy ranges overlap.

### Memory allocation

| Model | FLM server RSS peak (GiB) | Vulkan-run VRAM peak (GiB) | Vulkan-run GTT peak (GiB) |
|---|---:|---:|---:|
| Qwen3.5-2B | 4.51 | 2.41 | 0.51 |
| Qwen3.5-4B | 7.69 | 5.08 | 0.62 |
| Qwen3.6-35B-A3B | 24.98 | 7.98 | 13.67 |
| Gemma-4-E4B-it | 10.66 | 4.48 | 2.32 |

FLM's allocations were substantially represented in server RSS, whereas
llama.cpp's Vulkan allocations were largely represented in amdgpu counters.
The Vulkan server's per-run RSS peaks were approximately 0.24–0.37 GiB and
did not represent its device allocations. VRAM/GTT counters are device-wide
and include desktop allocations.

These counters measure different, overlapping accounting domains on a
system with shared physical memory. RSS, host-memory changes and GPU
allocations are not additive totals. The results do not establish minimum
RAM requirements or a cross-backend memory-efficiency ranking.

### Between-block variability and thermal behavior

For each model/backend/input cell, the range of its four request-duration
block medians was expressed relative to the smallest median. The maximum
relative range across cells was 4.0% (rounded). Excluding the first request
of each server run in a sensitivity analysis left Vulkan's pooled request
median lower in all twelve comparisons. The primary tables retain those
requests. This observed timing stability does not establish equivalent energy
stability or thermal isolation.

Peak recorded CPU Tctl was 95.5°C during the FLM MoE run, including loading.
The firmware CPU thermal-residency counter increased within sampled portions
of 121 of 144 NPU requests and two of 144 Vulkan requests. The experiment
therefore does not represent uniformly unthrottled execution. GPU/SoC thermal
and PROCHOT counters did not increase in the retained samples, while Vulkan's
SPL power-limit counter increased in every server run. These counters use
cumulative firmware cycles, not percentages, and do not quantify the resulting
performance loss.

## Discussion and limitations

The measurements compare complete serving configurations, including runtime,
model representation, host processing and accelerator execution. They do not
isolate the relative capabilities of the NPU and GPU silicon. Differences in
tensor precision, unverified checkpoint identity, KV-cache implementation,
thermal residency and power limits constrain hardware-level attribution.

The workload comprises repeated timings of one Russian-language corpus and
instruction on one host. Answer quality, factual accuracy, tool-use reliability
and cross-format quality equivalence were not evaluated. Neither a nominal
quantization label nor a fixed output cap establishes comparable answer
quality. No model-quality ranking is supported by these measurements.

Socket-power integrals are not external wall-energy or battery-life
measurements. The IPU-only rail does not represent the complete cost of FLM;
socket and APU domains overlap and cannot be summed. Firmware Psys is retained
in the public telemetry but is not treated as a calibrated whole-laptop
measurement. Separate prefill/decode energy is not reported because differing
timer definitions and sensor filtering prevent reliable phase attribution.

The findings apply to the tested HX 370 system and configurations, not the
entire Ryzen AI 300 family. Other hardware, runtime versions, memory
configurations and operating conditions may produce different results.
ROCm, CUDA, concurrent serving, speculative decoding, bilingual workloads
and battery operation were outside the experiment. Neither backend was
exhaustively optimized, and the study does not compare Gentoo overlays.

## Conclusion

Under the tested single-request conditions, llama.cpp with Vulkan on Radeon
890M consistently achieved lower capped-response duration than FastFlowLM
on the XDNA 2 NPU. FastFlowLM exhibited lower socket power and, for selected
model/input combinations, lower first-answer latency and estimated request energy.
These outcomes distinguish response duration, first-answer latency and energy
as separate evaluation criteria; none alone establishes a general advantage
for an accelerator architecture.

## Data availability and reproducibility

The [24-cell CSV](data/npu-vs-890m-2026-09-11.csv),
[96 block summaries](data/npu-vs-890m-2026-09-11-blocks.csv) and
[288 request observations](data/npu-vs-890m-2026-09-11-requests.csv) retain
unrounded measurements and descriptive ranges. Column definitions, artifact
metadata and diagnostic details are documented in the
[supporting data notes](data/npu-vs-890m-2026-09-11.md).

The [sanitized NPU/iGPU evidence archive](https://raw.githubusercontent.com/istitov/stuff-benchmarks/d600c05b6b1bdd69ce6dc2135faaba61c38f2d89/data/npu-vs-890m-2026-09-11.tar.7z)
and [analysis and verification methods](https://github.com/istitov/stuff-benchmarks/blob/d600c05b6b1bdd69ce6dc2135faaba61c38f2d89/docs/FOLLOWUPS.md#npu-versus-radeon-890m)
are pinned to signed commit `d600c05`. The evidence is separate from the MTP
and Muse DFlash datasets. Verification reconciles all 288 request streams
with saved records, checks token/cache accounting and artifact fingerprints,
and regenerates the published tables. Recomputing the calculations does not
authenticate the original capture or reconstruct omitted runtime state;
weights, tokenizers and model-authored templates are not distributed.

## References and setup guides

- [FastFlowLM](https://github.com/ROCm/FastFlowLM)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Ryzen AI NPU setup on Gentoo](../guides/ryzen-ai-npu.md)
- [llama.cpp, Ollama and llama-swap setup](../guides/llama-setup.md)
- [GPU hardware identification](../guides/hardware-targets.md)

Model repositories on Hugging Face:

- [FastFlowLM native model collection](https://huggingface.co/FastFlowLM)
- [Qwen3.5-2B GGUF](https://huggingface.co/unsloth/Qwen3.5-2B-GGUF)
- [Qwen3.5-4B GGUF](https://huggingface.co/unsloth/Qwen3.5-4B-GGUF)
- [Qwen3.6-35B-A3B ordinary Q4_K_M](https://huggingface.co/Abiray/Qwen3.6-35B-A3B-Q4_K_M-GGUF)
- [Gemma-4-E4B-it GGUF](https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF)

These links identify model repositories, not checksum-pinned copies of the
measured weights. The model table lists measured filenames; the evidence
archive supplies captured artifact fingerprints and provenance limits.

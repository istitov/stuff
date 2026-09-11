# FastFlowLM NPU versus Radeon 890M

With the model already loaded and one request at a time on this Framework 13,
**llama.cpp Vulkan finished the capped responses sooner in all twelve
model/context comparisons**. FastFlowLM on the NPU drew less
socket power in every comparison, but its longer runtimes sometimes consumed
more estimated socket energy. The NPU also produced the first answer sooner
in three longer-context cases, despite finishing the response later.

These are **September 2026 measurements** of four model pairs on Gentoo:
288 requests, with twelve timing observations per model/backend/input length.
They compare the selected runtime and model-format combinations, not isolated
NPU versus GPU silicon or equal model quality.

The [sanitized NPU/iGPU evidence archive](https://raw.githubusercontent.com/istitov/stuff-benchmarks/d600c05b6b1bdd69ce6dc2135faaba61c38f2d89/data/npu-vs-890m-2026-09-11.tar.7z)
and [methods and verification notes](https://github.com/istitov/stuff-benchmarks/blob/d600c05b6b1bdd69ce6dc2135faaba61c38f2d89/docs/FOLLOWUPS.md#npu-versus-radeon-890m)
are published in the signed evidence release, separately from the MTP and
Muse DFlash datasets.

For setup, see [the Ryzen AI NPU guide](../guides/ryzen-ai-npu.md),
[llama.cpp, Ollama and llama-swap](../guides/llama-setup.md), and
[checking GPU hardware](../guides/hardware-targets.md). The measured packages
are `sci-ml/fastflowlm` and `sci-misc/llama-cpp` from `stuff`. This study does
not compare overlays, ROCm, speculative decoding, or concurrent serving.

## How long do you wait?

Each value is the median of twelve requests: four counterbalanced blocks,
with three repetitions at each input length. First-answer time ends when the
client receives the first answer text. Request time ends at the completed
stream and excludes model loading. Every request evaluates the full prompt;
these are **not cached-repeat timings**.

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

Vulkan's median request-time reduction ranges from **4.9% to 49.2%**. Its
within-block request median was lower in all 48 paired comparisons. However,
the NPU's first-answer advantage for Qwen2B at 32k and Qwen4B at 8k/32k also
appeared in every block. “Finishes sooner” and “starts answering sooner” are
different findings.

The same prompt is repeated at each length, not twelve independent tasks.
All responses reached the output cap; these times do not measure a naturally
completed answer, factual accuracy, or tool-use success.
The comparison fixes the prompt and emitted-token budget, **not the generated
token sequence**. Temperature zero did not guarantee identical text across
repetitions: Vulkan Qwen2B produced six distinct answers in its twelve 1k
requests. Different generated sequences remain part of this serving comparison,
not an identical-token computation benchmark.

## Generation speed in t/s

These are median **native reported decode rates**, in tokens per second.
Each cell lists **NPU / Vulkan**. The runtimes use different timer and token-
count boundaries, explained below: do not divide these columns to obtain a
hardware speedup. Use the client timing table for the cross-backend comparison.

| Model | 1,024 input tokens | 8,192 input tokens | 32,768 input tokens |
|---|---:|---:|---:|
| Qwen3.5-2B | 26.53 / 48.33 | 23.50 / 45.31 | 17.05 / 38.62 |
| Qwen3.5-4B | 14.79 / 23.75 | 13.17 / 22.20 | 9.52 / 18.33 |
| Qwen3.6-35B-A3B | 16.35 / 26.49 | 14.59 / 24.95 | 10.68 / 21.16 |
| Gemma-4-E4B-it | 11.59 / 22.42 | 9.82 / 21.08 | 6.43 / 17.78 |

## Lower watts do not always mean lower energy

The table compares the **same firmware-reported socket-power domain** on
both backends. It includes CPU/APU consumption, not just the NPU. Each power
value is the median of twelve time-weighted request means; each energy value
is the median of twelve independently integrated request windows.

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

For example, Qwen4B at 32k traded a slightly longer request for a roughly
29% lower estimated socket integral on FLM. Qwen35B at 8k did the opposite:
FLM drew fewer watts but took long enough to use roughly 32% more estimated
socket energy. Near-ties such as Qwen2B at 1k, Gemma at 8k and Qwen35B at 32k
do not establish an efficiency winner.

The pooled medians hide a power transient. In the first Qwen2B Vulkan block,
the three 1k requests averaged **33.1–36.2 W**, versus roughly 25 W in later
blocks. Across all twelve, estimated socket energy ranged from **147.5 to
210.2 J**, with a 150.7 J median. These observations are retained, not removed
as outliers. The temperature cooldown did not ensure identical power behavior;
the request-time stability below must not be read as energy stability.

These are **not wall-power or battery-life measurements**. The sensor has a
one-second filter; sampling gaps reached 1.082 s. All request windows had
bracketing samples, with linear boundary interpolation and trapezoidal
integration. Shifting both boundaries by one second changed the most
sensitive individual estimate by 12.8%, on the shortest Vulkan Qwen2B
request. That sensitivity check is not a calibrated error bar, and some
observed request ranges overlap.

No idle subtraction is applied. Model loading, cooldown and the post-request
idle tail are excluded from these integrals. The recorded IPU-only rail is
not FLM's total cost; socket/APU readings overlap and must not be summed.
The firmware Psys field is retained in the public raw telemetry but is not
used as a calibrated whole-laptop measurement. Separate prefill/decode energy
is not reported because the timers differ and filtering blurs phase boundaries.

## Memory: compare the accounting domains

FLM holds substantial memory in its server process. Vulkan places much of
its allocation in amdgpu-managed memory, so a small `llama-server` RSS does
not imply a small model footprint.

| Model | FLM server RSS peak (GiB) | Vulkan-run VRAM peak (GiB) | Vulkan-run GTT peak (GiB) |
|---|---:|---:|---:|
| Qwen3.5-2B | 4.51 | 2.41 | 0.51 |
| Qwen3.5-4B | 7.69 | 5.08 | 0.62 |
| Qwen3.6-35B-A3B | 24.98 | 7.98 | 13.67 |
| Gemma-4-E4B-it | 10.66 | 4.48 | 2.32 |

These are maximum sampled values across loading and all four server runs
per backend/model, with a 65,536-token context allocation. The Vulkan server's
per-run RSS peaks were only about 0.24–0.37 GiB; its device allocations are
not represented by that number. VRAM/GTT figures are host-wide and include
desktop allocations. The iGPU shares system RAM; RSS, host-memory changes
and GPU allocations are overlapping accounting views, not additive totals.
This table does not establish a minimum RAM requirement or a memory winner.

## Sustained behavior and thermals

For each model/backend/input cell, the largest of its four request-time block
medians was at most 4.0% above the smallest. That is an observed range on this
workload, not a confidence interval or proof of perfect thermal isolation.
The [block and request tables](data/npu-vs-890m-2026-09-11.md) expose the
grouping and observed ranges. The twelve observations per cell are three
requests within each of four server runs on one host, not twelve independent
workloads. As a sensitivity check only, excluding the first request of each
server run leaves Vulkan's pooled request median lower in all twelve cells;
the published results still include those requests.

The CPU cooled to at most 65°C before each server launch. Peak recorded Tctl
was 95.5°C, in the FLM MoE run including loading. More importantly, the firmware
CPU thermal-residency counter increased within sampled portions of 121 of
144 NPU requests and two of 144 Vulkan requests. This was not an unthrottled
experiment. GPU/SoC thermal and PROCHOT counters did not increase in the
retained samples; Vulkan's SPL power-limit counter increased in every server
run. Counter units are cumulative firmware cycles, not percentages, and do
not quantify the lost performance.

AC remained online in all recorded samples. Battery-care charging/discharging
around the charge limit was allowed and retained. The CPU governor stayed
`performance`, the platform profile stayed `balanced`, and no firmware power
or thermal protections were changed. Process visibility was incomplete, so
the checks do not prove exclusive accelerator use.

## Workload and software

| Item | Measured configuration |
|---|---|
| Host | Framework 13, Ryzen AI 9 HX 370, XDNA 2 NPU and Radeon 890M (`gfx1150`, Strix Point) |
| Memory | 64 GB (2 × 32 GB) [DDR5-5600 SO-DIMM](https://frame.work/products/ddr5-5600?v=FRANRM0001X2), 5,600 MT/s, dual-channel, 128-bit aggregate data width |
| Bandwidth ceiling | 89.6 GB/s theoretical: 5,600 MT/s × 16 bytes; not a measured rate reserved for either accelerator |
| Runtime | FastFlowLM 1.0.4; llama.cpp package 0.4.0, build 10809 (`v0.4.0`), GNU 16.2.0, Vulkan/RADV; Mesa 26.2.1 |
| Kernel / NPU stack | `7.2.0-pf6`; xdna-driver `2.21.75-r2`, xrt-xdna `2.21.75-r1`, XRT `2.21.75`; reported NPU firmware `1.1.2.64` |
| Serving | Direct isolated servers, one at a time; no Lemonade routing overhead; one request at a time |
| Context | 65,536-token allocation on both backends; three full-input lengths: 1,024 / 8,192 / 32,768 |
| Vulkan settings | `-dev Vulkan0 -ngl 99 -fa on -ctk f16 -ctv f16 -b 2048 -ub 512 -t 12 -tb 12 --parallel 1 --fit off` |
| FLM settings | `--ctx-len 65536 --prefill-chunk-len 4096 --pmode performance`, ASR/embedding/preemption disabled |
| Input | One fixed Russian corpus and analytical-commentary instruction, sized to each input length |
| Generation | Temperature zero, neutral repetition/frequency/presence penalties, reasoning off, no speculation or EOS suppression |
| Output | Target 256 emitted tokens, with the explicitly audited Gemma/FLM counter correction below |
| Cache | Full prefill on every request; llama.cpp cache count zero and FLM cache-miss/context-clear logs checked |
| Repetition | Four blocks, rotated model/context order, alternating backend-first order, three repetitions per cell |

The [reproduction record](data/npu-vs-890m-2026-09-11.md#reproduction-record)
contains the complete captured launch arguments, selected installed build
records and their limits. These are the measured settings, not a claim that
either backend was exhaustively tuned.

Both backends use system memory, so DDR rate and channel configuration matter
when comparing other machines. Firmware DRAM-traffic counters were retained,
but this was not an isolated memory-bandwidth benchmark. No bandwidth bottleneck
or accelerator-exclusive share of the theoretical ceiling was established.

### Model pairs and token accounting

| Model | FLM registry profile | Measured Vulkan GGUF |
|---|---|---|
| Qwen3.5-2B | Q4_K, `flm_q4k_high_precision` | `Qwen3.5-2B-Q4_K_M.gguf` |
| Qwen3.5-4B | Q4_K, `flm_q4k_high_precision` | `Qwen3.5-4B-Q4_K_M.gguf` |
| Qwen3.6-35B-A3B | Q4_K, `flm_q4k_high_precision` | `Qwen3.6-35B-A3B-Q4_K_M.gguf` (ordinary, not UD) |
| Gemma-4-E4B-it | Q4_1 | `gemma-4-E4B-it-Q4_1.gguf` |

These are closest available profiles, not precision-matched artifacts.
Even the Gemma GGUF labelled Q4_1 contains mixed tensor types: approximately
48.7% of stored tensor bytes are Q4_1, 38.3% Q5_K, 7.5% Q4_K and the rest
BF16/F32. These percentages describe storage bytes, not parameter counts or
measured quality. A nominal quantization label does not specify every tensor's
precision or establish equivalence with the native FLM conversion.

The reviewed pairs match architecture dimensions and shared vocabulary token
IDs, and their offline rendered prompt bytes agree. Exact base checkpoint
revisions and cross-format tensor equivalence are not established. The common
context allocation also does not prove identical KV layouts: llama.cpp used
f16 K/V; FLM exposes bf16 accessors, but its internal layout/precision was not
independently established.

FLM's Qwen path defers four template-control tokens from its prefill count.
Its reported prompt counts are therefore 1,020 / 8,188 / 32,764, while the
full rendered inputs remain 1,024 / 8,192 / 32,768. This is not cached input or
a shorter corpus. Its native decode timer also includes deferred-control work
and excludes work covered by the client timer. llama.cpp's native decode
rate uses 255 timed steps for a reported 256-token response.

Gemma/FLM emits a first token outside its native completion counter. A separate
six-request diagnostic verified requesting a native cap of **255** for a
source-inferred **256 emitted tokens**; all 36 main Gemma/FLM answers also
re-tokenize to 256. Native counters remain unchanged. Re-tokenization
corroborates the source explanation but is not a capture of original sampled
token IDs. The adjustment applies only to the tested FLM build and Gemma path,
not as a general recommendation to change `max_tokens`.

## Data and next experiments

The [24-cell CSV](data/npu-vs-890m-2026-09-11.csv) contains unrounded medians
and observed minima/maxima. The [96 block summaries](data/npu-vs-890m-2026-09-11-blocks.csv)
and [288 request rows](data/npu-vs-890m-2026-09-11-requests.csv) preserve the
within-server repetitions. The [data description](data/npu-vs-890m-2026-09-11.md)
defines the fields; ranges are descriptive, not confidence intervals.
The local audit reconciled all 288 raw streams and saved log ranges, checked
counts/cache behavior, and verified artifact stability. Every server stopped
cleanly. The 48 preflight requests and six Gemma diagnostics are excluded.

This study does **not** test whether NPU models are weaker. Historical
tool-use differences motivate a separate quality and reliability experiment;
neither these capped answers nor nominal quantization labels resolve it.
Bilingual coverage, concurrent workloads, best-settings speculation, and
battery-life testing are also outside this comparison.

## See also

- [FastFlowLM](https://github.com/ROCm/FastFlowLM)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)

Links to the respective model pages on Hugging Face:

- [FastFlowLM native model collection](https://huggingface.co/FastFlowLM)
- [Qwen3.5-2B GGUF](https://huggingface.co/unsloth/Qwen3.5-2B-GGUF)
- [Qwen3.5-4B GGUF](https://huggingface.co/unsloth/Qwen3.5-4B-GGUF)
- [Qwen3.6-35B-A3B ordinary Q4_K_M](https://huggingface.co/Abiray/Qwen3.6-35B-A3B-Q4_K_M-GGUF)
- [Gemma-4-E4B-it GGUF](https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF)

Please, note: these are model-repository links, not checksum-pinned copies of
the measured weights. The filenames are listed above; the
[published evidence](data/npu-vs-890m-2026-09-11.md) supplies the captured artifact
hashes and explains the provenance limits. The weights themselves are not
distributed.

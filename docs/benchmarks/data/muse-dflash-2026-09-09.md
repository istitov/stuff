# Muse Glimmer-30B DFlash: data and reproduction notes

These numeric exports describe the 48-request September 2026 Muse follow-up
in [Speculative decoding on Radeon 890M](../speculative-decoding-on-890M.md#muse-glimmer-30b-dflash-follow-up).
They are separate from the four-model MTP study and all excluded preflights
or stopped attempts. No slow observation was removed.

The [sanitized Muse evidence archive](https://raw.githubusercontent.com/istitov/stuff-benchmarks/d600c05b6b1bdd69ce6dc2135faaba61c38f2d89/data/muse-dflash-2026-09-09.tar.7z)
contains submitted prompts and requests, streams, server logs, telemetry and
artifact fingerprints. The [verification instructions](https://github.com/istitov/stuff-benchmarks/blob/d600c05b6b1bdd69ce6dc2135faaba61c38f2d89/docs/FOLLOWUPS.md#verification)
recompute these tables from the retained records without running models.
Python 3.11+ and [7-Zip with PPMd support](https://github.com/istitov/stuff-benchmarks/blob/d600c05b6b1bdd69ce6dc2135faaba61c38f2d89/README.md#dataset-archives-and-7-zip)
are required; extraction is automatic. These links pin signed commit
`d600c05`, not the moving repository branch.

The public records are sanitized derivatives, not a complete unchanged capture;
weights and model-authored templates are omitted. Recomputing the calculations
does not authenticate the original capture or reproduce the historical runtime.
See the [privacy and evidence limits](https://github.com/istitov/stuff-benchmarks/blob/d600c05b6b1bdd69ce6dc2135faaba61c38f2d89/docs/PRIVACY.md)
and [license boundaries](https://github.com/istitov/stuff-benchmarks/blob/d600c05b6b1bdd69ce6dc2135faaba61c38f2d89/NOTICE.md).

## Downloads and grouping

| File | Rows | Meaning |
|---|---:|---|
| [Requests](muse-dflash-2026-09-09-requests.csv) | 48 | One row per completed request |
| [Arm/input cells](muse-dflash-2026-09-09.csv) | 4 | Median and range of 12 requests per arm and input length |
| [Blocks](muse-dflash-2026-09-09-blocks.csv) | 16 | Median and range of three requests per block, arm and input length |
| [Cache categories](muse-dflash-2026-09-09-cache-strata.csv) | 8 | Median and range of four first requests or eight cached repeats per arm and input length |
| [Device memory](muse-dflash-2026-09-09-memory.csv) | 8 | Allocation peaks during each block/arm's server loading and requests |

For the three timing-summary files, `n` is the number of requests summarized.
An unsuffixed timing/rate column is its median; `_min` and `_max` are observed
request-level extrema, not confidence intervals. Each metric is summarized
separately, so medians of timing components need not add exactly.

Decode speedup is DFlash's cell median divided by the matching baseline cell
median, not the median of paired speedups. Block comparisons use the same
ratio within each block. First-in-context and cached-repeat observations are
not interchangeable, and the repeated requests are not independent tasks.

The article's within-block speedup ranges are the minimum and maximum of the
four block-specific ratios of median decode rates. For the leave-one-block-out
check, omit all requests from one block in both arms and divide the remaining
arm medians, using nine requests per arm and input length. Repeat for each of
the four blocks. At 16,255 tokens these ratios span 1.49–1.86×. This measures
sensitivity to the included blocks; it is not a confidence interval or a
reason to exclude a block from the published result. All requests remain in
the main table and CSVs.

### Request fields

| Column | Meaning |
|---|---|
| `block` | Zero-based block, 0–3 |
| `arm` | `nospec`: no drafter or speculation options; `n3`: DFlash with maximum draft length 3 |
| `input_tokens` | Actual full input length, including cached tokens: 874 or 16,255 |
| `iteration` | Zero-based repetition, 0–2, within each block/arm/input group |
| `cache_stratum` | `first_in_context` for repetition 0; `cached_repeat` for 1 and 2 |
| `evaluated_input_tokens` | Newly evaluated prompt tokens reported by the server |
| `cached_input_tokens` | Reused prompt tokens; added to the evaluated count to obtain full input length |
| `output_tokens` | Server-reported generated tokens, 512 for every request, including reasoning and answer |
| `native_decode_tps` | Server-reported decode tokens/s; this build times 511 decode steps for the 512 emitted tokens, consistently in both arms |
| `prefill_s` | Server-reported prompt-processing duration in seconds, not a client first-token timer |
| `first_visible_s` | Client elapsed time from sending the request to its first reasoning or answer text; reasoning came first in every response |
| `first_answer_s` | Client elapsed time from sending the request to the first answer text, not the first reasoning text |
| `reasoning_to_answer_s` | Per-request `first_answer_s - first_visible_s`; a streamed-output interval, not a pure model-compute timer |
| `wall_s` | Client elapsed time from sending the request to the completed stream; excludes server startup and model loading |

Every response stopped at the 512-token cap (`finish_reason=length`), so neither
wall time nor throughput measures completion of a natural answer. Reasoning
text was identical for a given input length across all requests; answer text
differed in all 24 block/input/repetition-matched comparisons. Quality was not
scored, and faster decoding does not establish answer equivalence.

Within each arm and input length, the three repetitions also produced three
distinct answers, even after collapsing whitespace and trimming leading and
trailing whitespace. Each repetition's answer was identical across the four
blocks for that arm and input length. Thus variation was present without
DFlash too; these observations do not isolate its cause or measure quality.

The request exports deliberately omit prompts, answer/reasoning text, absolute
timestamps, host paths and process identifiers. The output-text comparison can
be repeated from the archived streams, but not from these numeric tables alone.

### Memory fields

`vram_peak_gib` and `gtt_peak_gib` are the maxima of the sampled amdgpu
`mem_info_vram_used` and `mem_info_gtt_used` counters for each block/arm.
Bytes are divided by 2³⁰ to obtain GiB. Sampling covers loading and all six
requests in that server instance; it does not isolate one input length or
request. The two maxima need not occur at the same instant.

These device-wide counters include other GPU users. GTT allocation peaks were
9.09–9.15 GiB without speculation and 11.99–12.02 GiB with DFlash; VRAM peaks
were about 7.9 GiB in both. They are not isolated process totals, additional
physical RAM to add to RSS, or minimum-RAM requirements. This integrated GPU
shares system memory. Actual memory bandwidth was not measured.

## Captured software and launch settings

The host was the Framework 13 / Ryzen AI 9 HX 370 / Radeon 890M described in
the main article, with 64 GB dual-channel DDR5-5600. Captured software records
identify `sci-misc/llama-cpp-0.4.0::stuff`, Mesa 26.2.1 (`RADV STRIX1`), and
`media-libs/vulkan-loader-1.4.357.0::gentoo`. The runtime reported
`0.4.0-dev (build 10809, commit v0.4.0)`; `v0.4.0` is a revision label, not a
cryptographic source-commit identifier. Executable, library and model hashes
matched before and after the run.

All 11,668 in-arm telemetry samples record running kernel `7.2.0-pf6`, CPU
governor `performance`, and platform profile `balanced`. The server logs record
a 12-thread llama threadpool in all eight instances. No thread-count flag was
passed in the launch commands; this is an observed runtime setting, not an
explicitly supplied option or a guarantee of the same setting on another host.

The Portage record has Vulkan, OpenMP and FlexiBLAS enabled, with ROCm and CUDA
disabled. Its C/C++ flags were
`-O2 -pipe -march=znver5 -mtune=znver5 -mno-rdrnd -mno-rdseed`, and linker flags
were `-Wl,-O1 -Wl,--as-needed -Wl,-z,pack-relative-relocs`. These are selected
package records, not a complete compiler-invocation archive.

The following commands reproduce the saved argument lists with only the model
paths parameterized. They describe the measured build, not guaranteed options
for a later release. Set `TARGET_GGUF` and `DRAFTER_GGUF` to your local files,
confirm that `Vulkan0` is the intended GPU, and use an unused local port. Run
only one arm at a time; stop its server before starting the other.

No-speculation baseline:

```sh
/usr/bin/llama-server -m "$TARGET_GGUF" -dev Vulkan0 -ngl 99 \
  --ctx-size 65536 --host 127.0.0.1 --port 52720 --parallel 1 \
  -ctk q8_0 -ctv q8_0 -fa on --alias muse-followup
```

DFlash n=3:

```sh
/usr/bin/llama-server -m "$TARGET_GGUF" -dev Vulkan0 -ngl 99 \
  --ctx-size 65536 --host 127.0.0.1 --port 52720 --parallel 1 \
  -ctk q8_0 -ctv q8_0 -fa on --spec-draft-n-max 3 \
  -md "$DRAFTER_GGUF" -ngld 99 --spec-type draft-dflash \
  --alias muse-followup
```

The inference process inherited the environment; a complete environment
snapshot was not captured. These commands alone do not reproduce that state.
The saved server records confirmed the expected backend and DFlash activation,
with no draft tokens in the baseline.

The request body sent to `/v1/chat/completions` used the following settings.
The content below is a placeholder, **not** the benchmark prompt:

```json
{
  "model": "muse-followup",
  "messages": [{"role": "user", "content": "<reviewed prompt>"}],
  "max_tokens": 512,
  "temperature": 0,
  "stream": true,
  "cache_prompt": true,
  "timings_per_token": true,
  "chat_template_kwargs": {"reasoning_effort": "minimal"}
}
```

`reasoning_effort: minimal` did not disable reasoning. The same saved Russian
corpus/question was sized to two inputs, with 874 and 16,255 tokens verified
by the runtime's input-count endpoint and every measured request's counters.
Input counting did not warm the KV cache.

Four blocks alternated arm order: baseline/DFlash, DFlash/baseline,
baseline/DFlash, DFlash/baseline. Each arm used a fresh server, with three short
requests followed by three long requests. The first short request had zero
cached tokens; the first long request followed the short requests and reused
49 tokens, so it was not completely cold. Repeats reused 869 or 16,250 tokens,
leaving five to evaluate. No timing observation was replaced or trimmed.

The CPU Tctl gate was ≤65°C before each server launch, not before every
request; temperatures were recorded during generation without an additional
software temperature abort. Firmware protections were unchanged. The CPU
governor was `performance`, AC stayed online in all recorded in-arm samples,
and operator-approved battery-care cycling around the 80% charge limit was
allowed. Explicit throttle-reason flags were not captured, and exclusive GPU
use was not proven. These conditions matter when comparing a rerun.

### Model identity

SHA-256 values were captured for these files and matched again after the run.
The Hugging Face links are convenience links; the repository's `main` branch
can move.

| Artifact | Filename and SHA-256 |
|---|---|
| [Target](https://huggingface.co/meta-models/Muse-Glimmer-30B-GGUF/blob/main/Muse-Glimmer-30B-KQuant-17GB-Q4_K_M.gguf) | `Muse-Glimmer-30B-KQuant-17GB-Q4_K_M.gguf`<br>`4cc57c0f51040a226e5a72cc47b7613f7772950e460a665f7083de89f183f60e` |
| [DFlash drafter](https://huggingface.co/meta-models/Muse-Glimmer-30B-GGUF/blob/main/dflash-Muse-Glimmer-30B-Q4_K_M.gguf) | `dflash-Muse-Glimmer-30B-Q4_K_M.gguf`<br>`b2e808bf656086fe86bd0d0bd990f01d33e377537a07c02d45371517c8b264ef` |

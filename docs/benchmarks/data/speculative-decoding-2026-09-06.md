# Speculative-decoding data: 6 September 2026

[Return to the study](../speculative-decoding-on-890M.md).

The [CSV](speculative-decoding-2026-09-06.csv) has 80 rows: four models,
five configurations, and four input lengths. Each row summarizes six requests
from two blocks. The table contains 480 requests in total.

| Column | Meaning |
|---|---|
| `model` | Model label; exact target and drafter filenames are listed in the study. |
| `arm` | Tested configuration: `nospec`, or `nN-pPPP` for draft length and probability threshold (`p050` means 0.50). |
| `nominal_tokens` | Requested prompt-size label; do not use it as the measured input length. |
| `actual_context_tokens` | Full measured input length, including cached tokens. |
| `n` | Requests included in this cell. |
| `decode_tps_median`, `decode_tps_min`, `decode_tps_max` | Median and observed range of server-reported generated tokens per second. |
| `block0_decode_median`, `block1_decode_median` | Three-request median within each block. |
| `first_iteration_decode_median` | Median of the two initial requests, one per block; these are not necessarily cache-free. |
| `cached_repeat_decode_median` | Median of the four heavily cached repeats. |
| `generated_tokens` | Output-token count; constant within each model in this experiment. |
| `reasoning_chars_median` | Recorded reasoning characters; zero throughout this four-model selection. |

Values retain their calculation precision for reanalysis, not as a claim of
measurement accuracy. Use sensible rounding when presenting them.

## Source runs

| Model | Run identifier |
|---|---|
| Qwen3.6-35B-A3B | `20260906-130122-Qwen3.6-35B-A3B` |
| Qwen3.8-27B | `20260906-143453-Qwen3.8-27B` |
| Gemma-4-26B-A4B | `20260906-194520-Gemma-4-26B-A4B-it` |
| Gemma-4-31B | `20260906-210820-Gemma-4-31B-it` |

The [public evidence directory](https://github.com/istitov/stuff-benchmarks/tree/b3651b931bf851dc3b5cf56d498fcc39927f7a8d/data/september-mtp-2026-09-06)
contains `iterations.jsonl`, `manifest.json`, `bench.py.snapshot`, server logs,
and saved `/props` responses for each run. Logs and path-bearing records are
sanitized derivatives; model-authored chat-template bodies are omitted with
fingerprints retained. The measurements, corpus, and harness snapshots retain
their original contents. `SANITIZATION.json` records the transformations and
original/public hashes; `SHA256SUMS` covers the public files.
The CSV was regenerated from those request records during the 9 September
audit. It excludes preliminary runs and the rejected Gemma reasoning-only run.

For each arm and input length, take the median decode rate of the six
requests. Divide by the corresponding reference median, subtract one, and
multiply by 100. The headline result averages those four percentages equally.

The source corpus SHA-256 is
`273f44d47dcf7379ca7630533ce6684685b06606d632be7c5174a86668580e0c`.
The recorded harness hash prefixes are `4f6e7754f7c816b1` for Qwen3.6 and
`13e2ad7a9fc7a189` for the other three runs. The audit verified both against
the saved snapshots. A corpus or harness hash does not identify the model
weights or runtime build; those provenance limits are described in the study.

The [analysis and verification instructions](https://github.com/istitov/stuff-benchmarks/blob/b3651b931bf851dc3b5cf56d498fcc39927f7a8d/README.md#verify-and-reproduce-the-calculations)
reproduce every CSV field without inference. See the
[corpus attribution](https://github.com/istitov/stuff-benchmarks/blob/b3651b931bf851dc3b5cf56d498fcc39927f7a8d/docs/CORPUS.md)
and [license boundaries](https://github.com/istitov/stuff-benchmarks/blob/b3651b931bf851dc3b5cf56d498fcc39927f7a8d/NOTICE.md)
before redistributing the material. These links are pinned to the published
commit rather than the moving repository branch.

# Local AI benchmarks

These measurements show how runtimes packaged by `stuff` behaved on the
maintainer's hardware. Each study records its workload and software snapshot
so that readers can judge whether the result applies to their own setup.

| Study | Hardware and backend | Question |
|---|---|---|
| [Speculative decoding](speculative-decoding-on-890M.md) | Radeon 890M, llama.cpp Vulkan | How much does MTP improve generation speed, and do model-specific settings help? |

The [benchmark evidence repository](https://github.com/istitov/stuff-benchmarks)
holds sanitized run records, analysis tools, checksums, and attribution.
Each study links to the exact evidence commit used for its results.

Start with [the hardware guide](../guides/hardware-targets.md) to identify
your GPU, and [the llama setup guide](../guides/llama-setup.md) to build and
run the corresponding backend. The [AI-stack overview](../ai-stack.md) maps
the other packaged runtimes and accelerator paths.

## Reading the results

**Prefill** processes the input prompt. **Decode** generates the response.
A faster decode rate need not mean a faster first answer when prefill,
model loading, or reasoning consumes most of the request time. Each page
identifies which part of the request was measured.

Compare runs with the same model artifact, quantization, context, output
length, and cache conditions. Different backends may support different model
formats; matching a model name alone does not make the comparison equivalent.

Measurement dates stay attached to results even as package versions advance.
Read the per-study limits before applying a setting to a different GPU,
runtime build, workload, or concurrency level.

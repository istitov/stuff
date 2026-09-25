# Local AI benchmarks

These measurements show how runtimes packaged by `stuff` behaved on the
maintainer's hardware. Each study records its workload and software snapshot
so that readers can judge whether the result applies to their own setup.

| Study | Hardware and backend | Question |
|---|---|---|
| [Speculative decoding](speculative-decoding-on-890M.md) | Radeon 890M, llama.cpp Vulkan | How much do MTP and DFlash improve generation speed, and when does that shorten the wait for an answer? |
| [AMD Ryzen AI 300 NPU versus Radeon 890M](npu-vs-890m.md) | XDNA 2 / FastFlowLM and Radeon 890M / llama.cpp Vulkan | How do request latency, socket power, estimated energy and memory accounting compare? |

The [benchmark evidence repository](https://github.com/istitov/stuff-benchmarks/tree/d22bc593998930fa6cee4e0340c2555b4b48a284)
publishes the MTP, Muse DFlash and NPU/iGPU datasets at signed commit
[`d22bc59`](https://github.com/istitov/stuff-benchmarks/commit/d22bc593998930fa6cee4e0340c2555b4b48a284).
Each study has a sanitized evidence archive compressed with **7-Zip/PPMd**;
CSV tables, analysis tools, checksums and attribution remain directly readable.
The [verification instructions](https://github.com/istitov/stuff-benchmarks/blob/d22bc593998930fa6cee4e0340c2555b4b48a284/README.md#verify-and-reproduce-the-calculations)
require Python 3.11+ and 7-Zip and automatically unpack the archives into
temporary directories. No inference or model downloads are needed.
See [7-Zip installation and archive layout](https://github.com/istitov/stuff-benchmarks/blob/d22bc593998930fa6cee4e0340c2555b4b48a284/README.md#dataset-archives-and-7-zip).

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

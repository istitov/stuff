---
tags:
  - NPU
  - LLM inference
  - fine-tuning
---

# Running a fine-tune on the Ryzen AI NPU

FastFlowLM runs the models in its own catalog. A fine-tune of one of those
models can run on the NPU too, after its weights are converted from GGUF to
FastFlowLM's Q4NX format. The `stuff` overlay packages the three tools this
takes: the converter, a structure check, and a helper that registers the
result without editing files that belong to Portage.

This guide assumes a working NPU stack; see
[Ryzen AI NPU](ryzen-ai-npu.md) first.

## What can be converted

The converter repacks weights. It does not build the NPU kernels, which are
compiled per model and ship with FastFlowLM. A converted model therefore runs
on the kernels of the catalog model it is derived from, and it must have that
model's architecture and size.

In practice this covers fine-tunes and other modified weights of a catalog
model. A model that FastFlowLM does not ship cannot be added this way.

Two paths were verified by the maintainer on a Ryzen AI 9 HX 370 with
FastFlowLM 1.0.7: Qwen3.5-2B and Qwen3.6-35B-A3B. The converter has
configurations for more families (Qwen2.5, Qwen3, Gemma 3, Gemma 4, Llama,
LFM2, Phi-4, GPT-OSS and others); those were not tested here. Upstream has
none for Qwen3.8-27B; the package adds one by a local patch, which was not
tested here either.

The commands in this guide were run with a stock Qwen3.5-2B GGUF standing in
for the fine-tune. That makes the result checkable: the converted file has to
match the weights FastFlowLM ships for the same model. A fine-tune of
Qwen3.5-2B takes the same path.

## Quickstart

!!! tip "Quickstart"
    Install the converter, `llama-quantize`, and a FastFlowLM that ships
    `flm-custom-sync` (1.0.7-r1 or later), as root:

    ```bash title="root #"
    emerge -av sci-ml/flm-q4nx-converter sci-misc/llama-cpp \
      '>=sci-ml/fastflowlm-1.0.7-r1'
    ```

    The converter depends on `sci-ml/pytorch`.

    Then, as a normal user: prepare the GGUF, convert it, compare it with the
    official file, register it. Each step is explained below.

    ```bash title="user $"
    flm pull qwen3.5:2b
    llama-quantize --allow-requantize --pure \
      --token-embedding-type q8_0 --output-tensor-type q8_0 \
      --tensor-type ssm_alpha=q8_0 --tensor-type ssm_beta=q8_0 \
      my-tune-Q4_K_M.gguf prepared.gguf Q4_K_M
    flm-q4nx-convert -i prepared.gguf -o converted
    flm-q4nx-check converted/model.q4nx \
      ~/.config/flm/models/Qwen3.5-2B-NPU2/model.q4nx
    ```

## Step 1: get the base model

Pull the catalog model the fine-tune is derived from. Its folder provides the
reference for the structure check and the support files of the new model.

```bash title="user $"
flm pull qwen3.5:2b
ls ~/.config/flm/models/Qwen3.5-2B-NPU2/
```

## Step 2: prepare the GGUF

The kernels expect each tensor in one fixed quantisation. A standard
`Q4_K_M` GGUF mixes several, so one `llama-quantize` pass brings the file to
the layout of the official weights. `--pure` makes every projection Q4_K; the
other options set the tensors that the official file stores differently.

| Base model | Options besides `--allow-requantize --pure` |
|---|---|
| Qwen3.5-2B | `--token-embedding-type q8_0 --output-tensor-type q8_0 --tensor-type ssm_alpha=q8_0 --tensor-type ssm_beta=q8_0` |
| Qwen3.6-35B-A3B | `--output-tensor-type q8_0 --tensor-type ssm_alpha=f32 --tensor-type ssm_beta=f32` |

The two rows differ, and other models will differ again. The structure check
in step 4 shows which tensors are wrong, so the options for a new base model
can be found by running steps 2 to 4 and reading its output.

Tensors that this pass re-quantises lose the importance-matrix calibration of
the source file. A Q8_0 source GGUF is the better starting point when the
author publishes one.

## Step 3: convert

```bash title="user $"
flm-q4nx-convert -i prepared.gguf -o converted
```

The output folder receives `model.q4nx`. Give `-o` explicitly; the converter
fails without it.

The converter picks its model class from the GGUF's metadata. When the
metadata lacks the size, name the class with `-f`. The value is matched as a
prefix, so it has to be exact: `-f qwen3.5-2B` for this model and
`-f qwen35moe` for Qwen3.6-35B-A3B. A bare `-f qwen3.5` selects the Qwen3
class, which is wrong.

Conversion holds the model in memory. The maintainer's first
Qwen3.6-35B-A3B conversion, from a `Q4_K_M` source, took about three minutes
and peaked at 32 GB of memory and about 62 GB of disk. A later one from a
Q8_0 source peaked at about 39 GiB of memory and about 80 GB of disk.

The package carries several patches that upstream has not merged. One of them,
[pull request 23](https://github.com/ROCm/FLM_Q4NX_Converter/pull/23), is
needed for Qwen3.5: without it a converted model lacks tensors FastFlowLM
requires.

## Step 4: check the structure

```bash title="user $"
flm-q4nx-check converted/model.q4nx \
  ~/.config/flm/models/Qwen3.5-2B-NPU2/model.q4nx
```

`flm-q4nx-check` reads the two file headers. It checks that the byte ranges of
the converted file are consistent and compares tensor names, types and shapes
with the reference. For the Qwen3.5-2B conversion above it reports:

```text
tensors: 356 converted, 356 reference; 0 missing, 0 unexpected, 0 with another type or shape
data bytes: 1339228928 converted, 1339228928 reference
structure matches the reference
```

Do not load a file that fails this check. A tensor in another quantisation has
another block size than the kernel expects. The check does not compare weight
values, so it cannot tell whether the fine-tune is any good.

## Step 5: assemble the model folder

Create a folder for the model next to the official one. The paths below are
the defaults; with `FLM_MODEL_PATH` set, the models are under
`$FLM_MODEL_PATH/models/`. It takes the converted
weights and the base model's support files.

```bash title="user $"
M=~/.config/flm/models
mkdir $M/Qwen3.5-2B-mytune-NPU2
cp $M/Qwen3.5-2B-NPU2/{config.json,tokenizer.json,tokenizer_config.json,chat_template.jinja,vision_weight.q4nx} \
  $M/Qwen3.5-2B-mytune-NPU2/
mv converted/model.q4nx $M/Qwen3.5-2B-mytune-NPU2/
```

Use the official `tokenizer.json`, not the one the converter writes beside
`model.q4nx`. This is correct only when the fine-tune kept the base model's
vocabulary, chat template and vision projector; check that before copying.

## Step 6: register the model

Write `~/.config/flm/custom_models.json`. Each entry maps a new tag to its base
tag and its folder. The part of the new tag before the colon must not be a
family name FastFlowLM already uses.

```json title="~/.config/flm/custom_models.json"
{
  "qwen3.5-mytune:2b": {
    "base": "qwen3.5:2b",
    "name": "Qwen3.5-2B-mytune-NPU2"
  }
}
```

Then generate the registry:

```bash title="user $"
flm-custom-sync
```

This writes `~/.config/flm/model_list.json`, a copy of the packaged list with
the custom entries added, and `~/.config/flm/xclbins/`, links to the packaged
kernel folders with one more per custom model. Nothing under `/opt/fastflowlm`
is changed.

## Step 7: run it

FastFlowLM uses the generated registry when two variables point at it:

```bash title="user $"
export FLM_CONFIG_PATH=~/.config/flm/model_list.json
export FLM_XCLBIN_PATH=~/.config/flm
flm serve qwen3.5-mytune:2b
```

`flm serve` rejects a tag that is not in the registry, so a typing error in
the tag shows at once. A running server is less strict: a request that names
a model it does not know was answered by the default model, `llama3.2:1b`,
in the maintainer's tests. When testing through the API, check the server's
output for the line `Loading model:` and the new folder.

For Lemonade, add the same two `export` lines to `/etc/conf.d/lemonade` with
the absolute path of the serving user's home, and restart the service. The
model then appears in `lemonade list`.

## After a FastFlowLM upgrade

The generated registry is a copy and goes stale when `sci-ml/fastflowlm` is
upgraded. Run the helper again and restart whatever serves the models:

```bash title="user $"
flm-custom-sync --check
flm-custom-sync
```

An upgrade can also replace a model's weight layout. FastFlowLM then treats
weights made for an older version as outdated and replaces them from its
download metadata. That has no entry for a custom model: in a test with
1.0.7 the old weights were kept and would have been loaded on the new
kernels. `flm-custom-sync` therefore leaves such a model out of the list and
reports it. To bring it back:

1. pull the base model again, which fetches its new weights and support files;
2. convert the fine-tune again, with a converter that writes the new layout,
   and repeat the structure check;
3. copy the base model's new support files into the custom folder. The
   version FastFlowLM compares is the `flm_version` field in `config.json`;
4. run `flm-custom-sync` again and restart whatever serves the models.

`flm pull` cannot fetch or repair a custom tag, with or without `--force`.

## Limits

- The NPU kernels stay FastFlowLM's proprietary binaries. Conversion changes
  weights only.
- A converted Qwen3.6-35B-A3B ran at the speed of the official one in the
  maintainer's measurement. Other models were not timed.
- Tool calling and reasoning mode were not tested on converted models.
- A real FastFlowLM upgrade has not happened since the helper was written; its
  guard was tested against a simulated one.

## See also

- [Ryzen AI NPU](ryzen-ai-npu.md) — the NPU stack this builds on
- [ROCm/FLM_Q4NX_Converter](https://github.com/ROCm/FLM_Q4NX_Converter) — the
  converter upstream
- [Fine-tuning, Unsloth and RAG](fine-tuning-rag.md) — producing the fine-tune
- [llama.cpp setup](llama-setup.md) — running the same GGUF on the GPU

# Fine-tuning LLMs, Unsloth, and local RAG (Gentoo)

`stuff` ships the stack to run QLoRA fine-tuning and a local vector store for
RAG on Gentoo without separate pip or Conda environments:
`sci-ml/bitsandbytes` provides k-bit quantization and 8-bit optimizers,
`sci-ml/peft` provides LoRA / QLoRA adapters, `sci-ml/trl` provides SFT / DPO /
GRPO trainers, and `app-misc/qdrant` provides the vector database. They install
as regular Portage packages on top of the system PyTorch stack.

## Quickstart

!!! tip "Quickstart"
    With the overlay enabled ([Setup](../setup.md)), install the training
    stack, as root. On an AMD GPU, enable the ROCm backend for `bitsandbytes`
    first (it compiles HIP kernels for the arch set in `AMDGPU_TARGETS` — see
    the [ROCm setup](vllm.md#amd-rocm-setup)); without the flag the build is CPU-only:

    ```bash title="root #"
    echo "sci-ml/bitsandbytes rocm" >> /etc/portage/package.use/finetune
    emerge -av sci-ml/trl sci-ml/peft sci-ml/bitsandbytes
    ```

    `trl` pulls `sci-ml/transformers`, `sci-ml/datasets`, and
    `sci-ml/accelerate` in as dependencies; `peft` completes the adapter side.

## Backends and expectations

- The packaged `bitsandbytes` builds its **CPU** backend by default and its
  **ROCm/HIP** backend with `USE=rocm` (via `hipBLAS` / `rocBLAS`, keyed off
  `AMDGPU_TARGETS`). A CUDA-wired build is not currently provided by the
  overlay.
- LoRA / QLoRA on a **small model** is feasible on an integrated GPU or CPU for
  experimentation; anything larger wants a discrete GPU and real VRAM. The
  stack is build-verified on Strix Point (`gfx1150`); the training recipe below
  is the upstream-canonical shape, not a benchmark claim.

## Unsloth and Studio

For a higher-level training workflow, the overlay carries `sci-ml/unsloth` and
`dev-python/unsloth-zoo`. The base package provides Unsloth on the system Python
stack; `USE=studio` also builds its React frontend and installs a launcher for
the local browser UI. As root:

```bash title="root #"
echo "sci-ml/unsloth studio" >> /etc/portage/package.use/unsloth
emerge -av sci-ml/unsloth
```

Then, as a normal user:

```bash title="user $"
unsloth-studio
```

This launcher runs the UI and API in-process against portage-managed packages;
it does not create `~/.unsloth/studio`, download a private Python, or install a
second PyTorch. The separately packaged `sci-ml/unsloth-desktop-bin` remains
masked because that vendor GUI does bootstrap such a private runtime.

!!! warning "Unsloth and the newest vLLM currently require mutually exclusive PyTorch lines"
    The current Unsloth ebuild caps PyTorch below 2.12 and TRL at 0.24, while
    vLLM 0.27/0.28 pins PyTorch 2.13. They cannot share those newest versions in
    one root. Keep the training and serving environments on compatible pinned
    package versions (vLLM 0.26 is the retained PyTorch-2.11 line), or use
    separate Gentoo prefixes/containers until the upstream constraints meet.

## Fine-tune: QLoRA in a few lines

QLoRA = load the base model 4-bit (`bitsandbytes`) and train small LoRA
adapters on top (`peft`), driven by TRL's `SFTTrainer`. The minimal,
upstream-canonical script:

```python title="qlora_sft.py"
import torch
from datasets import load_dataset
from peft import LoraConfig
from transformers import AutoModelForCausalLM, BitsAndBytesConfig
from trl import SFTConfig, SFTTrainer

model_id = "<hf-model-id>"          # start small, e.g. a 0.6B instruct model
bnb = BitsAndBytesConfig(load_in_4bit=True,
                         bnb_4bit_compute_dtype=torch.bfloat16)
model = AutoModelForCausalLM.from_pretrained(model_id, quantization_config=bnb)
dataset = load_dataset("<hf-dataset-id>", split="train")

trainer = SFTTrainer(
    model=model,
    train_dataset=dataset,
    args=SFTConfig(output_dir="qlora-out"),
    peft_config=LoraConfig(r=16, lora_alpha=32, target_modules="all-linear"),
)
trainer.train()
```

Run it as a normal user:

```bash title="user $"
python qlora_sft.py
```

The trained LoRA adapter lands in `qlora-out/` — normally much smaller than the
base model, loadable with `peft` or mergeable into full weights. Beyond SFT,
`trl` carries the preference-tuning trainers (DPO, GRPO) with the same
structure; see the [TRL documentation](https://huggingface.co/docs/trl) and
[PEFT documentation](https://huggingface.co/docs/peft) for the full option
surface.

## RAG: a local vector store with Qdrant

[Qdrant](https://qdrant.tech/) is the retrieval half: a vector database that
stores embeddings and answers similarity queries. Install and start it, as
root:

```bash title="root #"
emerge -av app-misc/qdrant
rc-service qdrant start          # OpenRC; or: systemctl start qdrant
rc-update add qdrant default
```

The packaged service is **privacy-first by default**: bound to `127.0.0.1`
(REST on `:6333`, gRPC on `:6334`), config at `/etc/qdrant/config.yaml`, data
under `/var/lib/qdrant` owned by the dedicated `qdrant` user. Widen the bind
address deliberately if remote access is wanted. The web-UI dashboard is a
separate upstream release and is not bundled — the REST and gRPC APIs work
without it.

!!! note "The build fetches crates"
    `app-misc/qdrant` is a Rust package whose build downloads its crate graph
    at build time (the ebuild disables the network sandbox for this) — the
    build is therefore not offline. It is one of several explicitly
    network-enabled builds in the overlay.

A smoke test and a collection sized for the embedding model below, as a normal
user:

```bash title="user $"
curl -s http://127.0.0.1:6333/collections
curl -s -X PUT http://127.0.0.1:6333/collections/notes \
  -H 'Content-Type: application/json' \
  -d '{"vectors": {"size": 384, "distance": "Cosine"}}'
```

Embeddings come from **`sci-ml/sentence-transformers`** (packaged); the
384-dimension collection above matches its compact `all-MiniLM-L6-v2` model:

```python title="rag_query.py"
import requests
from sentence_transformers import SentenceTransformer

m = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
vec = m.encode("what does the overlay ship?").tolist()
hits = requests.post(
    "http://127.0.0.1:6333/collections/notes/points/search",
    json={"vector": vec, "limit": 3},
).json()
print(hits)
```

`dev-python/qdrant-client` is not packaged (yet) — the REST API needs nothing
beyond `dev-python/requests`. For a no-code RAG path, `dev-util/aichat`
(packaged) has RAG built in and can point at any OpenAI-compatible serving
endpoint from the [AI stack](../ai-stack.md).

## Troubleshooting

- **`bitsandbytes` fails to build with `USE=rocm`** — the HIP kernels need the
  GPU arch set in `AMDGPU_TARGETS` (see the
  [ROCm setup](vllm.md#amdgpu_targets)); confirm the
  token with `rocminfo | grep gfx`.
- **Qdrant refuses connections** — the service binds `127.0.0.1` only by
  default. Check it is running (`rc-service qdrant status`), and widen the
  `host:` in `/etc/qdrant/config.yaml` only if remote access is actually
  intended.
- **A merged model behaves differently from base + adapter** — merging a LoRA
  trained against a 4-bit base into full-precision weights
  (`merge_and_unload()`) rounds through the quantization; evaluate the merged
  model before retiring the adapter workflow.

## See also

- [The AI / ML stack in stuff](../ai-stack.md) — where fine-tuning and RAG sit
  in the bigger map.
- [vLLM](vllm.md#amd-rocm-setup) — the `AMDGPU_TARGETS` / ROCm setup the
  `bitsandbytes[rocm]` build keys off.
- [TRL](https://huggingface.co/docs/trl) · [PEFT](https://huggingface.co/docs/peft)
  · [bitsandbytes](https://huggingface.co/docs/bitsandbytes) ·
  [Qdrant docs](https://qdrant.tech/documentation/) — upstreams.

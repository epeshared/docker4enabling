#!/usr/bin/env bash
set -euo pipefail

WORK_HOME=$PWD/../
echo "WORK_HOME=$WORK_HOME"

###############################################
# MODEL_DIR="/home/xtang/models/openai/clip-vit-base-patch32"
# MODEL_DIR="$WORK_HOME/models/openai/clip-vit-large-patch14-336"
# MODEL_DIR="/home/xtang/models/Qwen/Qwen3-Embedding-4B"
MODEL_DIR="Qwen/Qwen3-Embedding-0.6B"
###############################################
echo "Using model: $MODEL_DIR"

# ===== OneDNN / IPEX 建议 =====
export DNNL_MAX_CPU_ISA=AVX512_CORE_AMX
export DNNL_VERBOSE=0
export IPEX_DISABLE_AUTOCAST=1   

mkdir -p "sglang_logs/sglang_cpu"
export SGLANG_TORCH_PROFILER_DIR="$PWD/sglang_logs/sglang_cpu"


export MALLOC_ARENA_MAX=1

# ===== Batch Size =====
BATCH_SIZE=16
echo "Batch size = $BATCH_SIZE"

python -m sglang.launch_server \
  --model-path "$MODEL_DIR" \
  --trust-remote-code \
  --disable-overlap-schedule \
  --is-embedding \
  --enable-multimodal \
  --device cpu \
  --host 0.0.0.0 --port 30000 \
  --skip-server-warmup \
  --tp 1 \
  --enable-torch-compile \
  --torch-compile-max-bs 16 \
  --attention-backend intel_amx \
  --enable-tokenizer-batch-encode \
  --log-level info
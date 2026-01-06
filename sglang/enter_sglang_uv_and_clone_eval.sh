#!/usr/bin/env bash
set -euo pipefail

# Must match install_sglang_cpu.sh
WORKSPACE=${WORKSPACE:-/sgl-workspace}
VENV_DIR=${VENV_DIR:-/opt/.venv}
REPO_URL=${REPO_URL:-https://github.com/epeshared/multi-model-process-eval.git}
REPO_DIRNAME=${REPO_DIRNAME:-multi-model-process-eval}

if [[ ! -f "${VENV_DIR}/bin/activate" ]]; then
  echo "[ERROR] venv not found: ${VENV_DIR}/bin/activate"
  echo "        Did you run install_sglang_cpu.sh successfully?"
  exit 1
fi

echo "==> Activating venv: ${VENV_DIR}"
# shellcheck disable=SC1090
source "${VENV_DIR}/bin/activate"

echo "==> Ensuring workspace exists: ${WORKSPACE}"
mkdir -p "${WORKSPACE}"
cd "${WORKSPACE}"

if [[ -d "${REPO_DIRNAME}/.git" ]]; then
  echo "==> Repo already exists: ${WORKSPACE}/${REPO_DIRNAME} (skip clone)"
else
  echo "==> Cloning: ${REPO_URL}"
  git clone "${REPO_URL}" "${REPO_DIRNAME}"
fi

echo
echo "========================================"
echo " Activated venv: ${VENV_DIR}"
echo " Current dir   : $(pwd)"
echo " Repo path     : ${WORKSPACE}/${REPO_DIRNAME}"
echo "========================================"
echo
echo "Tip: you are in the venv now. Run: cd ${REPO_DIRNAME}"

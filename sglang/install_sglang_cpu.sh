#!/usr/bin/env bash
set -euo pipefail

############################################
# Configurable variables (equivalent to ARG)
############################################
SGLANG_REPO=${SGLANG_REPO:-https://github.com/sgl-project/sglang.git}
VER_SGLANG=${VER_SGLANG:-main}

VER_TORCH=${VER_TORCH:-2.9.0}
VER_TORCHVISION=${VER_TORCHVISION:-0.24.0}
VER_TRITON=${VER_TRITON:-3.5.0}

PYTHON_VERSION=3.12

INSTALL_ROOT=/opt
VENV_DIR=${INSTALL_ROOT}/.venv
WORKSPACE=/sgl-workspace

############################################
# 1. System packages
############################################
echo "==> Installing system dependencies"
apt-get update
apt-get full-upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    ca-certificates \
    git \
    curl \
    wget \
    vim \
    gcc \
    g++ \
    make \
    libsqlite3-dev \
    google-perftools \
    libtbb-dev \
    libnuma-dev \
    numactl

############################################
# 2. Install uv
############################################
echo "==> Installing uv"
curl -LsSf https://astral.sh/uv/install.sh | sh

# load uv env
source "$HOME/.local/bin/env"

############################################
# 3. Create virtual environment
############################################
echo "==> Creating Python ${PYTHON_VERSION} venv at ${VENV_DIR}"
mkdir -p "${INSTALL_ROOT}"
cd "${INSTALL_ROOT}"
uv venv --python ${PYTHON_VERSION}

############################################
# 4. Configure uv indexes (CPU wheels)
############################################
echo "==> Writing uv.toml"
cat > ${VENV_DIR}/uv.toml <<EOF
[[index]]
name = "torch"
url = "https://download.pytorch.org/whl/cpu"

[[index]]
name = "torchvision"
url = "https://download.pytorch.org/whl/cpu"

[[index]]
name = "triton"
url = "https://download.pytorch.org/whl/cpu"
EOF

export UV_CONFIG_FILE=${VENV_DIR}/uv.toml

############################################
# 5. Clone and build sglang
############################################
echo "==> Cloning sglang"
mkdir -p "${WORKSPACE}"
cd "${WORKSPACE}"

git clone "${SGLANG_REPO}" sglang
cd sglang
git checkout "${VER_SGLANG}"

############################################
# 6. Activate venv
############################################
source "${VENV_DIR}/bin/activate"

############################################
# 7. Install sglang (python)
############################################
echo "==> Installing sglang python package"
cd python
cp pyproject_cpu.toml pyproject.toml
uv pip install .

############################################
# 8. Install CPU-only torch stack
############################################
echo "==> Installing torch / torchvision / triton (CPU)"
uv pip install \
    torch==${VER_TORCH} \
    torchvision==${VER_TORCHVISION} \
    triton==${VER_TRITON} \
    --force-reinstall

############################################
# 9. Build sgl-kernel (CPU)
############################################
echo "==> Installing sgl-kernel"
cd ../sgl-kernel
cp pyproject_cpu.toml pyproject.toml
uv pip install .

############################################
# 10. Runtime environment variables
############################################
echo "==> Installing sglang runtime env wrapper"

cat >/usr/local/bin/sglang-env <<'EOF'
#!/usr/bin/env bash

export SGLANG_USE_CPU_ENGINE=1
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc.so.4:\
/usr/lib/x86_64-linux-gnu/libtbbmalloc.so:\
/opt/.venv/lib/libiomp5.so

exec "$@"
EOF

chmod +x /usr/local/bin/sglang-env

############################################
# 11. Auto-activate venv on login
############################################
if ! grep -q "${VENV_DIR}/bin/activate" /root/.bashrc; then
    echo "source ${VENV_DIR}/bin/activate" >> /root/.bashrc
fi

############################################
# 12. Copy start script (optional)
############################################
if [[ -f start_sglang_cpu.sh ]]; then
    echo "==> start_sglang_cpu.sh already present"
else
    echo "NOTE: start_sglang_cpu.sh not found, skip"
fi

echo
echo "========================================"
echo " SGLang CPU installation finished"
echo " Workspace : ${WORKSPACE}/sglang"
echo " Venv      : ${VENV_DIR}"
echo "========================================"

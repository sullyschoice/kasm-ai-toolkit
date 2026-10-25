#!/usr/bin/env bash
# Installs ai-toolkit (https://github.com/ostris/ai-toolkit) into /opt/ai-toolkit.
# Versions track upstream's docker/Dockerfile and manager/spec.py (linux x86_64, cu130).
# The cu130 torch wheels need an NVIDIA host driver >= 580 (CUDA 13).
set -ex
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
export DEBIAN_FRONTEND=noninteractive

AI_TOOLKIT_REF="${AI_TOOLKIT_REF:-main}"

# python3.12-dev provides Python.h, which triton needs to JIT-compile its CUDA
# helpers at runtime ("fatal error: Python.h: No such file or directory").
apt-get update
apt-get install -y --no-install-recommends \
    git curl build-essential cmake rsync ffmpeg \
    python3.12 python3.12-dev python3.12-venv python3-dev python3-venv \
    libgl1 libglib2.0-0

# Node.js 24 (upstream uses nodesource; Ubuntu's packaged nodejs is too old)
curl -fsSL https://deb.nodesource.com/setup_24.x -o /tmp/nodesource_setup.sh
bash /tmp/nodesource_setup.sh
rm /tmp/nodesource_setup.sh
apt-get install -y nodejs

mkdir -p /opt/
cd /opt
git clone https://github.com/ostris/ai-toolkit
cd ai-toolkit
git checkout "$AI_TOOLKIT_REF"
python3.12 -m venv venv
source venv/bin/activate
pip install --no-cache-dir --upgrade pip

# torch first, then requirements (versions must match upstream manager/spec.py)
pip install --no-cache-dir torch==2.13.0 torchvision==0.28.0 torchaudio==2.11.0 --index-url https://download.pytorch.org/whl/cu130
pip install --no-cache-dir -r requirements.txt
pip install --no-cache-dir setuptools==69.5.1

# Accelerators, installed after requirements with -U so they override older pins
pip install --no-cache-dir -U \
    torchcodec==0.15.0 \
    natten==0.21.7+torch2130cu130 --find-links https://whl.natten.org \
    https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.9.47/flash_attn-2.8.3+cu130torch2.13-cp312-cp312-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl

# flash-linear-attention (DeltaNet kernels for Qwen3.5/3.8 text encoders). Installed
# without -U so its unpinned transformers requirement can't bump the pinned version.
pip install --no-cache-dir flash-linear-attention==0.5.2
python -c "import torch, flash_attn, natten, torchcodec, fla, transformers; print('torch', torch.__version__, 'transformers', transformers.__version__)"

# UI: update_db runs `prisma generate`, which the TS build needs
cd ui
npm ci
npm run update_db
npm run build
chown -R 1000:1000 /opt/ai-toolkit

apt-get clean
rm -rf /var/lib/apt/lists/* /root/.cache/pip /root/.npm



cat >/usr/share/applications/ai-toolkit.desktop <<EOL
[Desktop Entry]
Version=1.0
Name=AI Toolkit
Comment=AI Image Traininer
TryExec=/opt/ai-toolkit/launcher.sh
Exec=/opt/ai-toolkit/launcher.sh -- %u
Icon=/opt/ai-toolkit/ai-toolkit.png
Terminal=false
StartupWMClass=ai-toolkit
Type=Application
Categories=Multimedia;
EOL

chmod +x /usr/share/applications/ai-toolkit.desktop
chown 1000:1000 /usr/share/applications/ai-toolkit.desktop
cp /usr/share/applications/ai-toolkit.desktop $HOME/Desktop/ai-toolkit.desktop
chown 1000:1000 $HOME/Desktop/ai-toolkit.desktop

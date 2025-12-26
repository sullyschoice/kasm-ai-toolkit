#!/usr/bin/env bash
set -ex
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

apt-get update
apt-get install -y python3-venv  nodejs npm python3.12

mkdir -p /opt/
cd /opt
git clone https://github.com/ostris/ai-toolkit
cd ai-toolkit
python3 -m venv venv
source venv/bin/activate
pip uninstall torch
pip3 install --no-cache-dir torch==2.9.1 torchvision==0.24.1 torchaudio==2.9.1 --index-url https://download.pytorch.org/whl/cu128
pip3 install setuptools==69.5.1
pip3 install -r requirements.txt

cd ui
npm install
npm run build
chown -R 1000:1000 /opt/ai-toolkit



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

set -euo pipefail

echo "[+] Updating system"
apt update
apt upgrade -y

echo "[+] Removing old Docker packages"
apt remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true
apt autoremove -y

echo "[+] Installing prerequisites"
apt install -y ca-certificates curl gnupg lsb-release

echo "[+] Adding Docker repository"
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

cat >/etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "[+] Installing Docker"
apt update
apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable --now docker

echo "[+] Installing SSH"
apt install -y openssh-server
systemctl enable --now ssh

echo "[+] Installing Python"
apt install -y python3 python3-pip python3-venv

python3 -m venv /opt/venv

source /opt/venv/bin/activate

pip install --upgrade pip
pip install python-dotenv

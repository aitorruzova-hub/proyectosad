#!/usr/bin/env bash
# El script se detiene si hay errores
set -e
export DEBIAN_FRONTEND=noninteractive
echo "########################################"
echo " Aprovisionando adminpc "
echo "########################################"
apt-get update -y
apt-get install -y curl nmap tcpdump wget iputils-ping
# Usuario administrador ( Debian el grupo de administradores es "sudo", no "wheel")
echo "=> Creamos usuario administrador..."
id admin_aitor >/dev/null 2>&1 || useradd -m -s /bin/bash admin_aitor
usermod -aG sudo admin_aitor
echo "admin_aitor ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/admin_aitor
chmod 440 /etc/sudoers.d/admin_aitor
# Claves SSH inyectadas por Vagrant en /tmp
echo "=> Importamos claves SSH"
mkdir -p /home/admin_aitor/.ssh
cp /tmp/id_ed25519 /home/admin_aitor/.ssh/id_ed25519
cp /tmp/id_ed25519.pub /home/admin_aitor/.ssh/id_ed25519.pub
# Por si las claves vienen de Windows con finales de línea CRLF
sed -i 's/\r$//' /home/admin_aitor/.ssh/id_ed25519 /home/admin_aitor/.ssh/id_ed25519.pub
chown -R admin_aitor:admin_aitor /home/admin_aitor/.ssh
chmod 700 /home/admin_aitor/.ssh
chmod 600 /home/admin_aitor/.ssh/id_ed25519
chmod 644 /home/admin_aitor/.ssh/id_ed25519.pub
echo "------ FIN ------"
# eth0 es la NAT de Vagrant: solo la queremos para que Vagrant entre por SSH.
# dhcpcd no debe poner rutas por defecto (ni IPv4 ni IPv6) por ella: todo sale por el gw.
grep -q '^interface eth0' /etc/dhcpcd.conf || cat >> /etc/dhcpcd.conf <<'EOF'
interface eth0
nogateway
EOF
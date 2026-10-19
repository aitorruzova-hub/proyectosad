#!/bin/sh

# El script se detiene si hay errores
set -e
echo "########################################"
echo " Aprovisionando adminpc "
echo "########################################"
echo "-----------------"
echo "Actualizando repositorios"
apk update
apk add curl nmap tcpdump wget bash iputils
# 1. Crear el usuario administrador local en adminpc (Alpine)
echo "=> Creando usuario administrador..."
adduser -D admin_aitor
adduser admin_aitor wheel
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
echo "=> Importando claves SSH desde el anfitrión..."
# 2. Movemos las llaves inyectadas por Vagrant en /tmp
mkdir -p /home/admin_aitor/.ssh
mv /tmp/id_ed25519 /home/admin_aitor/.ssh/id_ed25519
mv /tmp/id_ed25519.pub /home/admin_aitor/.ssh/id_ed25519.pub
# Limpiar posibles retornos de carro de Windows (CRLF)
sed -i 's/\r$//' /home/admin_aitor/.ssh/id_ed25519
# 3. Ajustamos los permisos por seguridad
chown -R admin_aitor:admin_aitor /home/admin_aitor/.ssh
chmod 700 /home/admin_aitor/.ssh
chmod 600 /home/admin_aitor/.ssh/id_ed25519
chmod 644 /home/admin_aitor/.ssh/id_ed25519.pub
echo "------ FIN ------"

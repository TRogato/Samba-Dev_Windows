#!/usr/bin/env bash

# Variáveis e Configurações
export SMB_USER="seu_usuario"
export SMB_PASS="sua_senha"

# Instalar Samba
echo "Instalando Samba"
apt-get update > /dev/null
apt-get install samba -y > /dev/null

# Criar diretório para compartilhamento
mkdir -p /var/www/html
chown -R $SMB_USER:$SMB_USER /var/www/html

# Configurar
echo "Configurando Samba"
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak

read -d '' SMB_CNFG <<"EOF"
[global]
    workgroup = WORKGROUP
    security = user
[www]
    comment = Compartilhamento de Arquivos do Ubuntu
    path = /var/www/html/
    browsable = yes
    guest ok = no
    read only = no

    create mask = 644
    force create mode = 644
    security mask = 644
    force security mode = 644

    directory mask = 2775
    force directory mode = 2775
    directory security mask = 2775
    force directory security mode = 2775
EOF

echo "$SMB_CNFG" | tee /etc/samba/smb.conf > /dev/null

# Criar usuário para o Samba
useradd $SMB_USER -s /sbin/nologin
echo -ne "$SMB_PASS\n$SMB_PASS\n" | smbpasswd -a -s $SMB_USER

# Reiniciar
echo "Reiniciando o Samba"
service smbd restart

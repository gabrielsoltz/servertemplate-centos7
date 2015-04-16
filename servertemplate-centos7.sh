#!/usr/bin/bash
########################################################################################################################
# SERVERTEMPLATE-CENTOS7
########################################################################################################################
SCRIPT_NAME="SERVERTEMPLATE-CENTOS7"
SCRIPT_DESCRIPTION="Server Template: CENTOS7"
SCRIPT_VERSION="0.2"
SCRIPT_AUTHOR="Gabriel Soltz"
SCRIPT_CONTACT="thegaby@gmail.com"
SCRIPT_DATE="30-03-2015"
SCRIPT_GIT="https://github.com/gabrielsoltz/servertemplate-centos7"
SCRIPT_WEB="www.3ops.com"
########################################################################################################################

###############################################################################
## INICIO
###############################################################################
## LOG
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATE=$(date +%m-%d-%Y_%H-%M)Hs
export LOG=$DIR/LOG-$SCRIPT_NAME-$DATE.log
echo "--------------------------------------------------------" | tee -a $LOG
echo "SCRIPT: $SCRIPT_NAME" | tee -a $LOG
echo "VERSION: $SCRIPT_VERSION" | tee -a $LOG
echo "INICIO: $DATE" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG

## CHECK HOSTNAME
echo "CHECK_VARIABLE: HOSTNAME" | tee -a $LOG
if [[ -z "$1" ]]; then
        echo " ! ERROR: SE DEBE ESPECIFICAR UN NOMBRE PARA HOSTNAME." | tee -a $LOG
        exit
else
	echo " HOSTNAME OK..." | tee -a $LOG
	HOSTNAME=$1
fi
echo "" | tee -a $LOG

###############################################################################
## GENERAL
###############################################################################
# UPGRADE SISTEMA
echo "--------------------------------------------------------" | tee -a $LOG
echo "UPGRADE SISTEMA" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
sudo yum -y upgrade 2>> $LOG && \
echo "OK" | tee -a $LOG || \
{ echo " ! ERROR" | tee -a $LOG ; exit; }
sleep 20
echo "" | tee -a $LOG

# ELIMINAR PAQUETES
echo "--------------------------------------------------------" | tee -a $LOG
echo "ELIMINAR PAQUETES" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
sudo yum -y remove java at ed words dash perl ruby20 bind-utils alsa-lib ntsysv javapackages-tools aws* 2>> $LOG && \
echo "OK" | tee -a $LOG || { echo " ! ERROR" | tee -a $LOG ; exit; }
sleep 20
echo "" | tee -a $LOG

# DESACTIVAR SERVICIOS
echo "--------------------------------------------------------" | tee -a $LOG
echo "DESACTIVAR SERVICIOS" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
sudo systemctl disable iptables 1>> $LOG 2>> $LOG
sudo systemctl disable ip6tables 1>> $LOG 2>> $LOG
sudo systemctl disable atd 1>> $LOG 2>> $LOG
sudo systemctl disable mdmonitor 1>> $LOG 2>> $LOG
sudo systemctl disable lvm2-monitor 1>> $LOG 2>> $LOG
sudo systemctl disable netfs 1>> $LOG 2>> $LOG
sudo systemctl disable cloud-config 1>> $LOG 2>> $LOG
sudo systemctl disable cloud-final 1>> $LOG 2>> $LOG
sudo systemctl disable cloud-init 1>> $LOG 2>> $LOG
sudo systemctl disable cloud-init-local 1>> $LOG 2>> $LOG
sudo systemctl disable abrt-ccpp 1>> $LOG 2>> $LOG
sudo systemctl disable abrtd 1>> $LOG 2>> $LOG
sudo systemctl disable autofs 1>> $LOG 2>> $LOG
sudo systemctl disable certmonger 1>> $LOG 2>> $LOG
sudo systemctl disable choose_repo 1>> $LOG 2>> $LOG
sudo systemctl disable cpuspeed 1>> $LOG 2>> $LOG
sudo systemctl disable cups 1>> $LOG 2>> $LOG
sudo systemctl disable nfslock 1>> $LOG 2>> $LOG
sudo systemctl disable portreserve 1>> $LOG 2>> $LOG
sudo systemctl disable postfix 1>> $LOG 2>> $LOG
sudo systemctl disable rhnsd 1>> $LOG 2>> $LOG
sudo systemctl disable rpcbind 1>> $LOG 2>> $LOG 
sudo systemctl disable rpcgssd 1>> $LOG 2>> $LOG
sudo systemctl disable sysstat 1>> $LOG 2>> $LOG
sudo systemctl disable sendmail 1>> $LOG 2>> $LOG
sudo systemctl disable firewalld 1>> $LOG 2>> $LOG
sleep 5
echo "" | tee -a $LOG

# DESACTIVAR SELINUX
echo "--------------------------------------------------------" | tee -a $LOG
echo "DESACTIVAR SELINUX" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
sudo sed -i "s/SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config 1>> $LOG 2>> $LOG

# NTP
echo "--------------------------------------------------------" | tee -a $LOG
echo "NTP" | tee -a $LOG 
echo "--------------------------------------------------------" | tee -a $LOG
echo "Eliminando NTP..." | tee -a $LOG
sudo yum -y remove ntp 2>> $LOG && \
echo "OK" | tee -a $LOG || \
{ echo " ! ERROR" | tee -a $LOG ; exit; }
sleep 5
echo "Seteando Localtime..." | tee -a $LOG
sudo ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime 1>> $LOG 2>> $LOG
sudo sed -i 's/ZONE=.*/ZONE="America\/Argentina\/Buenos_Aires"/g' /etc/sysconfig/clock 1>> $LOG 2>> $LOG
echo "" | tee -a $LOG

# HOSTNAME
echo "--------------------------------------------------------" | tee -a $LOG
echo "HOSTNAME" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
sudo hostnamectl --static set-hostname "$HOSTNAME" 1>> $LOG 2>> $LOG
echo "" | tee -a $LOG

# MOTD
echo "--------------------------------------------------------" | tee -a $LOG
echo "CONFIGURACION MOTD" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
echo -e "
HOSTNAME: $(hostname)
INSTALACION: $(date)
# -------------------------------------------------------------------------- #
# Use of this system is restricted to authorized users. User activity is     #
# monitored and recorded by system personnel. Anyone using this system       #
# expressly consents to such monitoring and recording. BE ADVISED: if        #
# possible criminal activity is detected, system records, along with certain #
# personal information, may be provided to law enforcement officials.        #
# -------------------------------------------------------------------------- #
" > /tmp/motd
sudo mv /tmp/motd /etc/motd 1>> $LOG 2>> $LOG
echo "" | tee -a $LOG

# SYSCTL
echo "--------------------------------------------------------" | tee -a $LOG
echo "CONFIGURACION SYSCTL" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
sudo sed -i '
$a # DESDE ACA, CONFIGURACION ADICONAL:
$a 
$a # Block SYN attacks
$a net.ipv4.tcp_syncookies = 1
$a net.ipv4.tcp_max_syn_backlog = 2048
$a net.ipv4.tcp_synack_retries = 2
$a net.ipv4.tcp_syn_retries = 5
$a 
$a # Ignore Directed pings
$a net.ipv4.icmp_echo_ignore_all = 0
$a 
$a # Deshabilitar Forwarding / Redirects
$a net.ipv4.conf.all.forwarding = 0
$a #net.ipv6.conf.all.forwarding = 0
$a net.ipv4.conf.all.mc_forwarding = 0
$a #net.ipv6.conf.all.mc_forwarding = 0
$a net.ipv4.conf.all.secure_redirects = 0
$a net.ipv4.conf.all.send_redirects = 0
$a net.ipv4.conf.all.send_redirects = 0
$a net.ipv4.conf.default.send_redirects = 0
$a 
$a # Exec-Shield Buffer Overflow Protection
$a kernel.randomize_va_space = 1
$a 
$a # DDOS PROTECTION
$a net.ipv4.conf.all.log_martians = 1
$a net.ipv4.icmp_ignore_bogus_error_messages = 1
$a net.ipv4.conf.default.accept_source_route = 0
$a #net.ipv6.conf.default.accept_source_route = 0
$a net.ipv4.conf.all.accept_source_route = 0
$a #net.ipv6.conf.all.accept_source_route = 0
$a net.ipv4.conf.all.accept_redirects = 0
$a #net.ipv6.conf.all.accept_redirects = 0
$a net.ipv4.icmp_echo_ignore_broadcasts = 1
$a net.ipv4.conf.all.rp_filter = 1
$a net.ipv4.conf.default.rp_filter = 1
$a 
$a # TCP OPTIMIZATION
$a net.ipv4.tcp_window_scaling = 1
$a net.core.rmem_max = 16777216
$a net.core.wmem_max = 16777216
$a net.ipv4.tcp_rmem = 4096 87380 16777216
$a net.ipv4.tcp_wmem = 4096 16384 16777216
$a net.core.somaxconn = 65535
$a net.core.netdev_max_backlog = 512000
$a net.ipv4.ip_local_port_range = 1024 65535
$a net.ipv4.tcp_tw_recycle = 1
$a net.ipv4.tcp_tw_reuse = 1
$a net.ipv4.tcp_congestion_control = cubic
$a net.ipv4.tcp_timestamps = 1
$a net.ipv4.tcp_sack = 1
$a net.ipv4.tcp_no_metrics_save = 1
$a net.ipv4.tcp_slow_start_after_idle = 0
$a 
$a # Otras
$a fs.file-max = 9999999
$a fs.nr_open = 9999999
$a net.ipv4.tcp_fin_timeout = 30
$a net.ipv4.tcp_keepalive_time = 30
$a net.ipv4.tcp_max_tw_buckets = 400000
$a vm.min_free_kbytes = 65536
$a vm.overcommit_memory = 1
' /etc/sysctl.conf 1>> $LOG 2>> $LOG
sudo chown root:root /etc/sysctl.conf 1>> $LOG 2>> $LOG
sudo chmod 0644 /etc/sysctl.conf 1>> $LOG 2>> $LOG
sudo chown root:root /etc/sysctl.conf 1>> $LOG 2>> $LOG
sudo sysctl -p /etc/sysctl.conf 1>> $LOG 2>> $LOG
sleep 5
echo "" | tee -a $LOG

# MODPROBE
echo "--------------------------------------------------------" | tee -a $LOG
echo "CONFIGURACION MODPROBE" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
if ! [ -f "/etc/modprobe.d/blacklist.conf" ]; then 
	sudo -E bash -c 'echo "# Blackilist Modprobe" | tee /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG'
fi
sudo sed -i '$a # Bloquear USB' /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG
sudo sed -i '$a blacklist usb_storage' /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG
sudo sed -i '$a # Bloquear Firewire' /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG
sudo sed -i '$a blacklist ohci1394' /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG
sudo sed -i '$a blacklist sbp2' /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG
sudo sed -i '$a blacklist dv1394' /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG
sudo sed -i '$a blacklist raw1394' /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG
sudo sed -i '$a blacklist video1394' /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG
sudo sed -i '$a blacklist firewire-ohci' /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG
sudo sed -i '$a blacklist firewire-sbp2' /etc/modprobe.d/blacklist.conf 1>> $LOG 2>> $LOG
sudo -E bash -c 'echo "# Bloquear IPV6" | tee /etc/modprobe.d/ipv6.conf 1>> $LOG 2>> $LOG'
sudo sed -i '$a install ipv6 /bin/true' /etc/modprobe.d/ipv6.conf 1>> $LOG 2>> $LOG
sleep 5
echo "" | tee -a $LOG

# DESACTIVAR IPV6
echo "--------------------------------------------------------" | tee -a $LOG
echo "DESACTIVAR IPV6" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
if grep "NETWORKING_IPV6=" /etc/sysconfig/network; then 
sudo sed -i "s/NETWORKING_IPV6=.*/NETWORKING_IPV6=no/g" /etc/sysconfig/network 1>> $LOG 2>> $LOG
else
sudo sed -i '$a NETWORKING_IPV6=no' /etc/sysconfig/network 1>> $LOG 2>> $LOG
fi

if grep "IPV6INIT=" /etc/sysconfig/network; then 
sudo sed -i "s/IPV6INIT=.*/IPV6INIT=no/g" /etc/sysconfig/network 1>> $LOG 2>> $LOG
else
sudo sed -i '$a IPV6INIT=no' /etc/sysconfig/network 1>> $LOG 2>> $LOG
fi

if grep "IPV6_ROUTER=" /etc/sysconfig/network; then 
sudo sed -i "s/IPV6_ROUTER=.*/IPV6_ROUTER=no/g" /etc/sysconfig/network 1>> $LOG 2>> $LOG
else
sudo sed -i '$a IPV6_ROUTER=no' /etc/sysconfig/network 1>> $LOG 2>> $LOG
fi

if grep "IPV6_AUTOCONF=" /etc/sysconfig/network; then 
sudo sed -i "s/IPV6_AUTOCONF=.*/IPV6_AUTOCONF=no/g" /etc/sysconfig/network 1>> $LOG 2>> $LOG
else
sudo sed -i '$a IPV6_AUTOCONF=no' /etc/sysconfig/network 1>> $LOG 2>> $LOG
fi

if grep "IPV6FORWARDING=" /etc/sysconfig/network; then 
sudo sed -i "s/IPV6FORWARDING=.*/IPV6FORWARDING=no/g" /etc/sysconfig/network 1>> $LOG 2>> $LOG
else
sudo sed -i '$a IPV6FORWARDING=no' /etc/sysconfig/network 1>> $LOG 2>> $LOG
fi

if grep "IPV6TO4INIT=" /etc/sysconfig/network; then 
sudo sed -i "s/IPV6TO4INIT=.*/IPV6TO4INIT=no/g" /etc/sysconfig/network 1>> $LOG 2>> $LOG
else
sudo sed -i '$a IPV6TO4INIT=no' /etc/sysconfig/network 1>> $LOG 2>> $LOG
fi

if grep "IPV6_CONTROL_RADVD=" /etc/sysconfig/network; then 
sudo sed -i "s/IPV6_CONTROL_RADVD=.*/IPV6_CONTROL_RADVD=no/g" /etc/sysconfig/network 1>> $LOG 2>> $LOG
else
sudo sed -i '$a IPV6_CONTROL_RADVD=no' /etc/sysconfig/network 1>> $LOG 2>> $LOG
fi
echo "" | tee -a $LOG

###############################################################################
## SSHD_CONFIG
###############################################################################
# CREAR GRUPO SSH
echo "--------------------------------------------------------" | tee -a $LOG
echo "Crear Grupo SSH" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
SSHGROUP=sshusers
sudo groupadd -r $SSHGROUP 1>> $LOG 2>> $LOG
# PASSWORD ROOT
echo "--------------------------------------------------------" | tee -a $LOG
echo "Cambiar Password Root" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
PASSWORD_ROOT=$(openssl rand -base64 32)
echo root:$PASSWORD_ROOT | sudo chpasswd 1>> $LOG 2>> $LOG
echo "********************************************************" | tee -a $LOG
echo " ROOT PASSWORD: $PASSWORD_ROOT" | tee -a $LOG
echo "********************************************************" | tee -a $LOG
# CREAR USUARIO ADMIN
echo "--------------------------------------------------------" | tee -a $LOG
echo "Creacion Usuario Admin" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
export SSHGROUP=sshusers
export USUARIO=admin
PASSWORD_ADMIN=$(openssl rand -base64 32)
sudo useradd $USUARIO 1>> $LOG 2>> $LOG
echo $USUARIO:$PASSWORD_ADMIN | sudo chpasswd 1>> $LOG 2>> $LOG
sudo usermod -a -G $SSHGROUP $USUARIO 1>> $LOG 2>> $LOG
# PASSWORD ADMIN
echo "--------------------------------------------------------" | tee -a $LOG
echo "Cambiar Password Admin" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
echo "********************************************************" | tee -a $LOG
echo " ADMIN PASSWORD: $PASSWORD_ADMIN" | tee -a $LOG
echo "********************************************************" | tee -a $LOG
# KEYS ADMIN
echo " Generar Keys..." | tee -a $LOG
sudo mkdir /home/$USUARIO/.ssh 1>> $LOG 2>> $LOG
sudo chown -R $USUARIO:$USUARIO /home/$USUARIO/.ssh 1>> $LOG 2>> $LOG
sudo chmod -R 700 /home/$USUARIO/.ssh 1>> $LOG 2>> $LOG
sudo -u $USUARIO ssh-keygen -t rsa -b 2048 -N "" -f /home/$USUARIO/.ssh/$USUARIO-$(hostname).key 1>> $LOG 2>> $LOG
sudo -E bash -c 'cat /home/$USUARIO/.ssh/$USUARIO-$(hostname).key.pub | tee /home/$USUARIO/.ssh/authorized_keys 1>> $LOG 2>> $LOG'
sudo chown -R $USUARIO:$USUARIO /home/$USUARIO/.ssh 1>> $LOG 2>> $LOG
sudo chmod -R 700 /home/$USUARIO/.ssh 1>> $LOG 2>> $LOG
echo "Llaves SSH en /home/$USUARIO/.ssh/$USUARIO-$(hostname).key" | tee -a $LOG
echo "********************************************************" | tee -a $LOG
echo " ADMIN PRIV-KEY:" | tee -a $LOG
sudo cat /home/$USUARIO/.ssh/$USUARIO-$(hostname).key | tee -a $LOG
echo "********************************************************" | tee -a $LOG
echo "********************************************************" | tee -a $LOG
echo " ADMIN PUB-KEY:" | tee -a $LOG
sudo cat /home/$USUARIO/.ssh/$USUARIO-$(hostname).key.pub | tee -a $LOG
echo "********************************************************" | tee -a $LOG
echo "Elimino Keys" | tee -a $LOG
rm -f /home/$USUARIO/.ssh/$USUARIO-$(hostname).key 1>> $LOG 2>> $LOG
# SUDOERS ADMIN
echo "Configuracion Sudoers" | tee -a $LOG
sudo -E bash -c 'echo "$USUARIO ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/$USUARIO 1>> $LOG 2>> $LOG'
# BASHRC
echo "BashRC" | tee -a $LOG
sudo sed -i '$a export PS1="\\[\\e[00;33m\\]\\u\\[\\e[0m\\]\\[\\e[00;31m\\]@\\[\\e[0m\\]\\[\\e[00;32m\\]\\h\\[\\e[0m\\]\\[\\e[00;31m\\]:\\[\\e[0m\\]\\[\\e[00;36m\\][\\w]\\[\\e[0m\\]\\[\\e[00;31m\\]:\\[\\e[0m\\]"' /home/$USUARIO/.bashrc
# REINICIAR SSHD
echo "--------------------------------------------------------" | tee -a $LOG
echo "Reiniciar SSHD" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
sudo systemctl restart sshd 1>> $LOG 2>> $LOG
sleep 10

###############################################################################
## FINAL
###############################################################################
## BASH_HISTORY
echo "--------------------------------------------------------" | tee -a $LOG
echo "REMOVE BASH_HISTORY" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
cat /dev/null > ~/.bash_history 1>> $LOG 2>> $LOG
history -c 1>> $LOG 2>> $LOG
echo "" | tee -a $LOG

## FIN
echo "--------------------------------------------------------" | tee -a $LOG
echo "FIN" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG

echo "--------------------------------------------------------" | tee -a $LOG
echo "Reiniciar" | tee -a $LOG
echo "--------------------------------------------------------" | tee -a $LOG
sudo su root -c 'sudo reboot'

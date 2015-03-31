Server Template CentOS7

Script en Bash para estandarizar Sistemas CentOS 7.
Fué realizado para ejecutar previo a la instalación de los servicios productivos de cada servidor. 
Realiza control de errores en cada uno de sus funcionalidades. Todo lo realizado se loguea en $LOG.

Para Ejecutar: ./servertemplate-centos7.sh <HOSTNAME>

Funcionalidades:

1. UPGRADE SISTEMA
2. ELIMINAR PAQUETES: Desintalación de Paquetes no necesarios
3. DESACTIVAR SERVICIOS: Desactivación de Serivicios al Inicio no necesarios
4. ZONEDATE: Eliminar Paquete NTP y Setear Zona Horaria.
5. SETEAR HOSTNAME
6. SETEAR MOTD
7. AJUSTES SYSCTL
8. AJUSTES MODPROBE
9. DESACTIVAR IPV6
10. SSHD_CONFIG
	- CREAR GRUPO SSH
	- SETEAR PASSWORD ROOT
	- CREAR USUARIO ADMIN
	- SETEAR PASSWORD ADMIN
	- CREAR CERTS ADMIN
	- CONFIGURAR SUDOERS ADMIN
	- CONFIGURAR BASHRC PS1
11. REBOOT
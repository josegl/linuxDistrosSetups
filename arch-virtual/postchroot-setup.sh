#!/bin/bash
# Este script se ejecuta dentro del entorno chroot. En el haremos las siguientes operaciones:

# Copia de los ficheros de configuracion
# Intalacion de los paquetes necesarios
# Configuracion de los repos de pacman
# Creacion del usuario jgl con new users y el fichero
# 
# En este punto tenemos que preparar el tema del cifrado de la particion home con la llave 

# 1. En este punto actualizamos repos e instalamos los paquetes necesarios para un entorno cli usable:
pacman-db-upgrade
pacman -Syy
pacman -Syu
pacman -S gvim-python3 openssh zsh git tmux weechat grub sudo links networkmanager

# 2. Ahora que tenemos los paquetes basicos para un etorno cli. Vamos a poner los ficheros de configuracion en su 
# sitio.
cp linuxDistrosSetups/arch-virtual/hostname /etc/hostname
cp linuxDistrosSetups/arch-virtual/vconsole.conf /etc/vconsole.conf
cp /etc/hosts /etc/hosts.noAdds
cp linuxDistrosSetups/arch-virtual/hosts /etc/hosts
# Llaves ssh para root (esto es temporal, cuando inicie sesion con mi usuario
# se pasaran estas llaves al directorio .ssh de mi usuario y se borraran de aqui
mkdir -p /root/.ssh
cp linuxDistrosSetups/arch-virtual/id_rsa* /root/.ssh/

# 3. Hacemos la configuracion del localtime
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime

# 4. Generamos las locales a partir del locale.gen
cp linuxDistrosSetups/arch-virtual/locale.gen /etc/locale.gen
locale-gen

# 5. Generamos la nueva imagen initramfs con los modulos de seguridad y lvm adecuados
cp linuxDistrosSetups/arch-virtual/mkinitcpio.conf /etc/mkinitcpio.conf
mkinitcpio -p linux

# 6. Hacemos la configuracion adecuada del gestor de arranque
grub-install --target=i386-pc --recheck --debug /dev/sdb
grub-mkconfig -o /boot/grub/grub.cfg

# 7. Configuracion de red. Usaremos networkmanager para ello
systemctl enable NetworkManager.service

# 8. Pass de root (archpartaadminpass)
passwd

# 10. Creacion de mi propio usuario
useradd -m -g users -G adm,disk,audio,video,optical,storage,power,scanner,network -s /bin/zsh jgl
echo pass para jgl
passwd jgl

# 10. Eliminacion del directorio de los ficheros de setup
rm -r /linuxDistrosSetups

# 12. Reiniciamos el sistema. Ahora sera cuando necesitemos levantar el entorno grafico. Pero esa parte sera a mano. 
echo todo terminado. Reiniciando para probar Presiona intro para continuar
read key
reboot

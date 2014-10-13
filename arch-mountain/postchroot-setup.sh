#!/bin/bash
# Este script se ejecuta dentro del entorno chroot. En el haremos las siguientes operaciones:

# Copia de los ficheros de configuracion
# Intalacion de los paquetes necesarios
# Configuracion de los repos de pacman
# Creacion del usuario jgl con new users y el fichero
# 
# En este punto tenemos que preparar el tema del cifrado de la particion home con la llave 

# 1. En este punto actualizamos repos e instalamos los paquetes necesarios para un entorno cli usable:
pacman -Syy
pacman -Syu
pacman -S vim openssh zsh git tmux weechat grub sudo links

# 2. Ahora que tenemos los paquetes basicos para un etorno cli. Vamos a poner los ficheros de configuracion en su 
# sitio.
cp linuxDistrosSetups/arch-mountain/hostname /etc/hostname
cp linuxDistrosSetups/arch-mountain/vconsole.conf /etc/vconsole.conf
cp linuxDistrosSetups/arch-mountain/crypttab /etc/crypttab

# 3. Hacemos la configuracion del localtime
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime

# 4. Generamos las locales a partir del locale.gen
cp linuxDistrosSetups/arch-mountain/locale.gen /etc/locale.gen
locale-gen

# 5. Generamos la nueva imagen initramfs con los modulos de seguridad y lvm adecuados
cp linuxDistrosSetups/arch-mountain/mkinitcpio.conf /etc/mkinitcpio.conf
mkinitcpio -p linux

# 6. Hacemos la configuracion adecuada del gestor de arranque
cp linuxDistrosSetups/arch-mountain/grub /etc/default/grub
grub-install --target=i386-pc --recheck --debug /dev/sdb
grub-mkconfig -o /boot/grub/grub.cfg

# 7. Configuracion de red. Pondremos de inicio una ip automatica
systemctl enable dhcpcd@enp3s0f2.service

# 8. Pass de root (archpartaadminpass)
passwd

# 9. Creacion de la particion /home, su cifrado swap etc.
# la swap se creara en el reinicio del sistema. 
# Ademas se montara en ramdisk el directorio /tmp y /var/tmp
mkdir -m 700 /etc/lukskeys
dd if=/dev/random of=/etc/lukskeys/home.key bs=1 count=4096000
cryptsetup luksFormart -v -s 512 /dev/vg0/lvhome /etc/lukskeys/home.key
cryptsetup -d /etc/lukskeys/home.key open --type luks /dev/vg0/lvhome homeCifrado
mkfs.ext4 /dev/mapper/homeCifrado


# 10. Creacion de mi propio usuario
useradd -m -g users -G adm,disk,audio,video,optical,storage,power,scanner,network -s /bin/zsh jgl
passwd jgl

# 10. Eliiminacion del directorio de los ficheros de setup
rm -r /linuxDistrosSetups

# 12. Reiniciamos el sistema. Ahora sera cuando necesitemos levantar el entorno grafico. Pero esa parte sera a mano. 
reboot



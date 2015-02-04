#!/bin/bash
# Este setup es solo valido para levantar una maquina virtual de archlinux. 
# esta maquina tiene una configuracion sencilla de un unico disco duro con solo
# 4 particiones:
# Tabla de parciones gpt
# sda1 --> uefi = 10MiB
# sda2 --> ext4 = 100MiB /boot
# sda3 --> ext4 = 9GiB /
# sda4 --> swap = 0.9GiB 

# 1. Formateamos la particion sda2 para /boot. Lo haremos con ext4
mkfs.ext4 /dev/sda2

# 2. Formateamos la particion sda3 para /. Lo haremos con ext4
mkfs.ext4 /dev/sda3

# 3. En este punto creamos y activamos la swap
mkswap /dev/sda4
swapon /dev/sda4

# 4. Montamos las particiones
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot

# 4. Instalamos los paquetes basicos. En este caso como vamos a desarrollar en esta maquina son necesarios tanto base como base-devel
# 4.1 metemos unos repos en condiciones. Para eso necesitamos el paquete reflector.
pacman -Syy
pacman -S reflector
reflector -a 8 -f 10 > /etc/pacman.d/mirrorlist
pacman -Syy
pacstrap /mnt base base-devel


# 5. En este punto generariamos el fstab con genfstab, pero en este caso vamos a restaurar el fichero original.
cp linuxDistrosSetups/arch-virtual/fstab /mnt/etc/fstab

# 6. Aqui nos chrooteamos. 
# Tendremos que partir la instalacion del setup en dos partes. La prechroot, que es esta que se encarga del tema del particionado, montaje
# de particiones etc. Y despues, la parte postchroot que se encargara de instalar los paquetes necesarios, y poner los ficheros de configuracion
# con los parametros adecuados. Es por ello que habra que clonear de nuevo el repo dentro del entorno chroot. En lugar de hacerlo con git, copiaremos
# el directorio completo dentro de /mnt. No podemos olvidar el eliminar todo el directorio del repo cuando terminemos.
cp -R linuxDistrosSetups /mnt 
arch-chroot /mnt /bin/bash -c "sh linuxDistrosSetups/arch-virtual/postchroot-setup.sh" 


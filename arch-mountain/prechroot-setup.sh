#!/bin/bash

# Este script se ejecuta al inicicio de la ejecucion de un livecd de archlinux
# Esto funciona solo para mi portatil. Es decir. El mountain
# Esta particionado de la siguiente manera:

# ssd = 120GB = sdb
# hd = 750GB = sda

# El ssd tiene 3 particiones:
# sdb1 = particion 10mb bios
# sdb2 = particion 200 MB para /boot
# sdb3 = particion del resto del espacio para lvm

# El Disco duro normal tiene 1 unica particion:
# sda1 = Todo el disco se usa para lvm

# Configuracion de lvm
# sda1 y sdb3 son physical volumes 
# Tenemos el vg0 que es un grupo que contiene a sdb3 y sda1
#
# El particionado que se ha hecho del volumen es el siguiente:
#
# /dev/vg0/lvroot = 20GiB = cifrado con luks. passphrase ="di amigo y entra: mellon"  se monta en /dev/mapper/rootCifrado
# /dev/vg0/lvhome = 600 GiB cifrado con luks, con una llave que se crea con dd y se almacena en /etc/lukskeys/home.key  se monta en /dev/mapper/homeCifrado
# /dev/vg0/lvswap = 16 GiB cifrado con luks con una llave aleatoria temporal. (cryptab se encarga de ello) se monta en /dev/mapper/swapCifrado

# Esquema de particiones:
# /dev/sdb2 ------------------> /boot
# /dev/mapper/rootCifrado ----> /
# /dev/mapper/homeCifrado ----> /home
# Ramdisk --------------------> /tmp
# Ramdisk --------------------> /var/tmp

# No se usa todo el disco para que si necesitamos mas espacio en el futuro para alguna de las particiones, podamos utilizarlo para dicho
# ampliar la que necesitemos.

# Las siguientes instrucciones se ejecutan para dejar el sistema correctamente particionado y formateado

# 1. Formateamos la particion sda2 para /boot. Lo haremos con ext4
mkfs.ext4 /dev/sdb2

# 2. Abrimos /dev/vg0/lvroot, lo mapeamos a rootCifrado y lo formateamos con ext4
cyptsetup open --type luks /dev/vg0/lvroot rootCifrado
mkfs.ext4 /dev/mapper/rootCifrado

# 3. Montamos las particiones
mount /dev/mapper/rootCifrado /mnt
mkdir /mnt/boot
mount /dev/sdb2 /mnt/boot

# 4. Instalamos los paquetes basicos. En este caso como vamos a desarrollar en esta maquina son necesarios tanto base como base-devel
# 4.1 metemos unos repos en condiciones. Para eso necesitamos el paquete reflector.
pacman -Syy
pacman -S reflector
reflector -a 8 -f 10 > /etc/pacmand.d/mirrorlist
pacman -Syy
pacstrap /mnt base base-devel


# 5. En este punto generariamos el fstab con genfstab, pero en este caso vamos a restaurar el fichero original.
cp linuxDistrosSetups/arch/fstab /mnt/etc/fstab

# 6. Aqui nos chrooteamos. 
# Tendremos que partir la instalacion del setup en dos partes. La prechroot, que es esta que se encarga del tema del particionado, montaje
# de particiones etc. Y despues, la parte postchroot que se encargara de instalar los paquetes necesarios, y poner los ficheros de configuracion
# con los parametros adecuados. Es por ello que habra que clonear de nuevo el repo dentro del entorno chroot. En lugar de hacerlo con git, copiaremos
# el directorio completo dentro de /mnt. No podemos olvidar el eliminar todo el directorio del repo cuando terminemos.
cp -R linuxDistrosSetups /mnt 
arch-chroot /mnt /bin/bash -c "sh linuxDistrosSetups/arch/postchroot-setup.sh" 


<h1>Setup para una instalacion de archlinux en el mountain</h1>
<p>Estos ficheros de configuracion son exclusivos para una instalacion de arch linux en el ordenador portatil mountain</p>

<h2> 1. Particionado de los discos y esquemas de como esta particionado este sistema </h2>
<h3>Esquema de particionado de los discos duros</h3>
sda = disco duro mecanico de 750 GB
sdb = disco ssd de 120 GB

Tabla de particiones gpt para ambos discos

sda1 = 750GB = sistema de ficheros lvm2

sdb1 = 10 MiB = sistema de ficheros para bios
sdb2 = 200 MiB = sistema de ficheros ext4 para /boot
sdb3 = resto del disco = sistema de ficheros lvm2

<h3>Esquema del lvm</h3>
<p>
	sdb3 = pyshical volume
	sda1 = pyshical volume
</p>

<p>
	vg0 = volume group = sdb3 + sda1 = 810.2 GiB
	/dev/vg0/lvroot = 20 GiB 
	/dev/vg0/lvhome = 600 GiB 
	/dev/vg0/lvswap = 16 GiB 
	El resto del espacio no se utiliza y se deja como reserva para posibles usos futuros.
</p>
<h4>Volumenes cifrados y como se cifran</h4>
<h5>/dev/vg0/lvroot</h5>
<p>
<ul>
    <li>Es el volumen donde se almacenara la raiz del sistema. </li>
    <li>Este volumen lleva un cifrado luks protegido por passphrase.</li>
    <li>Su passphrase es: "di amigo y entra: mellon" sin las comillas. </li>
    <li>Se mapea en /dev/mapper/rootCifrado</li>
</ul>
 
Es necesario el desbloqueo de esta unidad para acceder a toda la informacion del disco. 
Incluso a los ficheros almacenados en la particion /home. Porque esa particion tambien esta cifrada 
pero utilizando una llave de 4Mib que se almacena en la raiz del sistema. 
</p>

<h5>/dev/vg0/lvhome</h5>
<p>
<ul>
    <li>Es el volumen donde se almacenara el directorio /home del sistema. </li>
    <li>Este volumen lleva un cifrado luks protegido por Llave.</li>
    <li>La llave se genera de forma aleatoria con /dev/random. Tiene una longitud de 4MiB y se almacena en /etc/lukskeys/home.key </li>
    <li>Se mapea en /dev/mapper/homeCifrado</li>
</ul>
 
Es necesario el desbloqueo de esta unidad para acceder a toda la informacion de los usuarios del sistema 
</p>

<h5>/dev/vg0/lvswap</h5>
<p>
Utilizamos una swap de 16 GiB porque es la cantidad de ram que disponemos, y es lo mas seguro para hibernar el sistema con un minimo de seguridad 
<ul>
    <li>Es el volumen donde se almacenara la swap del sistema. </li>
    <li>Este volumen lleva un cifrado luks protegido por una llave temporal que se genera en cada reinicio..</li>
    <li>La llave se genera de forma aleatoria con /dev/random. No tiene tamanio fijo y no se almacena nunca. </li>
    <li>Se mapea en /dev/mapper/swapCifrado</li>
</ul>
</p>

<h3>Puntos de montaje del sistema</h3>
/dev/mapper/rootCifrado ------> /
/dev/mapper/homeCifrado ------> /home
/dev/mapper/swapCifrado ------> swap
ramdisk ----------------------> /tmp
ramdisk ----------------------> /var/tmp


<h2> 2. Scripts de setup del sistema</h2>
La instalacion de arch tiene dos partes bien diferenciadas. Una previa al chrooting, y otra posterior a dicho chrooting. 
<p>
La diferencia entre ambas partes es que los pasos a realizar antes del chrooting tienen que ver con el el sistema de pariticionado de los discos duros
y de como se organizaran las particiones. No tiene porque hacerse todo el setup de las particiones durante la parte del prechrootin, tal y como queda patente
en el setup que nos ocupa aqui. Y en el que la parte de la particion /home y de la swap se hacen a posteriori dentro del chroot. 
</p>

<p>
Es por ello que son necesarios 2 scripts distintos:
<ol type="1">
   <li>prechroot-setup.sh</li>
   <li>postchroot-setup.sh</li>
</p>

<h3>prechroot-setup.sh</h3>
<p>
Este script es el que se encarga de formatear las particiones de los discos duros. </br>
No se va a volver a crear ninguna particion. Solo se va a reformatear todo. </br>
El volumen lvroot no se va a volver a formatear con luks, pues ya tiene ese formato. No es necesario</br>
volver a hacerlo. 
</p>
<p>
El volumen lvhome si que se requiere de un nuevo formateo con luks porque la llave que se usa para su cifrado se </br>
crea de forma dinamica en cada instalacion. Por ello primero creamos la llave y luego formateamos con luks usando esa llave.
</p>
<h4> 1. Formateo de la particion /boot </h4>
En este setup la particion que se dedica a boot es la sdb2. Tiene 200MiB de espacio. Y se formatea como ext4.

<h4> 2. Preparacion y formateo de la particon root</h4>
Aqui ya hacemos uso de un volumen de nuestro lvm. El volumen es lvmroot y esta cifrado con luks. 
Su passphrase es: di amigo y entra: mellon
lo mapeamos a /dev/mapper/rootCifrado
Ahora formateamos /dev/mapper/rootCifrado con ext4 y lo montamos en /mnt

<h4> 3. Montaje de particiones</h4>
Poco que contar aqui. Ya que tenemos las particiones creadas y correctamente formateadas solo tenemos que 
montarlas. La particion /dev/mapper/rootCifrado la montamos en /mnt 
Una vez que hayamos montado rootCifrado. Creamos el directorio /mnt/boot, y montamos en ese directorio
la particion /dev/sdb2. 

<h4> 4. Instalacion del sistema base</h4>
Para instalar el sistema base necesitaremos antes tener unos repos como dios manda para tener
la maxima velocidad y tambien unos paquetes actualizados. 
Para ello instalamos en el sistema live la herramienta <strong>reflector</strong>. Esta herramienta nos permite 
tener una lista de repos ordenada por varios criterios, como los N que se actualizaron en las ultimas X horas. y de esos
Elegir los Z mas rapidos para nosotros. 

Despues generarmos un /etc/pacman.d/mirrorlist con esa herramienta. Y ya tendremos en nuestro nuevo sistema unos repos como dios
manda porque se copiara la configuracion para nuestro nuevo sistema. 

Ademas no solo instalamos el sistema base, si no que tambien instalaremos el sistema base-devel para tener herramientas de desarrollo.
que para algo soy programador >D 

<h4> 5. Copia del fstab, y del repo setup al nuevo entorno</h4>
En este punto estamos a punto de hacer chroot al nuevo entorno. 
Lo que hacemos es poner el el nuevo entorno el fstab que corresponde a esta instalacion. 
En el especificamos ademas de las particiones que hemos creado durante todo el proceso anterior, la particion /home que crearemos mas adelante, 
definimos la swap, y ademas ya creamos los ramdisks para /tmp y /var/tmp. 

Ademas, necesitaremos el el repo en el nuevo entorno, por lo que copiaremos el directorio contenedor completo al nuevo repo. 

<h4> 6. Chroot al nuevo sistema</h4>
Aqui hacemos chroot al nuevo sistema, pero no lo hacemos tal y como indica la guia. Si no que  como ahora tenemos en la nueva raiz el repo entero
le diremos que cuando se haga chroot, ejecuta el script de postchroot. El postchroot-setup.sh. Que se encargara ya de instalar las herramientas 
necesarias, poner los ficheros de configuracion correctos y de formatear con luks el volumen logico dedicado a home, para luego reformatearlo en 
ext4 para usarlo como dios manda. Ademas hara lo necesario para usar la swap de forma cifrada. 



<h3>prechroot-setup.sh</h3>
Este script es ejecutado al entrar en el chroot. Se ejecuta automaticamente por el otro script del que venimos. 
A continuacion ponemos en orden las cosas que realiza este script
<h4> 1. Actualizacion del sistema e instalacion de paquetes basicos para entorno cli</h4>
Instalamos algunos paquetes basicos para usar el sistema con la terminal. Como links, vim, git, zsh etc.

<h4> 2. Copia de los ficheros de configuracion</h4>
En este punto pondremos en su sitio el fichero de hostname y vconsole. 

<h4> 3. Localtime</h4>
Ponemos la zona horaria adecuada al sistema mediante el enlace simbolico. 

<h4> 4. Locales</h4>
Aqui ponemos el fichero locale.gen con los locales que nos interesan ya descomentados, 
y los generamos con locale-gen

<h4> 5. mkinitcpio</h4>
Metemos el fichero personalizado de mkinitcpio.conf con los modulos de lvm2 y encrypt activados 
Ademas generamos la nueva imagen del kernel con esos modulos cargados.

<h4> 6. Grub</h4>
Copiamos el fichero adecuado para el /etc/default/grub que ya tenemos con los parametros del kernel correctos.
Instalamos el grub en el mbr del ssd. (sdb) y generamos la configuracion.

<h4> 7. Configuracion de red</h4>
Activamos dhcpcd para la interface de red ethernet cableada. Si necesito wifi se hara mas adelante. 
Con esto haremos que systemd nos cargue el modulo dhcp para que tengamos una ip de forma automatica
sin complicaciones.

<h4> 8. Cambio de la pass para el usuario root</h4>
Aqui ponemos una nueva contrasenia para root. Sugiero utilizar archpartaadminpass

<h4> 9. Particion home y swap cifrados</h4>
A la hora de hacer setup de los discos duros dejamos preparados dos volumenes logicos dentro del lvm para estas dos partes del sistema
el swap y home. 
Lo que vamos a hacer es crear la llave con la que vamos a cifrar la particion home. Usaremos para ello /dev/random de un tamanio de 4MiB 
y almacenaremos dicha llave en /etc/lukskeys/home.key
Despues daremos formato luks a /dev/vg0/lvhome utilizando la llave creada anteriormente.
Mapeamos el volumen cifrado en /dev/mapper/homeCifrado.

Para la swap no tendremos que hacer nada, pues al haber copiado ya el crypttab  a /etc/crypttab y tener tambien el fichero /etc/fstab 
con las configuraciones adecuadas, no habra que hacer nada extra.

<h4> 10. Creacion de mi usuario</h4>
En este punto creo mi usuario jgl que pertenecera a los grupos clasicos. 

<h4> 11. Eliminacion de los ficheros de configuracion</h4>
Aqui eliminamos el directorio que contiene el repo con todos los ficheros de configuracion y demas
para no dejar rastro

<h4> 12. Reinicio del sistema</h4>
Reiniciamos el sistema para que todos los cambios surtan efecto.

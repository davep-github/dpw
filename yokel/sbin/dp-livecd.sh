#!/bin/sh -
# Copyright 2001 2002 Edson Brandi <ebrandi.home@uol.com.br>
# All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY EDSON BRANDI ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT EDSON BRANDI BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.

# Check UID
#if [ "`id -u`" != "0" ]; then
#        echo "Sorry, this must be done as root."
#        exit 1
#fi

DIALOG=${DIALOG=/usr/bin/dialog}

idioma() {

rm /tmp/opcao_*

tempfile=`/usr/bin/mktemp -t checklist`

dialog --menu "FreeBSD LiveCD - Choose your Language:" 12 60 4 \
        Br "Portuguese / Portugues" \
        En "English / Ingles" \
        Q "Quit / Sair" \
2> $tempfile 
        
opcao_idioma=`cat $tempfile`

case ${opcao_idioma} in
     Br)
     if [ -f ./lang/livecd_Br ] ; then
     . ./lang/livecd_Br
     touch /tmp/opcao_Br
     configurar
     . ./config
     . ./lang/livecd_Br
     verifica_config
     else
     echo "Idioma selecionado nao disponivel"
     exit 1
     fi
     ;;
     En)
     if [ -f ./lang/livecd_En ] ; then
     . ./lang/livecd_En
     touch /tmp/opcao_En
     configurar
     . ./config
     . ./lang/livecd_En
     verifica_config
     else
     echo "Language not Availble"
     exit 1
     fi
     ;;
     *)
     exit 1
     ;;
esac

}

# This function will create the directories structure that LiveCD will need
# They will all be created under $CHROOTDIR
prepara_diretorios() {

# check if $CHROOTDIR exists, if so, take schg flag out away from executable
# files and remove the directories.
if [ -r $CHROOTDIR ]; then
        chflags -R noschg $CHROOTDIR/
        rm -rf $CHROOTDIR/
fi

# Creates the directory that will be LiveCD's root 
mkdir -p $CHROOTDIR 

# Creates LiveCD related directories

mtree -deU -f $LIVEDIR/files/LIVECD.raiz.dist -p $CHROOTDIR >> $LIVEDIR/log
#mkdir /var/spool/clientmqueue

# Creates $CHROOTDIR/dist directory if $LIVECDINSTALL variable value is set to 1
if [ $LIVECDINSTALL -eq 1 ]; then
   mkdir $CHROOTDIR/dist
fi

# Shows dialog information box about the directories creation.
dialog --title "FreeBSD LiveCD" --msgbox "$c_dialogo_1" 5 60

}

# warning routines
aviso() {
dialog --title "FreeBSD LiveCD" --infobox "$g_dialogo_4" -1 -1
echo "$g_dialogo_3"
exit 1
}

# This function makes buildworld
gera_binarios() {

# Shows dialog asking for buildworld confirmation. If the user does not confirm
# we will return execution to main_dialog.
dialog --title "FreeBSD LiveCD" --yesno "$g_dialogo_1" 6 70 

case $? in
     1)
     echo "$g_dialogo_3"
     exit 1
     ;;
     255)
     echo "$g_dialogo_3"
     exit 1 
     ;;
     0)
     # Makes buildworld, creating logs under $LIVEDIR/log
     cd /usr/src && make buildworld >> $LIVEDIR/log || aviso

     # Shows dialog telling the user that the buildworld process was done.
     dialog --title "FreeBSD LiveCD" --msgbox "$g_dialogo_2" 5 60
     cd $LIVEDIR
     ;;
esac
}

# This function distributes binaries under $CHROOTDIR
distribui_binarios() {

cd /usr/src/etc && make distrib-dirs DESTDIR=$CHROOTDIR >> $LIVEDIR/log || aviso
cd /usr/src/etc && make distribution DESTDIR=$CHROOTDIR >> $LIVEDIR/log || aviso
       
# Copies /etc/resolv.conf to /etc under LiveCD ;-) 

if [ -f /etc/resolv.conf ]; then 
     cp -p /etc/resolv.conf $CHROOTDIR/etc
fi

cd /usr/src/ && make installworld DESTDIR=$CHROOTDIR >> $LIVEDIR/log || aviso

mkdir $CHROOTDIR/bootstrap
cp -p $CHROOTDIR/sbin/mount $CHROOTDIR/bootstrap
cp -p $CHROOTDIR/sbin/umount $CHROOTDIR/bootstrap

# rebuilds sysinstall
cd /usr/src/release/sysinstall/
make clean >> $LIVEDIR/log
make >> $LIVEDIR/log
make install >> $LIVEDIR/log

# copies /stand to LiveCD's root
tar -cf - -C /stand . | tar xpf - -C $CHROOTDIR/stand/
# sysinstall's moved under 5.x
cp /usr/obj/sundry/usr.src-RELENG_5_x/usr.sbin/sysinstall/sysinstall \
    $CHROOTDIR/stand

# Creates distribution file that allows one to use LiveCD as an installation media.

if [ $LIVECDINSTALL -eq 1 ]; then
   cp $LIVEDIR/files/fstab.install $CHROOTDIR/dist
   cp /usr/src/etc/rc $CHROOTDIR/dist
fi

mkdir  $CHROOTDIR/scripts/lang
cp  $LIVEDIR/lang/*  $CHROOTDIR/scripts/lang
rm  $CHROOTDIR/scripts/lang/livecd_*

# Tells the user that the whole process was done ;-)
dialog --title "FreeBSD LiveCD" --msgbox "$d_dialogo_1" 5 60

cd $LIVEDIR
}

# Now, we will patch GENERIC accordingly to our changes and build LIVECD from it
gera_kernel() {

rm -rf $COMPILEDIR >> $LIVEDIR/log

# Copies GENERIC to LIVECD
#cp $KERNELDIR/GENERIC $KERNELDIR/LIVECD >> $LIVEDIR/log && \

# Patch LIVECD up
#cd $KERNELDIR && patch -p < $LIVEDIR/files/patch_generic  >> $LIVEDIR/log && \

# Lets build the kernel 
#config LIVECD  >> $LIVEDIR/log && cd $COMPILEDIR && make depend  >> $LIVEDIR/log && \
#make  >> $LIVEDIR/log && make install DESTDIR=$CHROOTDIR  >> $LIVEDIR/log || aviso

# Creates the Kernel to be installed if LiveCD will be used as instalation mediao.
if [ $LIVECDINSTALL -eq 1 ]; then
#   cd /usr/src/sys/i386/conf 
#   config GENERIC >> $LIVEDIR/log && cd /usr/src/sys/compile/GENERIC && make depend >> $LIVEDIR/log && make >> $LIVEDIR/log && make install DESTDIR=$CHROOTDIR/dist  >> $LIVEDIR/log

mtree -c -i -p $CHROOTDIR -k gname,md5digest,mode,nlink,uname,size,link,type > /tmp/LiveCD.mtree
mv  /tmp/LiveCD.mtree $CHROOTDIR/dist

fi

# Tells the user that this process was done.
dialog --title "FreeBSD LiveCD" --msgbox "$k_dialogo_1" 5 60

cd $LIVEDIR

}

# Now we will patch all changed files under /etc
alterar_etc() {

cd $CHROOTDIR/etc && patch -p < $LIVEDIR/files/patch_rc || aviso

if [ -f /tmp/opcao_Br ]
then
cp $LIVEDIR/files/rc.live_Br $CHROOTDIR/etc/rc.live
else
cp $LIVEDIR/files/rc.live_En $CHROOTDIR/etc/rc.live
fi

cp $LIVEDIR/files/rc.conf $CHROOTDIR/etc
cp $LIVEDIR/files/fstab   $CHROOTDIR/etc
cp $LIVEDIR/files/motd   $CHROOTDIR/etc

cd $CHROOTDIR/dev

# We will need some devices if we intend to have virtual nodes, right?
# so lets make them ;-)
for i in 0 1 2 3 4 5 6 7 8 9
 do
   ./MAKEDEV vn$i
done;

# Lets copy all scripts to LiveCD's /
cp -Rp $LIVEDIR/scripts $CHROOTDIR/
rm -rf $CHROOTDIR/scripts/CVS

# Lets tell the user that /etc files were patched
dialog --title "FreeBSD LiveCD" --msgbox "$e_dialogo_1" 5 60

cd $LIVEDIR

}

# This function generates ISOs and files to populate MFS
gera_iso() {

# Lets create the .tgz files that will be used to mount MFS
cd $CHROOTDIR
tar cvzfp mfs/etc.tgz etc >> $LIVEDIR/log
tar cvzfp mfs/dev.tgz dev >> $LIVEDIR/log
tar cvzfp mfs/root.tgz root >> $LIVEDIR/log
tar cvzfp mfs/local_etc.tgz usr/local/etc >> $LIVEDIR/log

# Copies all the necessary files to make a bootable CD
cp $LIVEDIR/files/boot.catalog $CHROOTDIR/boot >> $LIVEDIR/log
cd $CHROOTDIR

# Now we make a Bootable ISO without emulating floppy 2.8 Mb boot style.
if [ -f /usr/local/bin/mkisofs ] ; then

        /usr/local/bin/mkisofs -b boot/cdboot -no-emul-boot -c boot/boot.catalog  -r -J -h -V LiveCD -o $LIVEISODIR/LiveCD.iso . >> $LIVEDIR/log || aviso
	dialog --title "FreeBSD LiveCD" --msgbox "$i_dialogo_1" 5 60

elif then
        
	dialog --title "FreeBSD LiveCD" --msgbox "$i_dialogo_2" 5 75
	#
	# If mkisofs does not exist, we will install it ;-)
	cd /usr/ports/sysutils/mkisofs
	make >> $LIVEDIR/log
	make install >> $LIVEDIR/log
	make clean >> $LIVEDIR/log
	#
	dialog --title "FreeBSD LiveCD" --msgbox "$i_dialogo_3" 5 75
	#
	# makes ISO image.
	/usr/local/bin/mkisofs -b boot/cdboot -no-emul-boot -c boot/boot.catalog  -r -J -h -V LiveCD -o $LIVEISODIR/LiveCD.iso . >> $LIVEDIR/log || aviso
	dialog --title "FreeBSD LiveCD" --msgbox "$i_dialogo_1" 5 60

fi

# If ISO image was previously created, we tell the user it was done.
if [ -f $LIVEISODIR/LiveCD.iso ]; then
	dialog --title "FreeBSD LiveCD" --msgbox "$i_dialogo_4" 5 60
fi
 
cd $LIVEDIR

}

# Burn the house down! ;-)
# gee, sorry i was just envolved with garbage's lyrics...
# Burns the CD Image.
grava_iso() {

burncd -f $CDRW -s 8 -e data $LIVEISODIR/LiveCD.iso fixate >> $LIVEDIR/log || aviso
dialog --title "FreeBSD LiveCD" --msgbox "$i_dialogo_5" 5 60

cd $LIVEDIR

}

# Let's check if user has already confirm'd his options on config file

configurar() {
$DIALOG --title "FreeBSD LiveCD" --clear --inputbox "$config_1" 8 70 "`pwd`" 2> /tmp/input.tmp.$$
retval=$?

LIVEDIR=`cat /tmp/input.tmp.$$`
rm /tmp/input.tmp.$$

# We will TRAP to allow the user to abort the process...
case $retval in
  0)
    echo "LIVEDIR=$LIVEDIR" > ./config
    ;;
  1)
    echo "Cancel pressed."
    exit 1
    ;;
  255)
    echo "ESC pressed."
    exit 1
    ;;
esac

$DIALOG --title "FreeBSD LiveCD" --clear --inputbox "$config_2" 8 70 "/usr/live_root" 2>/tmp/input.tmp.$$
retval=$?

CHROOTDIR=`cat /tmp/input.tmp.$$`
rm /tmp/input.tmp.$$

# Trap again ;)
case $retval in
  0)
    echo "CHROOTDIR=$CHROOTDIR" >> ./config
    ;;
  1)
    echo "Cancel pressed."
    exit 1
    ;;
  255)
    echo "ESC pressed."
    exit 1
    ;;
esac

$DIALOG --title "FreeBSD LiveCD" --clear --inputbox "$config_3" 8 70 "/usr" 2>/tmp/input.tmp.$$
retval=$?

LIVEISODIR=`cat /tmp/input.tmp.$$`
rm /tmp/input.tmp.$$

# One more Trap, with the same purpose.
case $retval in
  0)
    echo "LIVEISODIR=$LIVEISODIR" >> ./config
    ;;
  1)
    echo "Cancel pressed."
    exit 1
    ;;
  255)
    echo "ESC pressed."
    exit 1
    ;;
esac

$DIALOG --title "FreeBSD LiveCD" --clear --yesno "$config_4" 8 70

case $? in
  0)
    echo "LIVECDINSTALL=1" >> ./config
    ;;
  1)
    echo "LIVECDINSTALL=0" >> ./config
    ;;
  255)
    echo "ESC pressed."
    exit 1
    ;;
esac

$DIALOG --title "FreeBSD LiveCD" --clear --yesno "$config_5" 8 70 

case $? in
  0)
     $DIALOG --title "FreeBSD LiveCD" --clear --inputbox "$config_6" 8 70 "/dev/acd0c" 2>/tmp/input.tmp.$$
     retval=$?

     CDRW=`cat /tmp/input.tmp.$$`
     rm /tmp/input.tmp.$$

     # Trap to allow user to abort process...
     case $retval in
     0)
     echo "CDRW=$CDRW" >> ./config
     ;;
     1)
     echo "Cancel pressed."
     exit 1
     ;;
     255)
     echo "ESC pressed."
     exit 1 
     ;;
     esac 
     ;;
  1)
    echo "CDRW=/dev/null" >> ./config
    ;;
  255)
    echo "ESC pressed."
    exit 1
    ;;
esac

echo "KERNELDIR=/usr/src/sys/i386/conf" >> ./config
echo "COMPILEDIR=/usr/src/sys/compile/LIVECD" >> ./config

}

# checks for config file
verifica_config() {

if [ -f ./config ] ; then
   . ./config
fi

   dialog --title "FreeBSD LiveCD" --yesno "$v_dialogo_1" 18 70 || exit 0
   touch ./config.ok


}

# Lists the packages that are actually installed at the local B0X and asks the
# user if he wants to install any of those packages.
pacotes() {

DIALOG=${DIALOG=/usr/bin/dialog}

# Now, we create packages.sh that will be used to list all available applications
# as a reference to the user.

echo "$DIALOG --title \"FreeBSD LiveCD - $p_dialogo_1\" --clear \\" > $LIVEDIR/packages.sh
echo "--checklist \"$p_dialogo_2" >> $LIVEDIR/packages.sh
echo "$p_dialogo_3 -1 -1 10 \\" >> $LIVEDIR/packages.sh
for i in `ls -1 /var/db/pkg`; do echo "\"$i\" \"\" off \\" >> $LIVEDIR/packages.sh ; done
echo "2> /tmp/checklist.tmp.\$\$" >> $LIVEDIR/packages.sh
echo "retval=\$?" >> $LIVEDIR/packages.sh
echo "choice=\`cat /tmp/checklist.tmp.\$\$\`" >> $LIVEDIR/packages.sh
echo "rm -f /tmp/checklist.tmp.\$\$" >> $LIVEDIR/packages.sh
echo "case \$retval in" >> $LIVEDIR/packages.sh
echo "  0)" >> $LIVEDIR/packages.sh
echo "for i in \`echo \$choice | sed -e 's/\"/#/g'\`; do pkg_create -b \`echo \$i | awk -F\"#\" '{print \$2}'\`; done ;;" >> $LIVEDIR/packages.sh
echo "  1)" >> $LIVEDIR/packages.sh
echo "echo  \"Cancel pressed.\";;" >> $LIVEDIR/packages.sh
echo "  255)" >> $LIVEDIR/packages.sh
echo "[ -z \"\$choice\" ] || echo \$choice ;" >> $LIVEDIR/packages.sh
echo "echo \"ESC pressed.\";;" >> $LIVEDIR/packages.sh
echo "esac" >> $LIVEDIR/packages.sh
echo $LIVEDIR/packages.sh

# Runs packages.sh
/bin/sh $LIVEDIR/packages.sh

# So, we install the packages that were chose by the User ;-)
for i in `ls -1 *.tgz`; do /usr/sbin/pkg_add -vRf -p $CHROOTDIR/usr/local $i >> $LIVEDIR/packages.log ; done

# Checks for First Level dependencies on the package, and install them.
cat $LIVEDIR/packages.log | grep depends | awk -F"\`" '{print $3}' | awk -F"'" '{print $1}' > $LIVEDIR/tmp_
for i in `cat $LIVEDIR/tmp_ `; do /usr/sbin/pkg_create -b $i ; done
for i in `cat $LIVEDIR/tmp_ `; do /usr/sbin/pkg_add -vRf -p $CHROOTDIR/usr/local $i.tgz >> $LIVEDIR/packages2.log; done

# Checks for Second Level dependencies on the package, and install them.
# Second Level dependencies are dependecies' dependencies.
cat $LIVEDIR/packages2.log | grep depends | awk -F"\`" '{print $3}' | awk -F"'" '{print $1}' > $LIVEDIR/tmp2_
for i in `cat $LIVEDIR/tmp2_ `; do /usr/sbin/pkg_create -b $i ; done
for i in `cat $LIVEDIR/tmp2_ `; do /usr/sbin/pkg_add -Rf -p $CHROOTDIR/usr/local $i.tgz; done

# Removes temporary files ;)
rm $LIVEDIR/packages.log $LIVEDIR/packages2.log
rm  $LIVEDIR/packages.sh
rm $LIVEDIR/tmp_ $LIVEDIR/tmp2_
rm  $LIVEDIR/*.tgz

# Tells the user that the selected packages were installed.
dialog --title "FreeBSD LiveCD" --msgbox "$p_dialogo_4" 5 70
}

# This is the Main Dialog menu :)
main_dialog() {

# exports config file's defined variables
if [ -f ./config ] ; then
   . ./config
fi

if [ -f /tmp/opcao_Br ] ; then
   . ./lang/livecd_Br
fi

if [ -f /tmp/opcao_En ] ; then
   . ./lang/livecd_En
fi

# Defines the temporary file
tempfile=`/usr/bin/mktemp -t checklist`

# Makes main dialog menu...
  log "main_dialog()"
    dialog --menu "FreeBSD LiveCD Tool Set by FUG-BR -- (21 jun 2002)" 18 70 11 \
      1 "$m_dialogo_p" \
      2 "$m_dialogo_g" \
      3 "$m_dialogo_d" \
      4 "$m_dialogo_k" \
      5 "$m_dialogo_e" \
      6 "$m_dialogo_c" \
      7 "$m_dialogo_i" \
      8 "$m_dialogo_f" \
      9 "$m_dialogo_q" \
2> $tempfile 
        
opcao=`cat $tempfile`

case ${opcao} in
     1)
     prepara_diretorios
     ;;
     2)
     echo "Skipping buildworld..." # gera_binarios
     cd $LIVEDIR
     ;;
     3)
     distribui_binarios
     ;;
     4)
     gera_kernel
     ;;
     5)
     alterar_etc
     ;;
     6)
     pacotes
     ;;
     7)
     gera_iso 
     ;;
     8)
     grava_iso
     ;;
     9)
     rm $tempfile
     rm $LIVEDIR/config.ok
     rm /tmp/opcao_*
     exit 0
     ;;
     *) 
     exit 0
     ;;
esac
}

# Makes the Loop :) 
while true
do
if [ -f ./config.ok ] ; then
	main_dialog
elif then
	idioma
fi
done

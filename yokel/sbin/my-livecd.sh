#!/bin/sh

cd /usr/src/etc
export CHROOTDIR=/usr/yokel/live_root
make distrib-dirs DESTDIR=$CHROOTDIR
make distribution DESTDIR=$CHROOTDIR
cp -p /etc/resolv.conf $CHROOTDIR/etc
echo $CHROOTDIR
cd /usr/src/ && make installworld DESTDIR=$CHROOTDIR 2>&1 | tee /tmp/livecd.log
mkdir $CHROOTDIR/bootstrap
cp -p $CHROOTDIR/sbin/mount $CHROOTDIR/bootstrap
cp -p $CHROOTDIR/sbin/umount $CHROOTDIR/bootstrap
cd /usr/src/release/sysinstall/	        # for 4.x
cd /usr/src/usr.sbin/sysinstall/	# for 5.x
# only makable in 5.x under 4.x via buildworld due to header file diffs.
#make clean
#make
make install
# ?? will cross-stand work?
tar -cf - -C /stand . | tar xpf - -C $CHROOTDIR/stand/
mkdir $CHROOTDIR/stand
tar -cf - -C /stand . | tar xpf - -C $CHROOTDIR/stand/
mkdir  $CHROOTDIR/scripts/lang
mkdir -p $CHROOTDIR/scripts/lang
export LIVEDIR=/sundry/build/livecd/livecd
cp  $LIVEDIR/lang/*  $CHROOTDIR/scripts/lang
rm  $CHROOTDIR/scripts/lang/livecd_*
cd $LIVEDIR
source ./config
echo $COMPILEDIR
rm -rf $COMPILEDIR
cp $KERNELDIR/GENERIC $KERNELDIR/LIVECD
cd $KERNELDIR && patch -p < $LIVEDIR/files/patch_generic
config LIVECD && cd $COMPILEDIR && make depend && make && make install DESTDIR=$CHROOTDIR
cd $LIVEDIR
cd $CHROOTDIR/etc && patch -p < $LIVEDIR/files/patch_rc
if [ -f /tmp/opcao_Br ]; then cp $LIVEDIR/files/rc.live_Br $CHROOTDIR/etc/rc.live; else cp $LIVEDIR/files/rc.live_En $CHROOTDIR/etc/rc.live; fi
cat $CHROOTDIR/etc/rc.live
cp $LIVEDIR/files/rc.conf $CHROOTDIR/etc
cp $LIVEDIR/files/fstab   $CHROOTDIR/etc
cp $LIVEDIR/files/motd   $CHROOTDIR/etc
cd $CHROOTDIR/dev
for i in 0 1 2 3 4 5 6 7 8 9;  do    ./MAKEDEV vn$i; done;
ls vn*
cp -Rp $LIVEDIR/scripts $CHROOTDIR/
rm -rf $CHROOTDIR/scripts/CVS
cd $LIVEDIR
ls
/usr/local/bin/mkisofs -b boot/cdboot -no-emul-boot -c boot/boot.catalog  -r -J -h -V LiveCD -o $LIVEISODIR/LiveCD.iso
cd $CHROOTDIR
tar cvzfp mfs/etc.tgz etc
ls mfs
mkdir mfs
tar cvzfp mfs/etc.tgz etc
ls mfs
tar cvzfp mfs/dev.tgz dev
tar cvzfp mfs/root.tgz root
cd $CHROOTDIR
tar cvzfp mfs/local_etc.tgz usr/local/etc
ls
ls usr/local
cp $LIVEDIR/files/boot.catalog $CHROOTDIR/boot
cd $CHROOTDIR
/usr/local/bin/mkisofs -b boot/cdboot -no-emul-boot -c boot/boot.catalog  -r -J -h -V LiveCD -o $LIVEISODIR/LiveCD.iso .
# /usr/local/bin/mkisofs -b boot/cdboot -no-emul-boot -c boot/boot.catalog -r -J -h -V LiveCD -o $LIVEISODIR/LiveCD.iso .
ls $LIVEISODIR
mkdir -p $LIVEISODIR
# /usr/local/bin/mkisofs -b boot/cdboot -no-emul-boot -c boot/boot.catalog -r -J -h -V LiveCD -o $LIVEISODIR/LiveCD.iso .
/usr/local/bin/mkisofs -b boot/cdboot -no-emul-boot -c boot/boot.catalog -r -J -h -V LiveCD -o $LIVEISODIR/LiveCD.iso .
ls -l $LIVEISODIR
cd ../li
cd ..
ls
cd livecd.iso.d
ls
hd LiveCD.iso | hd | head
hd LiveCD.iso | hd | head -100
hd /boot/cdboot 
dirs
cd ../live_cd
cd ../live_root
ls
hd boot/cdboot
hd LiveCD.iso | head -100
cd ../livecd.iso.d/
ls
hd LiveCD.iso | head -100
history


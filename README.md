Android Build Stack
==================

Work in progress :)

# To write :

```
mount -o loop partition.img /mnt/tmp

mkboot recoveryksuamg5.img ksuamg
	Unpack & decompress recoveryksuamg5.img to ksuamg
mkboot ksuamg5 recovery.img
	mkbootimg from ksuamg5/img_info

abootimg -i ../boot.img
abootimg -x ../boot.img
mkdir ramdisk
cd ramdisk
gunzip -c ../initrd.img | cpio -i
```
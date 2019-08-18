Android Build Stack
==================

Work in progress :)

# To write :

```
# Docker
make run BUILD_PATH=/path/to/your/sources
make shell
source venv/bin/activate
cd /to/your/rom/repo
# Now you can use command to build
```

```
# TWRP
# before, be sure to use python2.7 with "source venv/bin/activate"
cd /path/to/twrp/sources
source build/envsetup.sh
lunch # Or lunch omni_DEVICE-eng, ex: omni_beryllium-eng
mka -j$(nproc) adbd recoveryimage ALLOW_MISSING_DEPENDENCIES=true
```

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

```
fdisk -l system.img

Disk system.img: 2.5 GiB, 2686451712 bytes, 5246976 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 7983C953-C727-45A6-8D7F-FF1686F68709
Device      Start     End Sectors  Size Type
system.img1  2048 5244927 5242880  2.5G Linux filesystem

## Now calculate offset :
# 512 x 2048 = 1048576

mkdir android_system_mount
mount -o loop,offset=1048576 system.img android_system_mount
```

#### How debug crash on device
- copy from https://stackoverflow.com/questions/17840521/android-fatal-signal-11-sigsegv-at-0x636f7d89-code-1-how-can-it-be-tracked/43252786

First, get your tombstone stack trace, it will be printed every time your app crashes. Something like this:
```
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
Build fingerprint: 'XXXXXXXXX'
pid: 1658, tid: 13086  >>> system_server <<<
signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 64696f7e
 r0 00000000  r1 00000001  r2 ad12d1e8  r3 7373654d
 r4 64696f72  r5 00000406  r6 00974130  r7 40d14008
 r8 4b857b88  r9 4685adb4  10 00974130  fp 4b857ed8
 ip 00000000  sp 4b857b50  lr afd11108  pc ad115ebc  cpsr 20000030
 d0  4040000040000000  d1  0000004200000003
 d2  4e72cd924285e370  d3  00e81fe04b1b64d8
 d4  3fbc71c7009b64d8  d5  3fe999999999999a
 d6  4010000000000000  d7  4000000000000000
 d8  4000000000000000  d9  0000000000000000
 d10 0000000000000000  d11 0000000000000000
 d12 0000000000000000  d13 0000000000000000
 d14 0000000000000000  d15 0000000000000000
 scr 80000012

         #00  pc 000108d8  /system/lib/libc.so
         #01  pc 0003724c  /system/lib/libxvi020.so
         #02  pc 0000ce02  /system/lib/libxvi020.so
         #03  pc 0000d672  /system/lib/libxvi020.so
         #04  pc 00010cce  /system/lib/libxvi020.so
         #05  pc 00004432  /system/lib/libwimax_jni.so
         #06  pc 00011e74  /system/lib/libdvm.so
         #07  pc 0004354a  /system/lib/libdvm.so
         #08  pc 00017088  /system/lib/libdvm.so
         #09  pc 0001c210  /system/lib/libdvm.so
         #10  pc 0001b0f8  /system/lib/libdvm.so
         #11  pc 00059c24  /system/lib/libdvm.so
         #12  pc 00059e3c  /system/lib/libdvm.so
         #13  pc 0004e19e  /system/lib/libdvm.so
         #14  pc 00011b94  /system/lib/libc.so
         #15  pc 0001173c  /system/lib/libc.so

code around pc:
ad115e9c 4620eddc bf00bd70 0001736e 0001734e 
ad115eac 4605b570 447c4c0a f7f44620 e006edc8 
ad115ebc 42ab68e3 68a0d103 f7f42122 6864edd2 
ad115ecc d1f52c00 44784803 edbef7f4 bf00bd70 
ad115edc 00017332 00017312 2100b51f 46682210 

code around lr:
afd110e8 e2166903 1a000018 e5945000 e1a02004 
afd110f8 e2055a02 e1a00005 e3851001 ebffed92 
afd11108 e3500000 13856002 1a000001 ea000009 
afd11118 ebfffe50 e1a01004 e1a00006 ebffed92 
afd11128 e1a01005 e1550000 e1a02006 e3a03000 

stack:
    4b857b10  40e43be8  
    4b857b14  00857280  
    4b857b18  00000000  
    4b857b1c  034e8968  
    4b857b20  ad118ce9  /system/lib/libnativehelper.so
    4b857b24  00000002  
    4b857b28  00000406
```

Then, use the **addr2line** utility (find it in your NDK tool-chain) to find the function that crashes. In this sample, you do

```
addr2line -e -f libc.so 0001173c
```

And you will see where you got the problem. Of course this wont help you since it is in libc.

So you might combine the utilities of arm-eabi-objdump to find the final target.

Believe me, it is a tough task.


UPDATE:

Just for an update. I think I was doing Android native build from the whole-source-tree for quite a long time, until today I have myself carefully read the NDK documents. Ever since the release NDK-r6, it has provided a utility called ndk-stack.

Following is the content from official NDK documents with the NDK-r9 tar ball.


Overview:

**ndk-stack** is a simple tool that allows you to filter stack traces as they appear in the output of 'adb logcat' and replace any address inside a shared library with the corresponding : values.

In a nutshell, it will translate something like:

```
  I/DEBUG   (   31): *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
  I/DEBUG   (   31): Build fingerprint: 'generic/google_sdk/generic/:2.2/FRF91/43546:eng/test-keys'
  I/DEBUG   (   31): pid: 351, tid: 351  %gt;%gt;%gt; /data/local/ndk-tests/crasher <<<
  I/DEBUG   (   31): signal 11 (SIGSEGV), fault addr 0d9f00d8
  I/DEBUG   (   31):  r0 0000af88  r1 0000a008  r2 baadf00d  r3 0d9f00d8
  I/DEBUG   (   31):  r4 00000004  r5 0000a008  r6 0000af88  r7 00013c44
  I/DEBUG   (   31):  r8 00000000  r9 00000000  10 00000000  fp 00000000
  I/DEBUG   (   31):  ip 0000959c  sp be956cc8  lr 00008403  pc 0000841e  cpsr 60000030
  I/DEBUG   (   31):          #00  pc 0000841e  /data/local/ndk-tests/crasher
  I/DEBUG   (   31):          #01  pc 000083fe  /data/local/ndk-tests/crasher
  I/DEBUG   (   31):          #02  pc 000083f6  /data/local/ndk-tests/crasher
  I/DEBUG   (   31):          #03  pc 000191ac  /system/lib/libc.so
  I/DEBUG   (   31):          #04  pc 000083ea  /data/local/ndk-tests/crasher
  I/DEBUG   (   31):          #05  pc 00008458  /data/local/ndk-tests/crasher
  I/DEBUG   (   31):          #06  pc 0000d362  /system/lib/libc.so
  I/DEBUG   (   31):
```

Into the more readable output:

```
  ********** Crash dump: **********
  Build fingerprint: 'generic/google_sdk/generic/:2.2/FRF91/43546:eng/test-keys'
  pid: 351, tid: 351  >>> /data/local/ndk-tests/crasher <<<
  signal 11 (SIGSEGV), fault addr 0d9f00d8
  Stack frame #00  pc 0000841e  /data/local/ndk-tests/crasher : Routine zoo in /tmp/foo/crasher/jni/zoo.c:13
  Stack frame #01  pc 000083fe  /data/local/ndk-tests/crasher : Routine bar in /tmp/foo/crasher/jni/bar.c:5
  Stack frame #02  pc 000083f6  /data/local/ndk-tests/crasher : Routine my_comparison in /tmp/foo/crasher/jni/foo.c:9
  Stack frame #03  pc 000191ac  /system/lib/libc.so
  Stack frame #04  pc 000083ea  /data/local/ndk-tests/crasher : Routine foo in /tmp/foo/crasher/jni/foo.c:14
  Stack frame #05  pc 00008458  /data/local/ndk-tests/crasher : Routine main in /tmp/foo/crasher/jni/main.c:19
  Stack frame #06  pc 0000d362  /system/lib/libc.so
```

Usage:

To do this, you will first need a directory containing symbolic versions of your application's shared libraries. If you use the NDK build system (i.e. **ndk-build**), then these are always located under $PROJECT_PATH/obj/local/, where stands for your device's ABI (i.e. **armeabi** by default).

You can feed the **logcat** text either as direct input to the program, e.g.:

```
adb logcat | $NDK/ndk-stack -sym $PROJECT_PATH/obj/local/armeabi
```

Or you can use the -dump option to specify the logcat as an input file, e.g.:

```
adb logcat > /tmp/foo.txt
$NDK/ndk-stack -sym $PROJECT_PATH/obj/local/armeabi -dump foo.txt
```

MPORTANT :

The tool looks for the initial line containing starts in the **logcat** output, i.e. something that looks like:

When copy/pasting traces, don't forget this line from the traces, or **ndk-stack** won't work correctly.

TODO:

A future version of **ndk-stack** will try to launch **adb logcat** and select the library path automatically. For now, you'll have to do these steps manually.

As of now, **ndk-stack** doesn't handle libraries that don't have debug information in them. It may be useful to try to detect the nearest function entry point to a given PC address (e.g. as in the libc.so example above).


Thank you to CAMOBAP https://stackoverflow.com/users/902217/camobap and Robin https://stackoverflow.com/users/1153396/robin .







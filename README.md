# Build Yocto for Raspberry Pi 3

## Hardware
- Linux host computer
- Raspberry Pi 3
- micro SD card
- USB to TTL serial cable

## Installation

```sh
$ sudo apt install kas
`̀``

## Build prod
```sh
$ kas build kas-rpi3.yml
```

## Build dev
```sh
$ kas build kas-qemuarm.yml
$ kas shell kas-qemuarm.yml -c 'runqemu nographic'
# To quit ctrl-a + x
`̀``

### img.xz
```sh
xz -dc 2023-05-03-raspios-bullseye-armhf-lite.img.xz | sudo dd bs=4M of=/dev/sdb status=progress && sync

```

Troubleshoot
```
# user pi was removded for security reason
echo 'mypassword' | openssl passwd -6 -stdin
# add the following line to userconf.txt in the boot partition
pi:$6$c70VpvPsVNCG0YR5$l5vWWLsLko9Kj65gcQ8qvMkuOoRkEagI90qi3F/Y7rm8eNYZHW8CY6BOIKwMH7a3YYzZYL90zf304cAHL
```

### wic.bz2
```sh
$ umount /dev/sdb*
$ sudo bmaptool copy build/tmp/deploy/images/raspberrypi3/rpi-diy-image-raspberrypi3-20230716134436.rootfs.wic.bz2 /dev/sdb && sync
$ sudo ip address add 192.168.99.37/24 dev eth0
```

```sh
$ mkdir -p ~/rpi/sources
$ cd ~/rpi/sources
$ git clone -b rocko git://git.yoctoproject.org/poky
$ git clone -b rocko git://git.openembedded.org/meta-openembedded
$ git clone -b rocko git://git.yoctoproject.org/meta-raspberrypi
$ cd ~/rpi/
$ source sources/poky/oe-init-build-env rpi-build
```
rpi-build/conf/local.conf:
```sh
CONF_VERSION = "1"
MACHINE = "raspberrypi3"
PREFERRED_VERSION_linux-raspberrypi = "4.%"
DISTRO_FEATURES_remove = "x11 wayland"
DISTRO_FEATURES_append = " systemd"
VIRTUAL-RUNTIME_init_manager = "systemd"
ENABLE_UART = "1" 
```
rpi-build/conf/bblayers.conf:
```sh
# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

BSPDIR := "/home/your_username/rpi/"

BBLAYERS ?= " \
  ${BSPDIR}/sources/poky/meta \
  ${BSPDIR}/sources/poky/meta-poky \
  ${BSPDIR}/sources/poky/meta-yocto-bsp \
  ${BSPDIR}/sources/meta-openembedded/meta-oe \
  ${BSPDIR}/sources/meta-openembedded/meta-multimedia \
  ${BSPDIR}/sources/meta-raspberrypi \
  ${BSPDIR}/sources/meta-openembedded/meta-python \
  "
BBLAYERS_NON_REMOVABLE ?= " \
  ${BSPDIR}/sources/poky/meta \
  ${BSPDIR}/sources/poky/meta-poky \
  "
```
```sh
$ sudo apt-get install chrpath 
$ bitbake rpi-basic-image
```
```sh
$ sudo dd if=~/rpi/rpi-build/tmp/deploy/images/raspberrypi3/rpi-basic-image-raspberrypi3.rpi-sdimg of=/dev/sdX bs=4M
```

# Hod to compile a dts
sudo apt install device-tree-compiler
dtc -O dtb -o out.dtbo tft35a-overlay.dts

# troubleshoot
```bash
# pyinotify.WatchManagerError: add_watch: cannot watch ./yocto-distrib/layers/meta-diy/conf WD=-1, Errno=No space left on device (ENOSPC)
sysctl -n fs.inotify.max_user_watches
# cat /proc/sys/fs/inotify/max_user_watches
# 60105
sysctl fs.inotify.max_user_watches=524288

```

## References
[1] https://raspinterest.wordpress.com/2016/11/30/yocto-project-on-raspberry-pi-3/  
[2] https://github.com/cosmo0920/rpi3-yocto-rocko  
[3] http://kernelhacks.com/raspberry-pi-3-with-yocto/  


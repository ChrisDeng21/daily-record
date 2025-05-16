# Run ast2700-evb machine using QEMU

## Created Date
2025/05/15

## Environment
ubuntu-22.04.4-desktop-amd64.iso
> This is console output：
> ```console＝
> $ cat /etc/os-release
> PRETTY_NAME="Ubuntu 22.04.4 LTS"
> NAME="Ubuntu"
> VERSION_ID="22.04"
> VERSION="22.04.4 LTS (Jammy Jellyfish)"
> VERSION_CODENAME=jammy
> ID=ubuntu
> ID_LIKE=debian
> HOME_URL="https://www.ubuntu.com/"
> SUPPORT_URL="https://help.ubuntu.com/"
> BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
> PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
> UBUNTU_CODENAME=jammy
> 
> $ uname -a
> Linux wilkes-evt 6.8.0-52-generic #53~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Wed Jan 15 19:18:46 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
> ```

## Symptom
None

## Cause
提供一種範例，編譯 [AspeedTech-BMC/openbmc](<https://github.com/AspeedTech-BMC/openbmc>) 的 AST2700，並且使用 [QEMU](<https://www.qemu.org/docs/master/system/arm/aspeed.html>) 方式啟動，用於前期建置。

## Solution
1. 由於 AST2700 使用 `AARCH64` 平台，請按照 [Installing the latest qemu-system-arm on Ubuntu 22.04.4 LTS](<https://github.com/ChrisDeng21/daily-record/blob/main/ubuntu/Installing_the_latest_qemu-system-arm_on_Ubuntu_22.04.4_LTS.md#buiild>) 編譯適合的 QEMU。

2. 下載 Aspeed OpenBMC（以 tags `v09.06` 示範）。
```shell
git clone -b v09.06 https://github.com/AspeedTech-BMC/openbmc.git
cd openbmc/
```

3. 按照 [SDK GUIDE](<https://github.com/AspeedTech-BMC/openbmc/tree/aspeed-master/meta-aspeed-sdk#create-build-environment>) 建置環境並設定目標機器（以 `ast2700-default` 示範）來開始編譯。
```shell
. setup ast2700-default
bitbake obmc-phosphor-image
```
- 等待編譯完成後，可以檢查 images 是否正常產出。
```shell
ls -l tmp/deploy/images/ast2700-default/
```

4. 按照官方 [QEMU](<https://www.qemu.org/docs/master/system/arm/aspeed.html>) 提供的指令啟動。
> `-M ast2700-evb` 改成 `-M ast2700a1-evb`
```shell
cd tmp/deploy/images/

IMGDIR=ast2700-default
UBOOT_SIZE=$(stat --format=%s -L ${IMGDIR}/u-boot-nodtb.bin)

qemu-system-aarch64 -M ast2700a1-evb \
  -device loader,force-raw=on,addr=0x400000000,file=${IMGDIR}/u-boot-nodtb.bin \
  -device loader,force-raw=on,addr=$((0x400000000 + ${UBOOT_SIZE})),file=${IMGDIR}/u-boot.dtb \
  -device loader,force-raw=on,addr=0x430000000,file=${IMGDIR}/bl31.bin \
  -device loader,force-raw=on,addr=0x430080000,file=${IMGDIR}/optee/tee-raw.bin \
  -device loader,cpu-num=0,addr=0x430000000 \
  -device loader,cpu-num=1,addr=0x430000000 \
  -device loader,cpu-num=2,addr=0x430000000 \
  -device loader,cpu-num=3,addr=0x430000000 \
  -smp 4 \
  -drive file=${IMGDIR}/image-bmc,format=raw,if=mtd \
  -nographic
```
> This is console output：
> ```console＝
> NOTICE:  BL31: v2.10.3(release):lts-v2.10.3-dirty
> NOTICE:  BL31: Built : 17:17:34, Apr  5 2024
> I/TC:
> I/TC: OP-TEE version: 4.1.0-dev (gcc version 13.2.0 (GCC)) #1 Fri Jan 19 17:14:14 UTC 2024 aarch64
> I/TC: WARNING: This OP-TEE configuration might be insecure!
> I/TC: WARNING: Please check https://optee.readthedocs.io/en/latest/architecture/porting_guidelines.html
> I/TC: Primary CPU initializing
> I/TC: Primary CPU switching to normal world boot
> 
> 
> U-Boot 2023.10-v00.05.06 (Mar 26 2025 - 05:59:26 +0000)
> 
> SOC: AST2700-A1
> Model: AST2700 EVB
> DRAM:  1 GiB
> Core:  124 devices, 29 uclasses, devicetree: separate
> WDT:   Not starting watchdog@14c37000
> MMC:   sdhci@12090100: 0, sdhci@14080100: 1
> Loading Environment from SPIFlash... SF: Detected w25q01jv with page size 256 Bytes, erase size 4 KiB, total 128 MiB
> *** Warning - bad CRC, using default environment
> 
> In:    serial@14c33b00
> Out:   serial@14c33b00
> Err:   serial@14c33b00
> Model: AST2700 EVB
> Net:   eth0: ftgmac@14050000, eth1: ftgmac@14060000
> Hit any key to stop autoboot:  0
> Boot from spi
> Working FDT set to 100420000
> ## Loading kernel from FIT Image at 403000000 ...
>    Using 'conf-ast2700-evb.dtb' configuration
>    Verifying Hash Integrity ... OK
>    Trying 'kernel-1' kernel subimage
>      Description:  Linux kernel
>      Type:         Kernel Image
>      Compression:  lzma compressed
>      Data Start:   0x40300011c
>      Data Size:    6095167 Bytes = 5.8 MiB
>      Architecture: AArch64
>      OS:           Linux
>      Load Address: 0x400000000
>      Entry Point:  0x400000000
>      Hash algo:    sha256
>      Hash value:   71db2e73213619ca9b2dd2436aa50881f810b731386b0f287ce48609cc665313
>    Verifying Hash Integrity ... sha256+ OK
> ## Loading ramdisk from FIT Image at 403000000 ...
>    Using 'conf-ast2700-evb.dtb' configuration
>    Verifying Hash Integrity ... OK
>    Trying 'ramdisk-1' ramdisk subimage
>      Description:  obmc-phosphor-initramfs
>      Type:         RAMDisk Image
>      Compression:  uncompressed
>      Data Start:   0x4035e4c94
>      Data Size:    1249448 Bytes = 1.2 MiB
>      Architecture: AArch64
>      OS:           Linux
>      Load Address: unavailable
>      Entry Point:  unavailable
>      Hash algo:    sha256
>      Hash value:   c47874ecc08109223dbfca887f02b1b5258464047075d7a94a43468215c5d9a3
>    Verifying Hash Integrity ... sha256+ OK
> ## Loading fdt from FIT Image at 403000000 ...
>    Using 'conf-ast2700-evb.dtb' configuration
>    Verifying Hash Integrity ... OK
>    Trying 'fdt-ast2700-evb.dtb' fdt subimage
>      Description:  Flattened Device Tree blob
>      Type:         Flat Device Tree
>      Compression:  uncompressed
>      Data Start:   0x4035d0374
>      Data Size:    84045 Bytes = 82.1 KiB
>      Architecture: AArch64
>      Hash algo:    sha256
>      Hash value:   d6c777dd66a6725441ee6d2a7fa72791fcaa268707d8a412e525d0a86f56de7c
>    Verifying Hash Integrity ... sha256+ OK
>    Booting using the fdt blob at 0x4035d0374
> Working FDT set to 4035d0374
>    Uncompressing Kernel Image
>    Loading Ramdisk to 43cd69000, end 43ce9a0a8 ... OK
>    Loading Device Tree to 000000043cd51000, end 000000043cd6884c ... OK
> Working FDT set to 43cd51000
> 
> Starting kernel ...
> 
> [    0.000000] Booting Linux on physical CPU 0x0000000000 [0x411fd040]
> [    0.000000] Linux version 6.6.78-v00.06.06-g882b09bd4db0 (oe-user@oe-host) (aarch64-openbmc-linux-gcc (GCC) 13.2.0, GNU ld (GNU Binutils) 2.42.0.20240216) #1 SMP PREEMPT Mon Mar 31 17:54:20 CST 2025
> [    0.000000] Machine model: AST2700-EVB
> ```

## Reference
[AspeedTech-BMC/openbmc](<https://github.com/AspeedTech-BMC/openbmc>)

[QEMU](<https://www.qemu.org/docs/master/system/arm/aspeed.html>)

[SDK GUIDE](<https://github.com/AspeedTech-BMC/openbmc/tree/aspeed-master/meta-aspeed-sdk#create-build-environment>)

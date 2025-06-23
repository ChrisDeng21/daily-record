# Run ast2700-evb machine using QEMU

## Language
[English](#English) | [中文](#中文)

## English
### Created Date
2025/05/15
### Environment
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
### Symptom
None
### Cause
Provide an example of building the AST2700 Evaluation Board (EVB) from the [AspeedTech-BMC/openbmc](<https://github.com/AspeedTech-BMC/openbmc>) project, and running it through QEMU using the [QEMU/aspeed-2700-family-boards-ast2700-evb](<https://www.qemu.org/docs/master/system/arm/aspeed.html#aspeed-2700-family-boards-ast2700-evb>) method for early-stage environment testing.
### Solution
1. Since the AST2700 EVB uses the AARCH64 architecture, please follow the steps in [Installing the latest qemu-system-arm](<https://github.com/ChrisDeng21/daily-record/blob/main/ubuntu/Installing_the_latest_qemu-system-arm_on_Ubuntu_22.04.4_LTS.md#buiild>) to prepare the appropriate QEMU tools.
2. Download the Aspeed OpenBMC source code using the `v09.06` tag as an example.
```shell
git clone -b v09.06 https://github.com/AspeedTech-BMC/openbmc.git
cd openbmc/
```
3. Set up the build environment using the [SDK](<https://github.com/AspeedTech-BMC/openbmc/tree/aspeed-master/meta-aspeed-sdk#create-build-environment>) and configure the target machine as `ast2700-default` to begin compilation.
```shell
. setup ast2700-default
bitbake obmc-phosphor-image
```
- After the compilation is complete, verify whether the images have been successfully generated.
```shell
ls -l tmp/deploy/images/ast2700-default/image-bmc
```
4. Launch the system using the commands provided in [QEMU/booting-the-ast2700-evb-machine](<https://www.qemu.org/docs/master/system/arm/aspeed.html#booting-the-ast2700-evb-machine>).
> Important! Replace `-M ast2700-evb` with `-M ast2700a1-evb`.
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
#### Extension
1. If network access to the emulator is required, add parameters to forward the emulator's ports and modify the QEMU command accordingly.
```shell
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
  -nographic \
  -net nic \
  -net user,hostfwd=:127.0.0.1:2222-:22,hostfwd=:127.0.0.1:2443-:443,hostfwd=udp:127.0.0.1:2623-:623,hostname=qemu
```
> Add two -net parameters after the QEMU command.
> - `127.0.0.1:2222` Port Forwarding for the Emulator `22` (Used for SSH)
> - `127.0.0.1:2443` Port Forwarding for the Emulator `443` (Used for HTTPS/REDFISH)
> - `127.0.0.1:2623` Port Forwarding for the Emulator `623` (Used for IPMI)
2. Alternatively, you can use a script by copying [qemuast2700a1-evb.sh](<https://github.com/ChrisDeng21/daily-record/blob/main/openbmc/qemuast2700a1-evb.sh>) to the root directory of the Aspeed OpenBMC source tree (i.e., under openbmc/). Once the images are successfully built, simply execute the script.
> - Before running the script, ensure that the `QEMUTOOL` parameter specifies a valid tool path. If not, modify it to point to the path where you built your own version.
> 
> - For example: change `QEMUTOOL=qemu-system-aarch64` to `QEMUTOOL=/home/chrisdeng/Work/Project/qemu/build/qemu-system-aarch64`, which reflects my local environment.
```shell
QEMUTOOL=/home/chrisdeng/Work/Project/qemu/build/qemu-system-aarch64
```
> - Also, grant the script execution permission.
```shell
chmod 775 qemuast2700a1-evb.sh
```
> - After that, simply execute the script.
```shell
./qemuast2700a1-evb.sh
```
### Reference
- [AspeedTech-BMC/openbmc](<https://github.com/AspeedTech-BMC/openbmc>)
- [QEMU/aspeed-2700-family-boards-ast2700-evb](<https://www.qemu.org/docs/master/system/arm/aspeed.html#aspeed-2700-family-boards-ast2700-evb>)
- [QEMU/booting-the-ast2700-evb-machine](<https://www.qemu.org/docs/master/system/arm/aspeed.html#booting-the-ast2700-evb-machine>)
- [SDK](<https://github.com/AspeedTech-BMC/openbmc/tree/aspeed-master/meta-aspeed-sdk#create-build-environment>)

## 中文
### 建立日期
2025/05/15
### 環境
ubuntu-22.04.4-desktop-amd64.iso
> 這是控制台輸出：
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
### 症狀
無
### 原因
提供一種範例，編譯 [AspeedTech-BMC/openbmc](<https://github.com/AspeedTech-BMC/openbmc>) 的 AST2700 EVB，並且透過 [QEMU/aspeed-2700-family-boards-ast2700-evb](<https://www.qemu.org/docs/master/system/arm/aspeed.html#aspeed-2700-family-boards-ast2700-evb>) 方式啟動，用於前期環境測試。
### 解決方案
1. 因為 AST2700 EVB 使用 `AARCH64` 平台，請按照 [Installing the latest qemu-system-arm](<https://github.com/ChrisDeng21/daily-record/blob/main/ubuntu/Installing_the_latest_qemu-system-arm_on_Ubuntu_22.04.4_LTS.md#buiild>) 準備適合的 QEMU 工具。
2. 下載 Aspeed OpenBMC 程式碼（以 tags `v09.06` 示範）。
```shell
git clone -b v09.06 https://github.com/AspeedTech-BMC/openbmc.git
cd openbmc/
```
3. 按照 [SDK](<https://github.com/AspeedTech-BMC/openbmc/tree/aspeed-master/meta-aspeed-sdk#create-build-environment>) 建置編譯環境並設定目標機器 `ast2700-default` 來開始編譯。
```shell
. setup ast2700-default
bitbake obmc-phosphor-image
```
- 等待編譯完成後，可以檢查 images 是否正常產出。
```shell
ls -l tmp/deploy/images/ast2700-default/image-bmc
```
4. 按照 [QEMU/booting-the-ast2700-evb-machine](<https://www.qemu.org/docs/master/system/arm/aspeed.html#booting-the-ast2700-evb-machine>) 提供的指令啟動。
> 注意! `-M ast2700-evb` 改成 `-M ast2700a1-evb`
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
> 這是控制台輸出：
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
#### 延伸
1. 如果需要網路連入模擬器的能力，新增轉發模擬器連接埠的參數，將 QEMU 指令改寫成：
```shell
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
  -nographic \
  -net nic \
  -net user,hostfwd=:127.0.0.1:2222-:22,hostfwd=:127.0.0.1:2443-:443,hostfwd=udp:127.0.0.1:2623-:623,hostname=qemu
```
> 新增兩行 -net 參數在 QEMU 指令後。
> - `127.0.0.1:2222` 轉發模擬器連接埠 `22` (用於SSH)
> - `127.0.0.1:2443` 轉發模擬器連接埠 `443` (用於HTTPS/REDFISH)
> - `127.0.0.1:2623` 轉發模擬器連接埠 `623` (用於IPMI)
2. 或使用腳本，將 [qemuast2700a1-evb.sh](<https://github.com/ChrisDeng21/daily-record/blob/main/openbmc/qemuast2700a1-evb.sh>) 複製到 Aspeed OpenBMC 程式碼的根目錄下，也就是 `openbmc/` 下，待 images 編譯成功後，直接執行即可。
> - 請先確認腳本內 `QEMUTOOL` 參數所定義的工具路徑是可行的，不然要改成你自己編譯出的路徑。
> 
> - 例如：`QEMUTOOL=qemu-system-aarch64` 改成 `QEMUTOOL=/home/chrisdeng/Work/Project/qemu/build/qemu-system-aarch64`，這是我的環境。
```shell
QEMUTOOL=/home/chrisdeng/Work/Project/qemu/build/qemu-system-aarch64
```
> - 並且賦予腳本執行權限。
```shell
chmod 775 qemuast2700a1-evb.sh
```
> - 之後直接執行即可。
```shell
./qemuast2700a1-evb.sh
```
### 參考
- [AspeedTech-BMC/openbmc](<https://github.com/AspeedTech-BMC/openbmc>)
- [QEMU/aspeed-2700-family-boards-ast2700-evb](<https://www.qemu.org/docs/master/system/arm/aspeed.html#aspeed-2700-family-boards-ast2700-evb>)
- [QEMU/booting-the-ast2700-evb-machine](<https://www.qemu.org/docs/master/system/arm/aspeed.html#booting-the-ast2700-evb-machine>)
- [SDK](<https://github.com/AspeedTech-BMC/openbmc/tree/aspeed-master/meta-aspeed-sdk#create-build-environment>)

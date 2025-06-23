# Installing the latest qemu-system-arm on Ubuntu 22.04.4 LTS

## Language
[English](#English) | [中文](#中文)

## English
### Created Date
2025/04/01
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
The qemu-system-arm version 6.2 was installed from the APT server, but the `ast1030-evb` is not listed among the supported machines.
### Solution
#### Buiild
1. Install a few prerequisite packages which let qemu build successfully.
  - System's packages：
```shell
sudo apt install -y build-essential libglib2.0-dev libpixman-1-dev zlib1g-dev git python3-pip ninja-build
```
  - Python's packages：
```shell
pip install tomli
```
2. Download QEMU source code and enter the directory.
```shell
git clone https://gitlab.com/qemu-project/qemu.git
cd qemu
```
3. Configure the build target.
  - To support ARM platform
```shell
./configure --target-list=arm-softmmu,arm-linux-user --enable-slirp
```
> `--target-list=arm-softmmu`：set target list, it's for system mode.
> 
> `--target-list=arm-linux-user`：set target list, it's for user mode.
> 
> `--enable-slirp`：libslirp user mode network backend support
  - To support AARCH64 platform
```shell
./configure --target-list=aarch64-softmmu,aarch64-linux-user --enable-slirp
```
> `--target-list=aarch64-softmmu`：set target list, it's for system mode.
> 
> `--target-list=aarch64-linux-user`：set target list, it's for user mode.
> 
> `--enable-slirp`：libslirp user mode network backend support
  - Both support ARM and AARCH64 platform
```shell
./configure --target-list=arm-softmmu,arm-linux-user,aarch64-softmmu,aarch64-linux-user --enable-slirp
```
4. Compile QEMU.
```shell
make -j$(nproc)
```
#### Method 1：Use directly
1. Execute binary in build directory.
  - Check version for ARM platform：
```shell
./build/qemu-system-arm --version
```
> This is console output：
> ```console＝
> $ ./build/qemu-system-arm --version
> QEMU emulator version 10.0.50 (v10.0.0-529-g5134cf9b5d)
> Copyright (c) 2003-2025 Fabrice Bellard and the QEMU Project developers
> ```
  - Check version for AARCH64 platform：
```shell
./build/qemu-system-aarch64 --version
```
> This is console output：
> ```console＝
> $ ./build/qemu-system-aarch64 --version
> QEMU emulator version 10.0.50 (v10.0.0-529-g5134cf9b5d)
> Copyright (c) 2003-2025 Fabrice Bellard and the QEMU Project developers
> ```
#### Method 2：Install into system environment
1. Install into system.
```shell
sudo make install
```
2. Verify the installation is success.
```shell
qemu-system-arm --version
```
> This is console output：
> ```console＝
> $ qemu-system-arm --version
> QEMU emulator version 10.0.50 (v10.0.0-529-g5134cf9b5d)
> Copyright (c) 2003-2025 Fabrice Bellard and the QEMU Project developers
> ```
#### Extension
`ast1030-evb` is supported in the latest version.
> This is console output：
> ```console＝
> $ qemu-system-arm -machine help
> Supported machines are:
> ast1030-evb          Aspeed AST1030 MiniBMC (Cortex-M4)
> ast2500-evb          Aspeed AST2500 EVB (ARM1176)
> ast2600-evb          Aspeed AST2600 EVB (Cortex-A7)
> b-l475e-iot01a       B-L475E-IOT01A Discovery Kit (Cortex-M4)
> bletchley-bmc        Facebook Bletchley BMC (Cortex-A7)
> bpim2u               Bananapi M2U (Cortex-A7)
> canon-a1100          Canon PowerShot A1100 IS (ARM946)
> collie               Sharp SL-5500 (Collie) PDA (SA-1110)
> cubieboard           cubietech cubieboard (Cortex-A8)
> emcraft-sf2          SmartFusion2 SOM kit from Emcraft (M2S010)
> fby35-bmc            Facebook fby35 BMC (Cortex-A7)
> fby35                Meta Platforms fby35
> fp5280g2-bmc         Inspur FP5280G2 BMC (ARM1176)
> fuji-bmc             Facebook Fuji BMC (Cortex-A7)
> g220a-bmc            Bytedance G220A BMC (ARM1176)
> highbank             Calxeda Highbank (ECX-1000)
> imx25-pdk            ARM i.MX25 PDK board (ARM926)
> integratorcp         ARM Integrator/CP (ARM926EJ-S)
> kudo-bmc             Kudo BMC (Cortex-A9)
> kzm                  ARM KZM Emulation Baseboard (ARM1136)
> lm3s6965evb          Stellaris LM3S6965EVB (Cortex-M3)
> lm3s811evb           Stellaris LM3S811EVB (Cortex-M3)
> mcimx6ul-evk         Freescale i.MX6UL Evaluation Kit (Cortex-A7)
> mcimx7d-sabre        Freescale i.MX7 DUAL SABRE (Cortex-A7)
> microbit             BBC micro:bit (Cortex-M0)
> midway               Calxeda Midway (ECX-2000)
> mori-bmc             Mori BMC (Cortex-A9)
> mps2-an385           ARM MPS2 with AN385 FPGA image for Cortex-M3
> mps2-an386           ARM MPS2 with AN386 FPGA image for Cortex-M4
> mps2-an500           ARM MPS2 with AN500 FPGA image for Cortex-M7
> mps2-an505           ARM MPS2 with AN505 FPGA image for Cortex-M33
> mps2-an511           ARM MPS2 with AN511 DesignStart FPGA image for Cortex-M3
> mps2-an521           ARM MPS2 with AN521 FPGA image for dual Cortex-M33
> mps3-an524           ARM MPS3 with AN524 FPGA image for dual Cortex-M33
> mps3-an536           ARM MPS3 with AN536 FPGA image for Cortex-R52
> mps3-an547           ARM MPS3 with AN547 FPGA image for Cortex-M55
> musca-a              ARM Musca-A board (dual Cortex-M33)
> musca-b1             ARM Musca-B1 board (dual Cortex-M33)
> musicpal             Marvell 88w8618 / MusicPal (ARM926EJ-S)
> netduino2            Netduino 2 Machine (Cortex-M3)
> netduinoplus2        Netduino Plus 2 Machine (Cortex-M4)
> none                 empty machine
> npcm750-evb          Nuvoton NPCM750 Evaluation Board (Cortex-A9)
> nuri                 Samsung NURI board (Exynos4210)
> olimex-stm32-h405    Olimex STM32-H405 (Cortex-M4)
> orangepi-pc          Orange Pi PC (Cortex-A7)
> palmetto-bmc         OpenPOWER Palmetto BMC (ARM926EJ-S)
> qcom-dc-scm-v1-bmc   Qualcomm DC-SCM V1 BMC (Cortex A7)
> qcom-firework-bmc    Qualcomm DC-SCM V1/Firework BMC (Cortex A7)
> quanta-gbs-bmc       Quanta GBS (Cortex-A9)
> quanta-gsj           Quanta GSJ (Cortex-A9)
> quanta-q71l-bmc      Quanta-Q71l BMC (ARM926EJ-S)
> rainier-bmc          IBM Rainier BMC (Cortex-A7)
> raspi0               Raspberry Pi Zero (revision 1.2)
> raspi1ap             Raspberry Pi A+ (revision 1.1)
> raspi2b              Raspberry Pi 2B (revision 1.1)
> realview-eb          ARM RealView Emulation Baseboard (ARM926EJ-S)
> realview-eb-mpcore   ARM RealView Emulation Baseboard (ARM11MPCore)
> realview-pb-a8       ARM RealView Platform Baseboard for Cortex-A8
> realview-pbx-a9      ARM RealView Platform Baseboard Explore for Cortex-A9
> romulus-bmc          OpenPOWER Romulus BMC (ARM1176)
> sabrelite            Freescale i.MX6 Quad SABRE Lite Board (Cortex-A9)
> smdkc210             Samsung SMDKC210 board (Exynos4210)
> sonorapass-bmc       OCP SonoraPass BMC (ARM1176)
> stm32vldiscovery     ST STM32VLDISCOVERY (Cortex-M3)
> supermicro-x11spi-bmc Supermicro X11 SPI BMC (ARM1176)
> supermicrox11-bmc    Supermicro X11 BMC (ARM926EJ-S)
> sx1                  Siemens SX1 (OMAP310) V2
> sx1-v1               Siemens SX1 (OMAP310) V1
> tiogapass-bmc        Facebook Tiogapass BMC (ARM1176)
> versatileab          ARM Versatile/AB (ARM926EJ-S)
> versatilepb          ARM Versatile/PB (ARM926EJ-S)
> vexpress-a15         ARM Versatile Express for Cortex-A15
> vexpress-a9          ARM Versatile Express for Cortex-A9
> virt                 QEMU 10.0 ARM Virtual Machine (alias of virt-10.0)
> virt-10.0            QEMU 10.0 ARM Virtual Machine
> virt-2.10            QEMU 2.10 ARM Virtual Machine (deprecated)
> virt-2.11            QEMU 2.11 ARM Virtual Machine (deprecated)
> virt-2.12            QEMU 2.12 ARM Virtual Machine (deprecated)
> virt-2.6             QEMU 2.6 ARM Virtual Machine (deprecated)
> virt-2.7             QEMU 2.7 ARM Virtual Machine (deprecated)
> virt-2.8             QEMU 2.8 ARM Virtual Machine (deprecated)
> virt-2.9             QEMU 2.9 ARM Virtual Machine (deprecated)
> virt-3.0             QEMU 3.0 ARM Virtual Machine (deprecated)
> virt-3.1             QEMU 3.1 ARM Virtual Machine (deprecated)
> virt-4.0             QEMU 4.0 ARM Virtual Machine (deprecated)
> virt-4.1             QEMU 4.1 ARM Virtual Machine (deprecated)
> virt-4.2             QEMU 4.2 ARM Virtual Machine (deprecated)
> virt-5.0             QEMU 5.0 ARM Virtual Machine (deprecated)
> virt-5.1             QEMU 5.1 ARM Virtual Machine (deprecated)
> virt-5.2             QEMU 5.2 ARM Virtual Machine (deprecated)
> virt-6.0             QEMU 6.0 ARM Virtual Machine (deprecated)
> virt-6.1             QEMU 6.1 ARM Virtual Machine (deprecated)
> virt-6.2             QEMU 6.2 ARM Virtual Machine (deprecated)
> virt-7.0             QEMU 7.0 ARM Virtual Machine
> virt-7.1             QEMU 7.1 ARM Virtual Machine
> virt-7.2             QEMU 7.2 ARM Virtual Machine
> virt-8.0             QEMU 8.0 ARM Virtual Machine
> virt-8.1             QEMU 8.1 ARM Virtual Machine
> virt-8.2             QEMU 8.2 ARM Virtual Machine
> virt-9.0             QEMU 9.0 ARM Virtual Machine
> virt-9.1             QEMU 9.1 ARM Virtual Machine
> virt-9.2             QEMU 9.2 ARM Virtual Machine
> witherspoon-bmc      OpenPOWER Witherspoon BMC (ARM1176)
> xilinx-zynq-a9       Xilinx Zynq 7000 Platform Baseboard for Cortex-A9
> yosemitev2-bmc       Facebook YosemiteV2 BMC (ARM1176)
> ```
### Reference
None

## 中文
### 建立日期
2025/04/01
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
從 APT 伺服器安裝的 qemu-system-arm 版本是 6.2 ，但「ast1030-evb」未列在支援的機器中。
### 解決方案
#### 建造
1. 安裝一些使 qemu 成功建置的必備軟體包。
  - 系統的軟體包：
```shell
sudo apt install -y build-essential libglib2.0-dev libpixman-1-dev zlib1g-dev git python3-pip ninja-build
```
  - Python 的軟體包：
```shell
pip install tomli
```
2. 下載 QEMU 原始碼並進入目錄。
```shell
git clone https://gitlab.com/qemu-project/qemu.git
cd qemu
```
3. 配置建置目標。
  - 支援 ARM 平台
```shell
./configure --target-list=arm-softmmu,arm-linux-user --enable-slirp
```
> `--target-list=arm-softmmu`：設定目標，用於系統模式。
> 
> `--target-list=arm-linux-user`：設定目標，用於使用者模式。
> 
> `--enable-slirp`：libslirp 用戶模式網路支持。
  - 支援 AARCH64 平台
```shell
./configure --target-list=aarch64-softmmu,aarch64-linux-user --enable-slirp
```
> `--target-list=aarch64-softmmu`：設定目標，用於系統模式。
> 
> `--target-list=aarch64-linux-user`：設定目標，用於使用者模式。
> 
> `--enable-slirp`：libslirp 用戶模式網路支持。
  - 支援 ARM 和 AARCH64 平台
```shell
./configure --target-list=arm-softmmu,arm-linux-user,aarch64-softmmu,aarch64-linux-user --enable-slirp
```
4. 編譯 QEMU。
```shell
make -j$(nproc)
```
#### 方法 1：直接使用
1. 在建置目錄中執行二進位檔案。
  - 檢查 ARM 平台的版本：
```shell
./build/qemu-system-arm --version
```
> 這是控制台輸出：
> ```console＝
> $ ./build/qemu-system-arm --version
> QEMU emulator version 10.0.50 (v10.0.0-529-g5134cf9b5d)
> Copyright (c) 2003-2025 Fabrice Bellard and the QEMU Project developers
> ```
  - 檢查 AARCH64 平台的版本：
```shell
./build/qemu-system-aarch64 --version
```
> 這是控制台輸出：
> ```console＝
> $ ./build/qemu-system-aarch64 --version
> QEMU emulator version 10.0.50 (v10.0.0-529-g5134cf9b5d)
> Copyright (c) 2003-2025 Fabrice Bellard and the QEMU Project developers
> ```
#### 方法 2：安裝到系統環境中
1. 安裝到系統中。
```shell
sudo make install
```
2. 驗證安裝是否成功。
```shell
qemu-system-arm --version
```
> 這是控制台輸出：
> ```console＝
> $ qemu-system-arm --version
> QEMU emulator version 10.0.50 (v10.0.0-529-g5134cf9b5d)
> Copyright (c) 2003-2025 Fabrice Bellard and the QEMU Project developers
> ```
#### 延伸
最新版本支援`ast1030-evb`。
> 這是控制台輸出：
> ```console＝
> $ qemu-system-arm -machine help
> Supported machines are:
> ast1030-evb          Aspeed AST1030 MiniBMC (Cortex-M4)
> ast2500-evb          Aspeed AST2500 EVB (ARM1176)
> ast2600-evb          Aspeed AST2600 EVB (Cortex-A7)
> b-l475e-iot01a       B-L475E-IOT01A Discovery Kit (Cortex-M4)
> bletchley-bmc        Facebook Bletchley BMC (Cortex-A7)
> bpim2u               Bananapi M2U (Cortex-A7)
> canon-a1100          Canon PowerShot A1100 IS (ARM946)
> collie               Sharp SL-5500 (Collie) PDA (SA-1110)
> cubieboard           cubietech cubieboard (Cortex-A8)
> emcraft-sf2          SmartFusion2 SOM kit from Emcraft (M2S010)
> fby35-bmc            Facebook fby35 BMC (Cortex-A7)
> fby35                Meta Platforms fby35
> fp5280g2-bmc         Inspur FP5280G2 BMC (ARM1176)
> fuji-bmc             Facebook Fuji BMC (Cortex-A7)
> g220a-bmc            Bytedance G220A BMC (ARM1176)
> highbank             Calxeda Highbank (ECX-1000)
> imx25-pdk            ARM i.MX25 PDK board (ARM926)
> integratorcp         ARM Integrator/CP (ARM926EJ-S)
> kudo-bmc             Kudo BMC (Cortex-A9)
> kzm                  ARM KZM Emulation Baseboard (ARM1136)
> lm3s6965evb          Stellaris LM3S6965EVB (Cortex-M3)
> lm3s811evb           Stellaris LM3S811EVB (Cortex-M3)
> mcimx6ul-evk         Freescale i.MX6UL Evaluation Kit (Cortex-A7)
> mcimx7d-sabre        Freescale i.MX7 DUAL SABRE (Cortex-A7)
> microbit             BBC micro:bit (Cortex-M0)
> midway               Calxeda Midway (ECX-2000)
> mori-bmc             Mori BMC (Cortex-A9)
> mps2-an385           ARM MPS2 with AN385 FPGA image for Cortex-M3
> mps2-an386           ARM MPS2 with AN386 FPGA image for Cortex-M4
> mps2-an500           ARM MPS2 with AN500 FPGA image for Cortex-M7
> mps2-an505           ARM MPS2 with AN505 FPGA image for Cortex-M33
> mps2-an511           ARM MPS2 with AN511 DesignStart FPGA image for Cortex-M3
> mps2-an521           ARM MPS2 with AN521 FPGA image for dual Cortex-M33
> mps3-an524           ARM MPS3 with AN524 FPGA image for dual Cortex-M33
> mps3-an536           ARM MPS3 with AN536 FPGA image for Cortex-R52
> mps3-an547           ARM MPS3 with AN547 FPGA image for Cortex-M55
> musca-a              ARM Musca-A board (dual Cortex-M33)
> musca-b1             ARM Musca-B1 board (dual Cortex-M33)
> musicpal             Marvell 88w8618 / MusicPal (ARM926EJ-S)
> netduino2            Netduino 2 Machine (Cortex-M3)
> netduinoplus2        Netduino Plus 2 Machine (Cortex-M4)
> none                 empty machine
> npcm750-evb          Nuvoton NPCM750 Evaluation Board (Cortex-A9)
> nuri                 Samsung NURI board (Exynos4210)
> olimex-stm32-h405    Olimex STM32-H405 (Cortex-M4)
> orangepi-pc          Orange Pi PC (Cortex-A7)
> palmetto-bmc         OpenPOWER Palmetto BMC (ARM926EJ-S)
> qcom-dc-scm-v1-bmc   Qualcomm DC-SCM V1 BMC (Cortex A7)
> qcom-firework-bmc    Qualcomm DC-SCM V1/Firework BMC (Cortex A7)
> quanta-gbs-bmc       Quanta GBS (Cortex-A9)
> quanta-gsj           Quanta GSJ (Cortex-A9)
> quanta-q71l-bmc      Quanta-Q71l BMC (ARM926EJ-S)
> rainier-bmc          IBM Rainier BMC (Cortex-A7)
> raspi0               Raspberry Pi Zero (revision 1.2)
> raspi1ap             Raspberry Pi A+ (revision 1.1)
> raspi2b              Raspberry Pi 2B (revision 1.1)
> realview-eb          ARM RealView Emulation Baseboard (ARM926EJ-S)
> realview-eb-mpcore   ARM RealView Emulation Baseboard (ARM11MPCore)
> realview-pb-a8       ARM RealView Platform Baseboard for Cortex-A8
> realview-pbx-a9      ARM RealView Platform Baseboard Explore for Cortex-A9
> romulus-bmc          OpenPOWER Romulus BMC (ARM1176)
> sabrelite            Freescale i.MX6 Quad SABRE Lite Board (Cortex-A9)
> smdkc210             Samsung SMDKC210 board (Exynos4210)
> sonorapass-bmc       OCP SonoraPass BMC (ARM1176)
> stm32vldiscovery     ST STM32VLDISCOVERY (Cortex-M3)
> supermicro-x11spi-bmc Supermicro X11 SPI BMC (ARM1176)
> supermicrox11-bmc    Supermicro X11 BMC (ARM926EJ-S)
> sx1                  Siemens SX1 (OMAP310) V2
> sx1-v1               Siemens SX1 (OMAP310) V1
> tiogapass-bmc        Facebook Tiogapass BMC (ARM1176)
> versatileab          ARM Versatile/AB (ARM926EJ-S)
> versatilepb          ARM Versatile/PB (ARM926EJ-S)
> vexpress-a15         ARM Versatile Express for Cortex-A15
> vexpress-a9          ARM Versatile Express for Cortex-A9
> virt                 QEMU 10.0 ARM Virtual Machine (alias of virt-10.0)
> virt-10.0            QEMU 10.0 ARM Virtual Machine
> virt-2.10            QEMU 2.10 ARM Virtual Machine (deprecated)
> virt-2.11            QEMU 2.11 ARM Virtual Machine (deprecated)
> virt-2.12            QEMU 2.12 ARM Virtual Machine (deprecated)
> virt-2.6             QEMU 2.6 ARM Virtual Machine (deprecated)
> virt-2.7             QEMU 2.7 ARM Virtual Machine (deprecated)
> virt-2.8             QEMU 2.8 ARM Virtual Machine (deprecated)
> virt-2.9             QEMU 2.9 ARM Virtual Machine (deprecated)
> virt-3.0             QEMU 3.0 ARM Virtual Machine (deprecated)
> virt-3.1             QEMU 3.1 ARM Virtual Machine (deprecated)
> virt-4.0             QEMU 4.0 ARM Virtual Machine (deprecated)
> virt-4.1             QEMU 4.1 ARM Virtual Machine (deprecated)
> virt-4.2             QEMU 4.2 ARM Virtual Machine (deprecated)
> virt-5.0             QEMU 5.0 ARM Virtual Machine (deprecated)
> virt-5.1             QEMU 5.1 ARM Virtual Machine (deprecated)
> virt-5.2             QEMU 5.2 ARM Virtual Machine (deprecated)
> virt-6.0             QEMU 6.0 ARM Virtual Machine (deprecated)
> virt-6.1             QEMU 6.1 ARM Virtual Machine (deprecated)
> virt-6.2             QEMU 6.2 ARM Virtual Machine (deprecated)
> virt-7.0             QEMU 7.0 ARM Virtual Machine
> virt-7.1             QEMU 7.1 ARM Virtual Machine
> virt-7.2             QEMU 7.2 ARM Virtual Machine
> virt-8.0             QEMU 8.0 ARM Virtual Machine
> virt-8.1             QEMU 8.1 ARM Virtual Machine
> virt-8.2             QEMU 8.2 ARM Virtual Machine
> virt-9.0             QEMU 9.0 ARM Virtual Machine
> virt-9.1             QEMU 9.1 ARM Virtual Machine
> virt-9.2             QEMU 9.2 ARM Virtual Machine
> witherspoon-bmc      OpenPOWER Witherspoon BMC (ARM1176)
> xilinx-zynq-a9       Xilinx Zynq 7000 Platform Baseboard for Cortex-A9
> yosemitev2-bmc       Facebook YosemiteV2 BMC (ARM1176)
> ```
### 參考
無

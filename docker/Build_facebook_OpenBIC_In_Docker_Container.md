# Build facebook OpenBIC In Docker Container

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
Provide an example of building [Facebook OpenBIC](<https://github.com/facebook/OpenBIC>) using Docker to help understand the build process.
### Solution
1. Pull the Docker image `zephyr-build:v0.17.0`, which comes with `zephyr-sdk-0.12.4` preinstalled.
```shell
docker pull zephyrprojectrtos/zephyr-build:v0.17.0
```
2. Create a working directory.
```shell
mkdir -p $HOME/Work
```
3. Launch the Docker container to clone the [Facebook OpenBIC](<https://github.com/facebook/OpenBIC>) repository into the designated working directory.
```shell
docker run -it -p 5900:5900 -v $HOME/Work:/workdir zephyrprojectrtos/zephyr-build:v0.17.0
```
> This is console output：
> ```console＝
> $ docker run -it -p 5900:5900 -v $HOME/Work:/workdir zephyrprojectrtos/zephyr-build:v0.17.0
> Openbox-Message: Unable to find a valid menu file "/var/lib/openbox/debian-menu.xml"
>
> ERROR: openbox-xdg-autostart requires PyXDG to be installed
> user@e10078cd7c42:/workdir$ Xlib:  extension "DPMS" missing on display ":0".
>
> The VNC desktop is:      e10078cd7c42:0
> PORT=5900
>
> user@e10078cd7c42:/workdir$
> ```
  - Clone the [Facebook OpenBIC](<https://github.com/facebook/OpenBIC>) repository and rename the folder to zephyrproject.
```shell
west init -m https://github.com/facebook/OpenBIC zephyrproject
```
  - Exit the Docker container.
```shell
exit
```
4. Re-launch the Docker container — this session is intended for updating the repository and performing the build.
> Note: The working directory has changed (from `$HOME/Work` to `$HOME/Work/zephyrproject`). Please check the differences in the parameters used in the `docker run` command.
```shell
docker run -it -p 5900:5900 -v $HOME/Work/zephyrproject:/workdir zephyrprojectrtos/zephyr-build:v0.17.0
```
  - Update the main repository, which will also fetch any necessary submodules or dependent repositories.
```shell
west update
```
  - For the `zephyr` and `zephyr_nuvoton` directories under the working directory, the code needs to be updated according to the [Facebook OpenBIC - fix_patch](<https://github.com/facebook/OpenBIC/tree/main/fix_patch>).

>    * As an example, navigate into the `zephyr` directory and list the available patch files using `ls`, then apply the patch using `git apply`.
```shell
cd /workdir/zephyr
ls ../openbic/fix_patch/tag_v00.01.06_d014527731033db477f806f5bff2e1ca5d4b2ba7/*.patch | sort | xargs -I{} git apply {}
```
>    * As an example, navigate into the `zephyr_nuvoton` directory and list the available patch files using `ls`, then apply the patch using `git apply`.
```shell
cd /workdir/zephyr_nuvoton/
ls ../openbic/fix_patch/nuvoton_tag_v2.6.0.0_cad6d72381ce408c40867f41a8741dba16e50bdf/*.patch | sort | xargs -I{} git apply {}
```
  - Build the project using yv35-cl as the target board example.
```shell
cd /workdir
west build -p auto -b ast1030_evb openbic/meta-facebook/yv35-cl/
```
> This is console output：
> ```console＝
> user@da18e80f601b:/workdir$ cd /workdir
> user@da18e80f601b:/workdir$ west build -p auto -b ast1030_evb openbic/meta-facebook/yv35-cl/
> -- west build: generating a build system
> Including boilerplate (Zephyr base): /workdir/zephyr/cmake/app/boilerplate.cmake
> -- Application: /workdir/openbic/meta-facebook/yv35-cl
> -- Zephyr version: 2.6.0 (/workdir/zephyr), build: v00.01.06
> -- Found Python3: /usr/bin/python3.8 (found suitable exact version "3.8.5") found components: Interpreter
> -- Found west (found suitable version "0.10.1", minimum required is "0.7.1")
> -- Board: ast1030_evb
> -- Cache files will be written to: /home/user/.cache/zephyr
> -- Using toolchain: zephyr 0.12.4 (/opt/toolchains/zephyr-sdk-0.12.4)
> -- Found dtc: /opt/toolchains/zephyr-sdk-0.12.4/sysroots/x86_64-pokysdk-linux/usr/bin/dtc (found suitable version "1.5.0", minimum required is "1.4.6")
> -- Found BOARD.dts: /workdir/zephyr/boards/arm/ast1030_evb/ast1030_evb.dts
> -- Found devicetree overlay: /workdir/openbic/meta-facebook/yv35-cl/boards/ast1030_evb.overlay
>
> （...ignore...）
>
> [355/362] Linking C executable zephyr/zephyr_prebuilt.elf
> 
> [362/362] Linking C executable zephyr/Y35BCL.elf
> Memory region         Used Size  Region Size  %age Used
>          SRAM_NC:       45120 B        60 KB     73.44%
>            FLASH:          0 GB         0 GB
>             SRAM:      566400 B       708 KB     78.12%
>         IDT_LIST:          0 GB         2 KB      0.00%
> user@da18e80f601b:/workdir$
> ```
5. Find the build output files after compilation.
```shell
find -name Y35BCL.elf
```
> This is console output：
> ```console＝
> user@da18e80f601b:/workdir$ find -name Y35BCL.elf
> ./build/zephyr/Y35BCL.elf
> user@da18e80f601b:/workdir$
> ```
#### Extension
To perform a clean build, remove the build folder from the project directory.
```shell
rm -rf /workdir/build/
```
### Reference
- [Facebook OpenBIC](<https://github.com/facebook/OpenBIC>)
- [zephyr-build](<https://hub.docker.com/r/zephyrprojectrtos/zephyr-build/tags>)

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
提供一種範例，使用 Docker 編譯 [Facebook OpenBIC](<https://github.com/facebook/OpenBIC>) ，用於理解建置流程。
### 解決方案
1. 下載 Docker Image ，使用 [zephyr-build](<https://hub.docker.com/r/zephyrprojectrtos/zephyr-build/tags>) `v0.17.0` 裡面包含 `zephyr-sdk-0.12.4` 。
```shell
docker pull zephyrprojectrtos/zephyr-build:v0.17.0
```
2. 建立工作目錄。
```shell
mkdir -p $HOME/Work
```
3. 啟動 Docker Container ：這次啟動用於下載 [Facebook OpenBIC](<https://github.com/facebook/OpenBIC>) 儲存庫到工作目錄。
```shell
docker run -it -p 5900:5900 -v $HOME/Work:/workdir zephyrprojectrtos/zephyr-build:v0.17.0
```
> 這是控制台輸出：
> ```console＝
> $ docker run -it -p 5900:5900 -v $HOME/Work:/workdir zephyrprojectrtos/zephyr-build:v0.17.0
> Openbox-Message: Unable to find a valid menu file "/var/lib/openbox/debian-menu.xml"
>
> ERROR: openbox-xdg-autostart requires PyXDG to be installed
> user@e10078cd7c42:/workdir$ Xlib:  extension "DPMS" missing on display ":0".
>
> The VNC desktop is:      e10078cd7c42:0
> PORT=5900
>
> user@e10078cd7c42:/workdir$
> ```
  - 下載 [Facebook OpenBIC](<https://github.com/facebook/OpenBIC>) 儲存庫，並且更名為 zephyrproject 資料夾
```shell
west init -m https://github.com/facebook/OpenBIC zephyrproject
```
  - 離開 Docker Container
```shell
exit
```
4. 再次啟動 Docker Container ：這次啟動用於更新儲存庫，也能用於編譯。
> 注意！變更 workdir 位置（`$HOME/Work` 改 `$HOME/Work/zephyrproject`），請看 `docker run` 內的參數差異。
```shell
docker run -it -p 5900:5900 -v $HOME/Work/zephyrproject:/workdir zephyrprojectrtos/zephyr-build:v0.17.0
```
  - 更新儲存庫（也會下載所需儲存庫）
```shell
west update
```
  - 針對工作目錄下的 `zephyr` 和 `zephyr_nuvoton` 資料夾，需要按照 [Facebook OpenBIC - fix_patch](<https://github.com/facebook/OpenBIC/tree/main/fix_patch>) 將程式碼更新

>    * 以 `zephyr` 資料夾為例子，進入資料夾後，使用 `ls` 指令搭配 `git apply` 方式。
```shell
cd /workdir/zephyr
ls ../openbic/fix_patch/tag_v00.01.06_d014527731033db477f806f5bff2e1ca5d4b2ba7/*.patch | sort | xargs -I{} git apply {}
```
>    * 以 `zephyr_nuvoton` 資料夾為例子，進入資料夾後，使用 `ls` 指令搭配 `git apply` 方式。
```shell
cd /workdir/zephyr_nuvoton/
ls ../openbic/fix_patch/nuvoton_tag_v2.6.0.0_cad6d72381ce408c40867f41a8741dba16e50bdf/*.patch | sort | xargs -I{} git apply {}
```
  - 編譯（以 yv35-cl 為例子）
```shell
cd /workdir
west build -p auto -b ast1030_evb openbic/meta-facebook/yv35-cl/
```
> 這是控制台輸出：
> ```console＝
> user@da18e80f601b:/workdir$ cd /workdir
> user@da18e80f601b:/workdir$ west build -p auto -b ast1030_evb openbic/meta-facebook/yv35-cl/
> -- west build: generating a build system
> Including boilerplate (Zephyr base): /workdir/zephyr/cmake/app/boilerplate.cmake
> -- Application: /workdir/openbic/meta-facebook/yv35-cl
> -- Zephyr version: 2.6.0 (/workdir/zephyr), build: v00.01.06
> -- Found Python3: /usr/bin/python3.8 (found suitable exact version "3.8.5") found components: Interpreter
> -- Found west (found suitable version "0.10.1", minimum required is "0.7.1")
> -- Board: ast1030_evb
> -- Cache files will be written to: /home/user/.cache/zephyr
> -- Using toolchain: zephyr 0.12.4 (/opt/toolchains/zephyr-sdk-0.12.4)
> -- Found dtc: /opt/toolchains/zephyr-sdk-0.12.4/sysroots/x86_64-pokysdk-linux/usr/bin/dtc (found suitable version "1.5.0", minimum required is "1.4.6")
> -- Found BOARD.dts: /workdir/zephyr/boards/arm/ast1030_evb/ast1030_evb.dts
> -- Found devicetree overlay: /workdir/openbic/meta-facebook/yv35-cl/boards/ast1030_evb.overlay
>
> （...ignore...）
>
> [355/362] Linking C executable zephyr/zephyr_prebuilt.elf
> 
> [362/362] Linking C executable zephyr/Y35BCL.elf
> Memory region         Used Size  Region Size  %age Used
>          SRAM_NC:       45120 B        60 KB     73.44%
>            FLASH:          0 GB         0 GB
>             SRAM:      566400 B       708 KB     78.12%
>         IDT_LIST:          0 GB         2 KB      0.00%
> user@da18e80f601b:/workdir$
> ```
5. 找出編譯後檔案。
```shell
find -name Y35BCL.elf
```
> 這是控制台輸出：
> ```console＝
> user@da18e80f601b:/workdir$ find -name Y35BCL.elf
> ./build/zephyr/Y35BCL.elf
> user@da18e80f601b:/workdir$
> ```
#### Extension
如果需要 Clean Build，直接將 Build 資料夾刪除即可。
```shell
rm -rf /workdir/build/
```
### Reference
- [Facebook OpenBIC](<https://github.com/facebook/OpenBIC>)
- [zephyr-build](<https://hub.docker.com/r/zephyrprojectrtos/zephyr-build/tags>)

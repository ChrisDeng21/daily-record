# Run OpenBMC Test Automation In Docker Container

## Language
[English](#English) | [中文](#中文)

## English

### Created Date
2025/03/27

### Update History
2025/06/11：Some users reported installation errors when building the Docker image, so it’s more suitable to build the QEMU tool manually instead.

### Environment
- **ISO**: `ubuntu-22.04.4-desktop-amd64.iso`

> Console output:
```shell
$ cat /etc/os-release
PRETTY_NAME="Ubuntu 22.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.4 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy

$ uname -a
Linux wilkes-evt 6.8.0-52-generic #53~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Wed Jan 15 19:18:46 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
```

### Symptom
None

### Cause
Provide an example that builds:

* [a Docker image with the openbmc-test-automation environment](#A-Docker-image-with-the-openbmc-test-automation-environment)
* [QEMU Tool](#QEMU-Tool)

And demonstrates how to perform testing on the emulator.

---

### Solution

#### Build

##### A Docker image with the openbmc-test-automation environment

1. Create a working directory.
```shell
mkdir -p ${HOME}/OpenBMC_Automation
```

2. Enter the working directory.
```shell
cd ${HOME}/OpenBMC_Automation
```

3. Clone the [openbmc-build-scripts](<https://github.com/openbmc/openbmc-build-scripts>) repository.
```shell
git clone https://github.com/openbmc/openbmc-build-scripts
```

4. Enter the repository directory.
```shell
cd openbmc-build-scripts
```

5. Start building the Docker image.
```shell
./scripts/build-qemu-robot-docker.sh
```

6. Once the build is complete, check if the Docker image has been successfully created.
```shell
docker images
```
> Console output：
```shell
$ docker images
REPOSITORY                       TAG            IMAGE ID       CREATED              SIZE
openbmc/ubuntu-robot-qemu        latest         5d73d6c8e6bb   About a minute ago   2.54GB
```

##### QEMU Tool

1. Enter the working directory.
```shell
cd ${HOME}/OpenBMC_Automation
```

2. Install the required packages for building the project.
```shell
sudo apt install -y build-essential libglib2.0-dev libpixman-1-dev zlib1g-dev git python3-pip ninja-build
pip install tomli
```

3. Clone the [qemu](<https://gitlab.com/qemu-project/qemu.git>) repository.
```shell
git clone https://gitlab.com/qemu-project/qemu.git
```

4. Enter the repository directory.
```shell
cd qemu
```

5. Set up the build target to support both ARM and AARCH64 architectures.
```shell
./configure --target-list=arm-softmmu,arm-linux-user,aarch64-softmmu,aarch64-linux-user --enable-slirp
```

6. Start building the QEMU tool.
```shell
make -j$(nproc)
```

---

### Test
Use two terminals to open the same Docker container — one for running the emulator and the other for executing automated tests.

#### Terminal 1：qemu-system-arm

1. Enter the working directory.
```shell
cd ${HOME}/OpenBMC_Automation
```

2. Download a prebuilt OpenBMC image—using the [romulus image](<https://jenkins.openbmc.org/job/latest-master/label=docker-builder,target=romulus/>) as an example.
```shell
wget https://jenkins.openbmc.org/job/latest-master/label=docker-builder,target=romulus/lastSuccessfulBuild/artifact/openbmc/build/tmp/deploy/images/romulus/obmc-phosphor-image-romulus.static.mtd
```

3. Launch the Docker container.
```shell
docker run --name openbmcTest --workdir ${HOME} --volume ${HOME}/OpenBMC_Automation:${HOME} -it openbmc/ubuntu-robot-qemu /bin/bash
```
> - `--name`：Assign a name to the Docker container when starting it.
> - `--workdir`：Configure the working directory within the Docker container.
> - `--volume`：Mount the local directory `${HOME}/OpenBMC_Automation` to the working directory inside the container.
> - `-it <images> /bin/bash`：Start the container from the image and enter the Bash shell in interactive mode.

4. Run the emulator.
```shell
qemu/build/qemu-system-arm -m 256 -M romulus-bmc -nographic -drive file=./obmc-phosphor-image-romulus.static.mtd,format=raw,if=mtd -net nic -net user,hostfwd=:127.0.0.1:2222-:22,hostfwd=:127.0.0.1:2443-:443,hostfwd=udp:127.0.0.1:2623-:623,hostname=qemu
```
> - `127.0.0.1:2222` Port Forwarding for the Emulator `22` (Used for SSH)
> - `127.0.0.1:2443` Port Forwarding for the Emulator `443` (Used for HTTPS/REDFISH)
> - `127.0.0.1:2623` Port Forwarding for the Emulator `623` (Used for IPMI)

#### Terminal 2：openbmc-test-automation

1. Enter the working directory.
```shell
cd ${HOME}/OpenBMC_Automation
```

2. Clone the [openbmc-test-automation](<https://github.com/openbmc/openbmc-test-automation>) repository.
```shell
git clone https://github.com/openbmc/openbmc-test-automation.git
```

3. Access the previously started Docker container.
```shell
docker exec -it openbmcTest /bin/bash
```

4. Use ipmitool to verify whether the emulator is running.
```shell
ipmitool -I lanplus -C 17 -U root -P 0penBmc -H 127.0.0.1 -p 2623 mc info
```
> Console output：
```shell
$ ipmitool -I lanplus -C 17 -U root -P 0penBmc -H 127.0.0.1 -p 2623 mc info
Device ID                 : 0
Device Revision           : 0
Firmware Revision         : 2.18
IPMI Version              : 2.0
Manufacturer ID           : 0
Manufacturer Name         : Unknown
Product ID                : 0 (0x0000)
Product Name              : Unknown (0x0)
Device Available          : yes
Provides Device SDRs      : yes
Additional Device Support :
    Sensor Device
    SEL Device
    FRU Inventory Device
    Chassis Device
Aux Firmware Rev Info     :
    0x00
    0x00
    0x00
    0x00

```

> Sample commands for testing Redfish
```shell
curl -k https://root:0penBmc@localhost:2443/redfish/v1
```

> Sample commands for testing SSH
```shell
ssh -p 2222 root@127.0.0.1
```

5. Use Robot Framework to test the emulator.
```shell
robot -v OPENBMC_HOST:127.0.0.1 -v OPENBMC_PASSWORD:0penBmc -v SSH_PORT:2222 -v HTTPS_PORT:2443 -v IPMI_PORT:2623 openbmc-test-automation/templates/test_openbmc_setup.robot
```
> Console output：
```shell
$ robot -v OPENBMC_HOST:127.0.0.1 -v OPENBMC_PASSWORD:0penBmc -v SSH_PORT:2222 -v HTTPS_PORT:2443 -v IPMI_PORT:2623 openbmc-test-automation/templates/test_openbmc_setup.robot
#(UTC) 2025/03/27 02:16:55.781560 -    0.186868 - Executing: get('/redfish/v1/')
#(UTC) 2025/03/27 02:16:55.997564 -    0.216004 - Executing: get('/redfish/v1/')
#(UTC) 2025/03/27 02:16:56.068714 -    0.071150 - Executing: get('/redfish/v1/')
#(UTC) 2025/03/27 02:16:57.990623 -    1.921909 - Issuing: ipmitool -I lanplus -C 17 -N 3 -p 2623 -U root -P ********** -H 127.0.0.1 power status
rc:                                               0x0000000000000000
==============================================================================
Test Openbmc Setup :: Test suite to verify if the Robot setup is ready for ...
==============================================================================
Test Redfish Setup :: Verify Redfish works.                           .#(UTC) 2025/03/27 02:16:58.782809 -    0.792186 - Executing: get('/redfish/v1/')
.#(UTC) 2025/03/27 02:16:58.802680 -    0.019871 - Executing: delete('/redfish/v1/SessionService/Sessions/YvNO1WpNkz')
Test Redfish Setup :: Verify Redfish works.                           | PASS |
------------------------------------------------------------------------------
Test SSH Setup :: Verify SSH works.                                   #(UTC) 2025/03/27 02:16:58.861828 -    0.059148 - Issuing: uname -a
root@romulus:~#
Linux romulus 6.6.84-36db6e8-00385-g36db6e8484ed #1 Mon Mar 24 02:47:12 UTC 2025 armv6l GNU/Linux
Linux romulus 6.6.84-36db6e8-00385-g36db6e8484ed #1 Mon Mar 24 02:47:12 UTC 2025 armv6l GNU/Linux
Test SSH Setup :: Verify SSH works.                                   | PASS |
------------------------------------------------------------------------------
Test IPMI Setup :: Verify Out-of-band works.                          #(UTC) 2025/03/27 02:17:00.404984 -    0.014049 - Issuing: ipmitool -I lanplus -C 17 -N 3 -p 2623 -U root -P ********** -H 127.0.0.1 chassis status
.
 System Power         : off
Power Overload       : false
Power Interlock      : inactive
Main Power Fault     : false
Power Control Fault  : false
Power Restore Policy : always-off
Last Power Event     :
Chassis Intrusion    : inactive
Front-Panel Lockout  : inactive
Drive Fault          : false
Cooling/Fan Fault    : false
Sleep Button Disable : not allowed
Diag Button Disable  : not allowed
Reset Button Disable : allowed
Power Button Disable : not allowed
Sleep Button Disabled: false
Diag Button Disabled : false
Reset Button Disabled: false
Power Button Disabled: false
Test IPMI Setup :: Verify Out-of-band works.                          | PASS |
------------------------------------------------------------------------------
Test Openbmc Setup :: Test suite to verify if the Robot setup is r... | PASS |
3 tests, 3 passed, 0 failed
==============================================================================
Output:  /home/chrisdeng/output.xml
Log:     /home/chrisdeng/log.html
Report:  /home/chrisdeng/report.html

```

### Extension

1. To exit the QEMU emulator: press Ctrl + a, then press the x key.
2. After running the Robot tests, the generated files output.xml, log.html, and report.html will be saved in the current directory where the command was executed.

### Reference

- [Run OpenBMC Test Automation Using Docker](<https://github.com/openbmc/docs/blob/master/testing/run-test-docker.md>)
- [在 QEMU 中运行 OpenBMC](<https://jia.je/system/2023/08/11/openbmc-qemu/#romulus>)

## 中文

### 建立日期
2025/03/27

### 更新歷史
2025/06/11：有人反應目前編譯 Docker Image 會出現安裝錯誤，所以改成自己編譯 QEMU 工具比較適合。

### 環境
- **ISO**: `ubuntu-22.04.4-desktop-amd64.iso`

> 控制台輸出：
```shell
$ cat /etc/os-release
PRETTY_NAME="Ubuntu 22.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.4 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy

$ uname -a
Linux wilkes-evt 6.8.0-52-generic #53~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Wed Jan 15 19:18:46 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
```

### 症狀
無

### 原因
提供一種範例，編譯:

* [具備 openbmc-test-automation 環境的 Docker Image](#具備-openbmc-test-automation-環境的-Docker-Image) 
* [QEMU 工具](#QEMU-工具)

並且演示如何對模擬器進行測試。

---

### 解決方案

#### 建造

##### 具備 openbmc-test-automation 環境的 Docker Image

1. 建立工作目錄。
```shell
mkdir -p ${HOME}/OpenBMC_Automation
```

2. 進入工作目錄。
```shell
cd ${HOME}/OpenBMC_Automation
```

3. 下載 [openbmc-build-scripts](<https://github.com/openbmc/openbmc-build-scripts>) 儲存庫。
```shell
git clone https://github.com/openbmc/openbmc-build-scripts
```

4. 進入儲存庫目錄。
```shell
cd openbmc-build-scripts
```

5. 開始編譯 Docker Image 。
```shell
./scripts/build-qemu-robot-docker.sh
```

6. 完成後確認 Docker Image 是否存在。
```shell
docker images
```
> 控制台輸出：
```shell
$ docker images
REPOSITORY                       TAG            IMAGE ID       CREATED              SIZE
openbmc/ubuntu-robot-qemu        latest         5d73d6c8e6bb   About a minute ago   2.54GB
```

##### QEMU 工具

1. 進入工作目錄。
```shell
cd ${HOME}/OpenBMC_Automation
```

2. 安裝編譯所需套件。
```shell
sudo apt install -y build-essential libglib2.0-dev libpixman-1-dev zlib1g-dev git python3-pip ninja-build
pip install tomli
```

3. 下載 [qemu](<https://gitlab.com/qemu-project/qemu.git>) 儲存庫。
```shell
git clone https://gitlab.com/qemu-project/qemu.git
```

4. 進入儲存庫目錄。
```shell
cd qemu
```

5. 配置建置目標。（支援 ARM 與 AARCH64 平台）
```shell
./configure --target-list=arm-softmmu,arm-linux-user,aarch64-softmmu,aarch64-linux-user --enable-slirp
```

6. 開始編譯 QEMU 工具。
```shell
make -j$(nproc)
```

---

### 測試
使用兩個終端機，將會開啟同個 Docker Dontainer ，一個用於執行模擬器，一個用於執行自動測試。

#### 終端機 1：qemu-system-arm

1. 進入工作目錄。
```shell
cd ${HOME}/OpenBMC_Automation
```

2. 下載現成 OpenBMC Image ，這裡以 [romulus image](<https://jenkins.openbmc.org/job/latest-master/label=docker-builder,target=romulus/>) 為例。
```shell
wget https://jenkins.openbmc.org/job/latest-master/label=docker-builder,target=romulus/lastSuccessfulBuild/artifact/openbmc/build/tmp/deploy/images/romulus/obmc-phosphor-image-romulus.static.mtd
```

3. 啟動 Docker Container 。
```shell
docker run --name openbmcTest --workdir ${HOME} --volume ${HOME}/OpenBMC_Automation:${HOME} -it openbmc/ubuntu-robot-qemu /bin/bash
```
> - `--name`：啟動 Docker 容器時為該容器命名
> - `--workdir`：設置容器內的工作目錄（工作資料夾）
> - `--volume`：將本機目錄 `${HOME}/OpenBMC_Automation` 掛載到容器內的工作目錄
> - `-it <images> /bin/bash`：啟動映像的容器，並以交互模式進入 bash shell

4. 執行模擬器。
```shell
qemu/build/qemu-system-arm -m 256 -M romulus-bmc -nographic -drive file=./obmc-phosphor-image-romulus.static.mtd,format=raw,if=mtd -net nic -net user,hostfwd=:127.0.0.1:2222-:22,hostfwd=:127.0.0.1:2443-:443,hostfwd=udp:127.0.0.1:2623-:623,hostname=qemu
```
> - `127.0.0.1:2222` 轉發模擬器連接埠 `22` (用於SSH)
> - `127.0.0.1:2443` 轉發模擬器連接埠 `443` (用於HTTPS/REDFISH)
> - `127.0.0.1:2623` 轉發模擬器連接埠 `623` (用於IPMI)

#### 終端機 2：openbmc-test-automation

1. 進入工作目錄。
```shell
cd ${HOME}/OpenBMC_Automation
```

2. 下載 [openbmc-test-automation](<https://github.com/openbmc/openbmc-test-automation>) 儲存庫。
```shell
git clone https://github.com/openbmc/openbmc-test-automation.git
```

3. 登入剛剛已啟動的 Docker Container 。
```shell
docker exec -it openbmcTest /bin/bash
```

4. 使用 ipmitool 確認模擬器是否存在。
```shell
ipmitool -I lanplus -C 17 -U root -P 0penBmc -H 127.0.0.1 -p 2623 mc info
```
> 控制台輸出：
```shell
$ ipmitool -I lanplus -C 17 -U root -P 0penBmc -H 127.0.0.1 -p 2623 mc info
Device ID                 : 0
Device Revision           : 0
Firmware Revision         : 2.18
IPMI Version              : 2.0
Manufacturer ID           : 0
Manufacturer Name         : Unknown
Product ID                : 0 (0x0000)
Product Name              : Unknown (0x0)
Device Available          : yes
Provides Device SDRs      : yes
Additional Device Support :
    Sensor Device
    SEL Device
    FRU Inventory Device
    Chassis Device
Aux Firmware Rev Info     :
    0x00
    0x00
    0x00
    0x00

```

> 測試 Redfish 的參考指令
```shell
curl -k https://root:0penBmc@localhost:2443/redfish/v1
```

> 測試 SSH 的參考指令
```shell
ssh -p 2222 root@127.0.0.1
```

5. 使用 robot 測試模擬器。
```shell
robot -v OPENBMC_HOST:127.0.0.1 -v OPENBMC_PASSWORD:0penBmc -v SSH_PORT:2222 -v HTTPS_PORT:2443 -v IPMI_PORT:2623 openbmc-test-automation/templates/test_openbmc_setup.robot
```
> 控制台輸出：
```shell
$ robot -v OPENBMC_HOST:127.0.0.1 -v OPENBMC_PASSWORD:0penBmc -v SSH_PORT:2222 -v HTTPS_PORT:2443 -v IPMI_PORT:2623 openbmc-test-automation/templates/test_openbmc_setup.robot
#(UTC) 2025/03/27 02:16:55.781560 -    0.186868 - Executing: get('/redfish/v1/')
#(UTC) 2025/03/27 02:16:55.997564 -    0.216004 - Executing: get('/redfish/v1/')
#(UTC) 2025/03/27 02:16:56.068714 -    0.071150 - Executing: get('/redfish/v1/')
#(UTC) 2025/03/27 02:16:57.990623 -    1.921909 - Issuing: ipmitool -I lanplus -C 17 -N 3 -p 2623 -U root -P ********** -H 127.0.0.1 power status
rc:                                               0x0000000000000000
==============================================================================
Test Openbmc Setup :: Test suite to verify if the Robot setup is ready for ...
==============================================================================
Test Redfish Setup :: Verify Redfish works.                           .#(UTC) 2025/03/27 02:16:58.782809 -    0.792186 - Executing: get('/redfish/v1/')
.#(UTC) 2025/03/27 02:16:58.802680 -    0.019871 - Executing: delete('/redfish/v1/SessionService/Sessions/YvNO1WpNkz')
Test Redfish Setup :: Verify Redfish works.                           | PASS |
------------------------------------------------------------------------------
Test SSH Setup :: Verify SSH works.                                   #(UTC) 2025/03/27 02:16:58.861828 -    0.059148 - Issuing: uname -a
root@romulus:~#
Linux romulus 6.6.84-36db6e8-00385-g36db6e8484ed #1 Mon Mar 24 02:47:12 UTC 2025 armv6l GNU/Linux
Linux romulus 6.6.84-36db6e8-00385-g36db6e8484ed #1 Mon Mar 24 02:47:12 UTC 2025 armv6l GNU/Linux
Test SSH Setup :: Verify SSH works.                                   | PASS |
------------------------------------------------------------------------------
Test IPMI Setup :: Verify Out-of-band works.                          #(UTC) 2025/03/27 02:17:00.404984 -    0.014049 - Issuing: ipmitool -I lanplus -C 17 -N 3 -p 2623 -U root -P ********** -H 127.0.0.1 chassis status
.
 System Power         : off
Power Overload       : false
Power Interlock      : inactive
Main Power Fault     : false
Power Control Fault  : false
Power Restore Policy : always-off
Last Power Event     :
Chassis Intrusion    : inactive
Front-Panel Lockout  : inactive
Drive Fault          : false
Cooling/Fan Fault    : false
Sleep Button Disable : not allowed
Diag Button Disable  : not allowed
Reset Button Disable : allowed
Power Button Disable : not allowed
Sleep Button Disabled: false
Diag Button Disabled : false
Reset Button Disabled: false
Power Button Disabled: false
Test IPMI Setup :: Verify Out-of-band works.                          | PASS |
------------------------------------------------------------------------------
Test Openbmc Setup :: Test suite to verify if the Robot setup is r... | PASS |
3 tests, 3 passed, 0 failed
==============================================================================
Output:  /home/chrisdeng/output.xml
Log:     /home/chrisdeng/log.html
Report:  /home/chrisdeng/report.html

```

### Extension

1. 離開 QEMU 模擬器：快捷鍵 Ctrl + a，然後按 x 鍵。
2. robot 測試後生成的 `output.xml` `log.html` `report.html` 會儲存執行指令的當前目錄位置下。

### Reference

- [Run OpenBMC Test Automation Using Docker](<https://github.com/openbmc/docs/blob/master/testing/run-test-docker.md>)
- [在 QEMU 中运行 OpenBMC](<https://jia.je/system/2023/08/11/openbmc-qemu/#romulus>)

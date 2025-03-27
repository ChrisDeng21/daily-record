# Run OpenBMC Test Automation In Docker Container

## Created Date
2025/03/27

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
提供一種範例，編譯出具備 qemu-system-arm 與 openbmc-test-automation 的 Docker Image ，並且演示如何對模擬器進行測試。

## Solution

### Build
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

5. 修改 `scripts/build-qemu-robot-docker.sh` ，添加 `qemu-system-arm` 套件。
```shell
vim scripts/build-qemu-robot-docker.sh
```
- 以下是檔案部份內容展示，主要在 `apt-get install -yy` 後加上 `qemu-system-arm`
```bash
# Create docker image that can run QEMU and Robot Tests
Dockerfile=$(cat << EOF
FROM ${docker_reg}/${DISTRO}

${MIRROR}

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yy \
    debianutils \
    gawk \
    git \
    python2 \
    python2-dev \
    python-setuptools \
    python3 \
    python3-dev \
    python3-setuptools \
    socat \
    texinfo \
    wget \
    gcc \
    libffi-dev \
    libssl-dev \
    xterm \
    mwm \
    ssh \
    vim \
    iputils-ping \
    sudo \
    cpio \
    unzip \
    diffstat \
    expect \
    curl \
    build-essential \
    libdbus-glib-1-2 \
    libpixman-1-0 \
    libglib2.0-0 \
    sshpass \
    libasound2 \
    libfdt1 \
    libpcre3 \
    libslirp-dev \
    openssl \
    libxml2-dev \
    libxslt-dev \
    python3-pip \
    ipmitool \
    xvfb \
    rustc \
    qemu-system-arm

RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install firefox \
  && wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/112.0.2/linux-x86_64/en-US/firefox-112.0.2.tar.bz2 \
  && apt-get -y purge firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-112.0.2 \
  && ln -fs /opt/firefox-112.0.2/firefox /usr/bin/firefox

ENV HOME ${HOME}
```
- 存檔離開

6. 開始編譯 Docker Image 。
```shell
./scripts/build-qemu-robot-docker.sh
```

7. 完成後確認 Docker Image 是否存在。
```shell
docker images
```

> This is console output：
> ```console＝
> $ docker images
> REPOSITORY                       TAG            IMAGE ID       CREATED              SIZE
> openbmc/ubuntu-robot-qemu        latest         5d73d6c8e6bb   About a minute ago   2.54GB
> ```

### Test
使用 SSH 登入兩個 Terminal ，一個用於執行模擬器，一個用於執行自動測試。

#### Terminal 1：qemu-system-arm
1. 進入工作目錄。
```shell
cd ${HOME}/OpenBMC_Automation
```

2. 下載現成 OpenBMC Image ， 這裡以 [romulus image](<https://jenkins.openbmc.org/job/latest-master/label=docker-builder,target=romulus/>) 為例。
```shell
wget https://jenkins.openbmc.org/job/latest-master/label=docker-builder,target=romulus/lastSuccessfulBuild/artifact/openbmc/build/tmp/deploy/images/romulus/obmc-phosphor-image-romulus.static.mtd
```

3. 啟動 docker container 。
```shell
docker run --name openbmcTest --workdir ${HOME} --volume ${HOME}/OpenBMC_Automation:${HOME} -it openbmc/ubuntu-robot-qemu /bin/bash
```
> - `--name`：啟動 Docker 容器時為該容器命名
> - `--workdir`：設置容器內的工作目錄（工作資料夾）
> - `--volume`：將本機目錄 `${HOME}/OpenBMC_Automation` 掛載到容器內的工作目錄
> - `-it <images> /bin/bash`：啟動映像的容器，並以交互模式進入 bash shell

4. 執行模擬器。
```shell
qemu-system-arm -m 256 -M romulus-bmc -nographic -drive file=./obmc-phosphor-image-romulus.static.mtd,format=raw,if=mtd -net nic -net user,hostfwd=:127.0.0.1:2222-:22,hostfwd=:127.0.0.1:2443-:443,hostfwd=udp:127.0.0.1:2623-:623,hostname=qemu
```
> - `127.0.0.1:2222` 轉發模擬器連接埠 `22` (用於SSH)
> - `127.0.0.1:2443` 轉發模擬器連接埠 `443` (用於HTTPS/REDFISH)
> - `127.0.0.1:2623` 轉發模擬器連接埠 `623` (用於IPMI)

#### Terminal 2：openbmc-test-automation
1. 進入工作目錄。
```shell
cd ${HOME}/OpenBMC_Automation
```

2. 下載 [openbmc-test-automation](<https://github.com/openbmc/openbmc-test-automation>) 儲存庫。
```shell
git clone https://github.com/openbmc/openbmc-test-automation.git
```

3. 登入剛剛已啟動的 docker container 。
```shell
docker exec -it openbmcTest /bin/bash
```

4. 使用 ipmitool 確認模擬器是否存在。
```shell
ipmitool -I lanplus -C 17 -U root -P 0penBmc -H 127.0.0.1 -p 2623 mc info
```
> This is console output：
> ```console＝
> $ ipmitool -I lanplus -C 17 -U root -P 0penBmc -H 127.0.0.1 -p 2623 mc info
> Device ID                 : 0
> Device Revision           : 0
> Firmware Revision         : 2.18
> IPMI Version              : 2.0
> Manufacturer ID           : 0
> Manufacturer Name         : Unknown
> Product ID                : 0 (0x0000)
> Product Name              : Unknown (0x0)
> Device Available          : yes
> Provides Device SDRs      : yes
> Additional Device Support :
>     Sensor Device
>     SEL Device
>     FRU Inventory Device
>     Chassis Device
> Aux Firmware Rev Info     :
>     0x00
>     0x00
>     0x00
>     0x00
> 
> ```

5. 使用 robot 測試模擬器。
```shell
robot -v OPENBMC_HOST:127.0.0.1 -v OPENBMC_PASSWORD:0penBmc -v SSH_PORT:2222 -v HTTPS_PORT:2443 -v IPMI_PORT:2623 openbmc-test-automation/templates/test_openbmc_setup.robot
```
> This is console output：
> ```console＝
> $ robot -v OPENBMC_HOST:127.0.0.1 -v OPENBMC_PASSWORD:0penBmc -v SSH_PORT:2222 -v HTTPS_PORT:2443 -v IPMI_PORT:2623 openbmc-test-automation/templates/test_openbmc_setup.robot
> #(UTC) 2025/03/27 02:16:55.781560 -    0.186868 - Executing: get('/redfish/v1/')
> #(UTC) 2025/03/27 02:16:55.997564 -    0.216004 - Executing: get('/redfish/v1/')
> #(UTC) 2025/03/27 02:16:56.068714 -    0.071150 - Executing: get('/redfish/v1/')
> #(UTC) 2025/03/27 02:16:57.990623 -    1.921909 - Issuing: ipmitool -I lanplus -C 17 -N 3 -p 2623 -U root -P ********** -H 127.0.0.1 power status
> rc:                                               0x0000000000000000
> ==============================================================================
> Test Openbmc Setup :: Test suite to verify if the Robot setup is ready for ...
> ==============================================================================
> Test Redfish Setup :: Verify Redfish works.                           .#(UTC) 2025/03/27 02:16:58.782809 -    0.792186 - Executing: get('/redfish/v1/')
> .#(UTC) 2025/03/27 02:16:58.802680 -    0.019871 - Executing: delete('/redfish/v1/SessionService/Sessions/YvNO1WpNkz')
> Test Redfish Setup :: Verify Redfish works.                           | PASS |
> ------------------------------------------------------------------------------
> Test SSH Setup :: Verify SSH works.                                   #(UTC) 2025/03/27 02:16:58.861828 -    0.059148 - Issuing: uname -a
> root@romulus:~#
> Linux romulus 6.6.84-36db6e8-00385-g36db6e8484ed #1 Mon Mar 24 02:47:12 UTC 2025 armv6l GNU/Linux
> Linux romulus 6.6.84-36db6e8-00385-g36db6e8484ed #1 Mon Mar 24 02:47:12 UTC 2025 armv6l GNU/Linux
> Test SSH Setup :: Verify SSH works.                                   | PASS |
> ------------------------------------------------------------------------------
> Test IPMI Setup :: Verify Out-of-band works.                          #(UTC) 2025/03/27 02:17:00.404984 -    0.014049 - Issuing: ipmitool -I lanplus -C 17 -N 3 -p 2623 -U root -P ********** -H 127.0.0.1 chassis status
> .
>  System Power         : off
> Power Overload       : false
> Power Interlock      : inactive
> Main Power Fault     : false
> Power Control Fault  : false
> Power Restore Policy : always-off
> Last Power Event     :
> Chassis Intrusion    : inactive
> Front-Panel Lockout  : inactive
> Drive Fault          : false
> Cooling/Fan Fault    : false
> Sleep Button Disable : not allowed
> Diag Button Disable  : not allowed
> Reset Button Disable : allowed
> Power Button Disable : not allowed
> Sleep Button Disabled: false
> Diag Button Disabled : false
> Reset Button Disabled: false
> Power Button Disabled: false
> Test IPMI Setup :: Verify Out-of-band works.                          | PASS |
> ------------------------------------------------------------------------------
> Test Openbmc Setup :: Test suite to verify if the Robot setup is r... | PASS |
> 3 tests, 3 passed, 0 failed
> ==============================================================================
> Output:  /home/chrisdeng/output.xml
> Log:     /home/chrisdeng/log.html
> Report:  /home/chrisdeng/report.html
> 
> ```

### Extension
1. 離開 QEMU 模擬器：快捷鍵 Ctrl + a，然後按 x 鍵。
2. robot 測試後生成的 `output.xml` `log.html` `report.html` 會儲存執行指令的當前目錄位置下。

## Reference
[Run OpenBMC Test Automation Using Docker](<https://github.com/openbmc/docs/blob/master/testing/run-test-docker.md>) \
[在 QEMU 中运行 OpenBMC](<https://jia.je/system/2023/08/11/openbmc-qemu/#romulus>)

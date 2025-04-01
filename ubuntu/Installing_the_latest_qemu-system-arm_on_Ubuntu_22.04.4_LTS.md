# Installing the latest qemu-system-arm on Ubuntu 22.04.4 LTS

## Created Date
2025/04/01

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
The qemu-system-arm version 6.2 was installed from the APT server, but the ast1030-evb is not listed among the supported machines.

## Solution
1. Install a few prerequisite packages which let qemu build successfully.
  - System's packages：
```shell
sudo apt-get install -y build-essential libglib2.0-dev libpixman-1-dev zlib1g-dev git python3-pip ninja-build
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
./configure --target-list=arm-softmmu,arm-linux-user
```
> `arm-softmmu`：It's for system mode.
> `arm-linux-user`：It's for user mode.

4. Compile QEMU.
```shell
make -j$(nproc)
```

### Method 1：Use qemu-system-arm directly
1. Execute binary file in build directory.
  - A sample for check version：
```shell
./build/qemu-system-arm --version
```
> This is console output：
> ```console＝
> $ ./build/qemu-system-arm --version
> QEMU emulator version 9.2.91 (v10.0.0-rc1-15-g0f15892aca)
> Copyright (c) 2003-2025 Fabrice Bellard and the QEMU Project developers
> ```

### Method 2：Install qemu-system-arm to system environment
1. Install to system.
```shell
sudo make install
```

2. Verify the installion is success.
```shell
qemu-system-arm --version
```
> This is console output：
> ```console＝
> $ qemu-system-arm --version
> QEMU emulator version 9.2.91 (v10.0.0-rc1-15-g0f15892aca)
> Copyright (c) 2003-2025 Fabrice Bellard and the QEMU Project developers
> ```

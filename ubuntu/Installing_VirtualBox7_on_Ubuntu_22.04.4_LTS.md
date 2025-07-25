# Installing VirtualBox7 on Ubuntu 22.04.4 LTS

## Language
[English](#English) | [中文](#中文)

## English
### Created Date
2025/03/04
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
VirtualBox 6 fails to run.
### Cause
VirtualBox 6 isn't compatible with the new kernel.
### Solution
1. Create the repository for VirtualBox.
```shell
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
```
2. Download and Register the Oracle public key for verifying the signatures.
```shell
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
```
3. Download package information from all configured sources.
```shell
sudo apt update
```
4. Install VirtualBox.
  - VirtualBox 7.0
```shell
sudo apt install -y virtualbox-7.0
```
  - VirtualBox 7.1
```shell
sudo apt install -y virtualbox-7.1
```
### Reference
- [Link](<https://udhayakumarc.medium.com/installing-virtualbox-7-in-ubuntu-22-363193e5a691>)

## 中文
### 建立日期
2025/03/04
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
VirtualBox 6 無法運作。
### 原因
VirtualBox 6 與新核心不相容。
### 解決方案
1. 為 VirtualBox 建立儲存庫。
```shell
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
```
2. 下載並註冊 Oracle 公鑰以驗證簽名。
```shell
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
```
3. 從所有配置的來源下載套件資訊。
```shell
sudo apt update
```
4. 安裝 VirtualBox。
  - VirtualBox 7.0
```shell
sudo apt install -y virtualbox-7.0
```
  - VirtualBox 7.1
```shell
sudo apt install -y virtualbox-7.1
```
### 參考
- [連結](<https://udhayakumarc.medium.com/installing-virtualbox-7-in-ubuntu-22-363193e5a691>)

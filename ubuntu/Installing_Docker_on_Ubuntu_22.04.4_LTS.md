# Installing Docker on Ubuntu 22.04.4 LTS

## Language
[English](#English) | [中文](#中文)

## English
### Created Date
2025/03/04
### Environment
ubuntu-22.04.4-desktop-amd64.iso
> This is console output：
> ```console=
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
None
### Solution
1. Update your existing list of packages.
```shell
sudo apt update
```
2. Install a few prerequisite packages which let apt use packages over HTTPS.
```shell
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```
3. Add the GPG key for the official Docker repository to your system.
```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
4. Add the Docker repository to APT sources.
```shell
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
5. Download package information from all configured sources.
```shell
sudo apt update
```
6. Make sure you are about to install from the Docker repo instead of the default Ubuntu repo.
```shell
apt-cache policy docker-ce
```
> This is console output：
> ```console=
> $ apt-cache policy docker-ce
> docker-ce:
>   Installed: (none)
>   Candidate: 5:28.0.1-1~ubuntu.22.04~jammy
>   Version table:
>      5:28.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:28.0.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.5.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.5.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.4.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.4.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.3.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.3.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.2.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.2.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.1.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.1.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.1.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.0.3-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.0.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.1.4-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.1.3-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.1.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.1.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.1.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.0.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.0.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.5-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.4-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.3-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.9-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.8-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.7-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.6-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.5-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.4-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.3-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.6-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.5-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.4-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.3-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.24~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.23~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.22~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.21~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.20~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.19~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.18~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.17~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.16~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.15~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.14~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.13~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
> ```
7. Install Docker.
```shell
sudo apt install -y docker-ce
```
8. Check that it’s running.
```shell
sudo systemctl status docker
```
> This is console output：
> ```console=
> $ sudo systemctl status docker
> ● docker.service - Docker Application Container Engine
>      Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
>      Active: active (running) since Thu 2025-02-27 14:11:29 CST; 4 days ago
> TriggeredBy: ● docker.socket
>        Docs: https://docs.docker.com
>    Main PID: 2874 (dockerd)
>       Tasks: 38
>      Memory: 100.8M
>         CPU: 1min 44.562s
>      CGroup: /system.slice/docker.service
>              └─2874 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
> 
> Feb 27 14:11:28 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:28.890129302+08:00" level=info msg="detected 127.0.0.53 nameserver, assuming systemd-resolved, so using resolv.conf: /run/systemd/resolve/resolv.conf"
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.016470639+08:00" level=info msg="[graphdriver] using prior storage driver: overlay2"
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.024669616+08:00" level=info msg="Loading containers: start."
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.705815252+08:00" level=info msg="Loading containers: done."
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.739112119+08:00" level=info msg="Docker daemon" commit=af898ab containerd-snapshotter=false storage-driver=overlay2 version=28.0.0
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.739318376+08:00" level=info msg="Initializing buildkit"
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.791571564+08:00" level=info msg="Completed buildkit initialization"
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.799787483+08:00" level=info msg="Daemon has completed initialization"
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.799893542+08:00" level=info msg="API listen on /run/docker.sock"
> Feb 27 14:11:29 wilkes-evt systemd[1]: Started Docker Application Container Engine.
> ```
9. Avoid typing sudo whenever you run the docker command, add your username to the docker group.
- Current logging user：
```shell
sudo usermod -aG docker ${USER}
```
- Other non-login user：
```shell
sudo usermod -aG docker <username>
```
> If `<username>` is john.
> 
> $ sudo usermod -aG docker john
>
> If `<username>` is iris.
> 
> $ sudo usermod -aG docker iris
10. To apply the new group membership, log out of the server and back in.
### Reference
- [Link](<https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04>)

## 中文
### 建立日期
2025/03/04
### 環境
ubuntu-22.04.4-desktop-amd64.iso
> 這是控制台輸出：
> ```console=
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
無
### 解決方案
1. 更新您現有的套件清單。
```shell
sudo apt update
```
2. 安裝一些必備軟體包，以便 apt 透過 HTTPS 使用軟體包。
```shell
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```
3. 將官方 Docker 儲存庫的 GPG 金鑰新增至您的系統。
```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
4. 將 Docker 儲存庫新增至 APT 來源。
```shell
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
5. 從所有配置的來源下載套件資訊。
```shell
sudo apt update
```
6. 確保您即將從 Docker 倉庫而不是預設的 Ubuntu 倉庫進行安裝。
```shell
apt-cache policy docker-ce
```
> 這是控制台輸出：
> ```console=
> $ apt-cache policy docker-ce
> docker-ce:
>   Installed: (none)
>   Candidate: 5:28.0.1-1~ubuntu.22.04~jammy
>   Version table:
>      5:28.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:28.0.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.5.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.5.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.4.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.4.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.3.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.3.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.2.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.2.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.1.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.1.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.1.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.0.3-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.0.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:27.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.1.4-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.1.3-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.1.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.1.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.1.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.0.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:26.0.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.5-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.4-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.3-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:25.0.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.9-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.8-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.7-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.6-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.5-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.4-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.3-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:24.0.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.6-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.5-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.4-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.3-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.2-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.1-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:23.0.0-1~ubuntu.22.04~jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.24~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.23~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.22~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.21~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.20~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.19~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.18~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.17~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.16~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.15~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.14~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
>      5:20.10.13~3-0~ubuntu-jammy 500
>         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
> ```
7. 安裝 Docker。
```shell
sudo apt install -y docker-ce
```
8. 檢查它是否正在運行。
```shell
sudo systemctl status docker
```
> 這是控制台輸出：
> ```console=
> $ sudo systemctl status docker
> ● docker.service - Docker Application Container Engine
>      Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
>      Active: active (running) since Thu 2025-02-27 14:11:29 CST; 4 days ago
> TriggeredBy: ● docker.socket
>        Docs: https://docs.docker.com
>    Main PID: 2874 (dockerd)
>       Tasks: 38
>      Memory: 100.8M
>         CPU: 1min 44.562s
>      CGroup: /system.slice/docker.service
>              └─2874 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
> 
> Feb 27 14:11:28 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:28.890129302+08:00" level=info msg="detected 127.0.0.53 nameserver, assuming systemd-resolved, so using resolv.conf: /run/systemd/resolve/resolv.conf"
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.016470639+08:00" level=info msg="[graphdriver] using prior storage driver: overlay2"
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.024669616+08:00" level=info msg="Loading containers: start."
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.705815252+08:00" level=info msg="Loading containers: done."
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.739112119+08:00" level=info msg="Docker daemon" commit=af898ab containerd-snapshotter=false storage-driver=overlay2 version=28.0.0
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.739318376+08:00" level=info msg="Initializing buildkit"
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.791571564+08:00" level=info msg="Completed buildkit initialization"
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.799787483+08:00" level=info msg="Daemon has completed initialization"
> Feb 27 14:11:29 wilkes-evt dockerd[2874]: time="2025-02-27T14:11:29.799893542+08:00" level=info msg="API listen on /run/docker.sock"
> Feb 27 14:11:29 wilkes-evt systemd[1]: Started Docker Application Container Engine.
> ```
9. 避免在執行 docker 命令時輸入 sudo，將您的使用者名稱新增至 docker 群組。
- 目前登入用戶：
```shell
sudo usermod -aG docker ${USER}
```
- 其他非登入中用戶：
```shell
sudo usermod -aG docker <username>
```
> 如果 `<username>` 是 john.
> 
> $ sudo usermod -aG docker john
>
> 如果 `<username>` 是 iris.
> 
> $ sudo usermod -aG docker iris
10. 若要套用新的群組成員身份，請登出伺服器並重新登入。
### 參考
- [連結](<https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04>)

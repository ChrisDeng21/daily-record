# Run Gitlab In Docker Container

## Language
[English](#english) | [中文](#中文)

## English
### Created Date
2025/03/25
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
Provide an example of running a GitLab service using Docker to understand the operational process.
### Solution
1. Pull the [gitlab/gitlab-ce:17.10.0-ce.0](<https://hub.docker.com/layers/gitlab/gitlab-ce/17.10.0-ce.0/images/sha256-4d1e1224ae38b06fb3066367ba5708e3c2e6249b118b5774dfc2ea78b5f0f138>) image from [Docker Hub](<https://hub.docker.com/>). (The latest version used during testing.)
```shell
docker pull gitlab/gitlab-ce:17.10.0-ce.0
```
2. Create three key folders.
```shell
mkdir -p ${HOME}/Gitlab/data ${HOME}/Gitlab/logs ${HOME}/Gitlab/config
```
> - `${HOME}/Gitlab/data`：Primary storage for GitLab data.
>   - Including the Git repository, user data, configuration files, etc.
>   - Once mounted to the local system, the data will be preserved even if the container is accidentally deleted or recreated, ensuring data persistence.
> - `${HOME}/Gitlab/logs`：Primary directory for storing GitLab log files.
>   - Contains important information such as GitLab's runtime logs, error logs, and more.
>   - After being mounted locally, the logs can be easily viewed and managed later, enabling efficient troubleshooting and monitoring.
> - `${HOME}/Gitlab/config`：Primary directory for storing GitLab configuration.
>   - Contains settings related to system configuration, user access control, and third-party integrations.
>   - Once mounted to the local system, it allows for flexible customization based on specific requirements.
3. Start the GitLab service.
```shell
docker run --detach \
           --restart always \
           --name gitlab \
           --env GITLAB_OMNIBUS_CONFIG="external_url 'http://172.16.203.166:8929'; gitlab_rails['gitlab_shell_ssh_port'] = 2424" \
           --publish 8929:8929 \
           --publish 2424:22 \
           --volume ${HOME}/Gitlab/data:/var/opt/gitlab \
           --volume ${HOME}/Gitlab/logs:/var/log/gitlab \
           --volume ${HOME}/Gitlab/config:/etc/gitlab \
           --log-driver=json-file \
           --log-opt max-size=512m \
           --log-opt max-file=3 \
           --shm-size 256m \
           gitlab/gitlab-ce:17.10.0-ce.0
```
> - `--detach`：Run in the background.
> - `--restart always`：Automatically restart the container when Docker restarts.
> - The IP address of the local (test) machine is 172.16.203.166.
> - The external web port is 8929 (forwarded to port 8929 of the GitLab service).
> - The external SSH port is 2424 (forwarded to port 22 of the GitLab service).
> - Mount the previously mentioned directories into the GitLab Docker container at `/var/opt/gitlab`, `/var/log/gitlab`, and `/etc/gitlab`.
> - Log configuration (such as limiting log disk usage).
> - Configure shared memory settings.
4. Enter the GitLab container to change the exposed ports and update the root account password.
```shell
docker exec -it gitlab /bin/bash
```
- Edit the `/etc/gitlab/gitlab.rb` configuration file to update the external ports, ensuring the correct port is reflected in the copied project URLs.
```shell
vi /etc/gitlab/gitlab.rb
```
- Add the following content (same as the parameters in the `docker run` command), then save and exit.
```shell
external_url 'http://172.16.203.166:8929'
gitlab_rails['gitlab_shell_ssh_port'] = 2424
```
- Reconfigure GitLab.
```shell
gitlab-ctl reconfigure
```
- Change the root login password.
```shell
gitlab-rake "gitlab:password:reset"
```
> This is console output：
> ```console＝
> # gitlab-rake "gitlab:password:reset"
>         Enter username: root
>         Enter password:
>         Confirm password:
>         Password successfully updated for user with username root.
> ```
5. Access the GitLab home page via a web browser (e.g., `http://172.16.203.166:8929/`), then log in using the root username and the configured password
#### Extension
Since the `docker run` command uses `--restart always` to enable automatic container restart, you need to change the restart policy before stopping the GitLab Docker container.
```shell
docker update --restart=no gitlab
docker stop gitlab
```
### Reference
- [使用Docker安裝GitLab](<https://vocus.cc/article/64673005fd89780001dedf45>)
- [Configure GitLab running in a Docker container](<https://docs.gitlab.com/install/docker/configuration/#expose-gitlab-on-different-ports>)

## 中文
### 建立日期
2025/03/25
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
提供一種範例，使用 Docker 執行 Gitlab 服務，用於理解操作流程。
### 解決方案
1. 從 [Docker Hub](<https://hub.docker.com/>) 下載 [gitlab/gitlab-ce:17.10.0-ce.0](<https://hub.docker.com/layers/gitlab/gitlab-ce/17.10.0-ce.0/images/sha256-4d1e1224ae38b06fb3066367ba5708e3c2e6249b118b5774dfc2ea78b5f0f138>)。（測試時的最新版本）
```shell
docker pull gitlab/gitlab-ce:17.10.0-ce.0
```
2. 新增三個重要資料夾。
```shell
mkdir -p ${HOME}/Gitlab/data ${HOME}/Gitlab/logs ${HOME}/Gitlab/config
```
> - `${HOME}/Gitlab/data`：主要儲存 GitLab 的資料。
>   - 包括Git repo、用戶資料、配置文件等。
>   - 掛載到本地後，即使容器發生意外被刪除或重新創建，資料也能夠得到保留，達到數據持久化。
> - `${HOME}/Gitlab/logs`：主要儲存 GitLab 的 Log 。
>   - 包含 GitLab 的運行 Log 、錯誤 Log 等重要資訊。
>   - 掛載到本地後，方便日後查看和管理 Log ，並進行故障排除和監控。
> - `${HOME}/Gitlab/config`：主要儲存 GitLab 的設定檔。
>   - 包含系統設定、用戶權限、外部整合等設定。
>   - 掛載到本地後，可根據需求進行自定義調整。
3. 啟動 Gitlab 服務。
```shell
docker run --detach \
           --restart always \
           --name gitlab \
           --env GITLAB_OMNIBUS_CONFIG="external_url 'http://172.16.203.166:8929'; gitlab_rails['gitlab_shell_ssh_port'] = 2424" \
           --publish 8929:8929 \
           --publish 2424:22 \
           --volume ${HOME}/Gitlab/data:/var/opt/gitlab \
           --volume ${HOME}/Gitlab/logs:/var/log/gitlab \
           --volume ${HOME}/Gitlab/config:/etc/gitlab \
           --log-driver=json-file \
           --log-opt max-size=512m \
           --log-opt max-file=3 \
           --shm-size 256m \
           gitlab/gitlab-ce:17.10.0-ce.0
```
> - `--detach`：於背景執行
> - `--restart always`：docker 重啟時，自動重啟 container
> - 本機（測試機） IP 為 172.16.203.166
> - Web 對外連接埠為 8929 （轉發到 Gitlab 服務的連接埠 8929）
> - SSH 對外連接埠為 2424 （轉發到 Gitlab 服務的連接埠 22）
> - 掛載上述三個重要資料夾於 Gitlab Docker Container 裡的位置 `/var/opt/gitlab` `/var/log/gitlab` `/etc/gitlab`
> - Log 的設定 （像是限制 Log 使用空間大小）
> - 共享內存的設定
4. 進入 Gitlab Docker Container 修改對外連接埠和 root 密碼。
```shell
docker exec -it gitlab /bin/bash
```
- 修改對外連接埠，編輯 `/etc/gitlab/gitlab.rb`（讓複製專案 URL 時能正確帶入連接埠）
```shell
vi /etc/gitlab/gitlab.rb
```
- 新增以下內容（與 `docker run` 裡參數相同）並存檔離開
```shell
external_url 'http://172.16.203.166:8929'
gitlab_rails['gitlab_shell_ssh_port'] = 2424
```
- 重新設定 Gitlab
```shell
gitlab-ctl reconfigure
```
- 修改 root 登入密碼
```shell
gitlab-rake "gitlab:password:reset"
```
> 這是控制台輸出：
> ```console＝
> # gitlab-rake "gitlab:password:reset"
>         Enter username: root
>         Enter password:
>         Confirm password:
>         Password successfully updated for user with username root.
> ```
5. 使用瀏覽器打開 Gitlab 首頁，例如：`http://172.16.203.166:8929/`，並且使用 root 帳號搭配登入密碼即可。
#### 延伸
因為 `docker run` 使用 `--restart always` 讓 container 自動重啟，若是要 Gitlab Docker Container 停止，可以改變策略再關閉。
```shell
docker update --restart=no gitlab
docker stop gitlab
```
### 參考
- [使用Docker安裝GitLab](<https://vocus.cc/article/64673005fd89780001dedf45>)
- [Configure GitLab running in a Docker container](<https://docs.gitlab.com/install/docker/configuration/#expose-gitlab-on-different-ports>)

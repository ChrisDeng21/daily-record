# Git Hooks for Checking Code

## Created Date
2025/03/07

## Environment
ubuntu-22.04.4-desktop-amd64.iso
```console
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

## Symptom
None

## Cause
執行 `git commit` 指令時，利用 Git 的 Hooks 功能，進行程式碼靜態分析。

## Solution
當 `git init` 指令替專案加入 Git 版本控制後，專案目錄底下會多出一個 .git 目錄，這個目錄用來存放 Git 設定與版本控制所需的檔案，它並不能被 `git add` 進 Git 倉庫中。為了程式碼靜態分析之目的，修改專案目錄裡的 `.git/hooks/pre-commit` 來達成。

### 安裝工具
```shell
sudo apt install git vim cppcheck
```

### 範例演練
1. 建立新專案加入版本控制，然後檢查 .git 目錄是否生成。
```shell
mkdir GIT_TEST
```
```shell
cd GIT_TEST
```
```shell
git init
```
```shell
ls -a
```
```console
$ mkdir GIT_TEST
$ cd GIT_TEST
$ git init
hint: Using 'master' as the name for the initial branch. This default branch name
hint: is subject to change. To configure the initial branch name to use in all
hint: of your new repositories, which will suppress this warning, call:
hint:
hint:   git config --global init.defaultBranch <name>
hint:
hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
hint: 'development'. The just-created branch can be renamed via this command:
hint:
hint:   git branch -m <name>
Initialized empty Git repository in /home/chrisdeng/GIT_TEST/.git/
$ ls -a
.  ..  .git
```

2. 新增檔案 `.git/hooks/pre-commit`。範本參考： [git-pre-commit-cppcheck](<https://github.com/danmar/cppcheck/blob/main/tools/git-pre-commit-cppcheck>)。\
**注意!!!** 下面內容與範本差異在 cppcheck 那行有新增 `--enable=all`。
```shell
vim .git/hooks/pre-commit
```
```bash
#!/bin/sh

# Usage: add this file to your project's .git/hooks directory. Rename it to
# just 'pre-commit'.
# Now, when you change some files in repository and try to commit these
# changes, git will run this script right before commit. Cppcheck will scan
# changed/new files in repository. If it finds some issues, script returns with
# exit code 1, rejecting commit. Otherwise, script returns 0, and you can
# actually commit your changes.
#
# Example:
# $ cat hello.c
# int main() {
#    int *s = malloc(10);
# }
# $ git add hello.c
# $ git commit
# Checking hello.c...
# [hello.c:3]: (error) Memory leak: s
# [hello.c:2]: (error) The allocated size 10 is not a multiple of the underlying type's size.
#
# $ vim hello.c
# $ cat hello.c
# int main() {
# }
# $ git add hello.c
# $ git commit
# Checking hello.c...
# $

if git rev-parse --verify HEAD >/dev/null 2>&1
then
	against=HEAD
else
	# Initial commit: diff against an empty tree object
	against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

# We should pass only added or modified C/C++ source files to cppcheck.
changed_files=$(git diff-index --cached $against | \
	grep -E '[MA]	.*\.(c|cpp|cc|cxx)$' | cut -f 2)

if [ -n "$changed_files" ]; then
	cppcheck --enable=all --error-exitcode=1 $changed_files
	exit $?
fi

exit 0
```

3. 改成可執行權限。
```shell
chmod 775 .git/hooks/pre-commit
```

4. 新增錯誤檢查的檔案。
```shell
vim err.c
```
```c
#include <stdio.h>

int main()
{
    int i;

    return 0;
}
```

5. 提交檔案失敗。
```shell
git add err.c
```
```shell
git commit -m "First commit"
```
```console
$ git add err.c
$ git commit -m "First commit"
Checking err.c ...
err.c:5:9: style: Unused variable: i [unusedVariable]
    int i;
        ^
nofile:0:0: information: Cppcheck cannot find all the include files (use --check-config for details) [missingIncludeSystem]
```

6. 按照提示把錯誤修正。
```shell
vim err.c
```
```c
#include <stdio.h>

int main()
{
    return 0;
}
```

7. 再次提交檔案成功。
```shell
git add err.c
```
```shell
git commit -m "First commit"
```
```console
$ git add err.c
$ git commit -m "First commit"
Checking err.c ...
nofile:0:0: information: Cppcheck cannot find all the include files (use --check-config for details) [missingIncludeSystem]

[master (root-commit) ed2dc78] First commit
 1 file changed, 6 insertions(+)
 create mode 100644 err.c
```

8. 確認提交是否成功。
```shell
git log -p
```
```console
$ git log -p
commit ed2dc78e4f0bbe6ee2e93572f5cb82b88f91bd66 (HEAD -> master)
Author: User <User@mail.com>
Date:   Fri Mar 7 16:47:24 2025 +0800

    First commit

diff --git a/err.c b/err.c
new file mode 100644
index 0000000..c5d6809
--- /dev/null
+++ b/err.c
@@ -0,0 +1,6 @@
+#include <stdio.h>
+
+int main()
+{
+    return 0;
+}
```

### Extension
可以在 Git 中設定 `global hooks` 目錄，而不需要在每個專案中單獨配置。利用 Git 指令：
```shell
git config --global core.hooksPath /path/to/global/hooks
```

> 將 /path/to/global/hooks 替換為你希望存放 `global hooks` 的目錄路徑。

Git 會自動在所有專案中使用這個路徑下的 pre-commit。在任何 Git 專案中執行 `git commit`，該 pre-commit 都應該會被執行。

如果個別專案需要自定義，可以在該專案的 `.git/hooks` 目錄中配置自己的 pre-commit，這樣會覆蓋 `global hooks` 的 pre-commit。

## Reference
1. [什麼是 Git Hooks？為什麼它這麼萬能？](<https://yhtechnote.com/git-hooks/>)
2. [如何在執行git commit前自動進行檢查？Git Hooks的基本用法](<https://magiclen.org/git-hooks/>)
3. [git-pre-commit-cppcheck](<https://github.com/danmar/cppcheck/blob/main/tools/git-pre-commit-cppcheck>)

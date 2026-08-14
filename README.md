# DSH Profile Pack

一个 DSH 整合包，一键安装自定义插件，不用一个一个配。

## 包含的插件

| 插件 | 说明 |
|---|---|
| `dsh-command-retry-count` | 调整 LLM 重试次数 |
| `dsh-command-check-update` | 检查更新和版本管理 |

## 用法

### 方式一：安装脚本（新装）

```powershell
# 下载安装脚本
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/xiaoxingdelabi1/dsh-profile-pack/main/install.ps1" -OutFile install.ps1

# 运行
.\install.ps1
```

### 方式二：斜杠命令（已有 check-update 插件）

如果你已经装了 `dsh-command-check-update` 插件，直接在聊天框里输入：

```
/install-pack
```

插件会自动从 GitHub 下载所有插件并更新 cordis.patch.yml。

### 3. 重启 DSH

重启后，在聊天框里就能用这些命令了：

```
/retry-count my-provider 5    # 设置重试次数
/check-update                 # 检查更新
/check-update to 0.1.0-rc.6  # 升级到指定版本
/version                      # 查看当前版本
```

## 没有 API key

所有插件都是公开的 GitHub 仓库，安装过程不需要任何 API key 或 token。

## 更新插件

再次运行 `install.ps1` 即可更新到最新版本。
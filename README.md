# DSH Profile Pack

一个 DSH 整合包，一键安装自定义插件，不用一个一个配。

## 包含的插件

| 插件 | 说明 |
|---|---|
| `dsh-command-retry-count` | 调整 LLM 重试次数 |
| `dsh-command-check-update` | 检查更新和版本管理 |

## 用法

### 1. 添加插件列表

把 `cordis.patch.yml` 的内容追加到你自己的 `~/.dsh/profiles/web/cordis.patch.yml` 里。

### 2. 安装插件

```powershell
# 运行安装脚本，自动下载所有插件
.\install.ps1
```

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
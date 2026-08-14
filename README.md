# DSH Profile Pack

一个 DSH 整合包，一键安装自定义插件，不用一个一个配。

## 包含的插件

| 插件 | 说明 |
|---|---|
| `dsh-command-retry-count` | 调整 LLM 重试次数（/retry-count） |
| `dsh-command-check-update` | 检查更新和版本管理（/check-update、/version） |

## 为什么不用 npm 包名安装？

这两个插件**只发布在 GitHub，没有发布到 npm registry**（`npm view @deepseek-ai/dsh-command-*` 返回 404）。

如果直接在 `cordis.patch.yml` 里写 `name: '@deepseek-ai/dsh-command-xxx'`，dsh web 启动时插件树会因为包名解析失败而**直接崩溃**。

因此本包采用**已验证可用**的方案：

1. 插件文件装入 dsh 自身依赖树（`npm 全局 node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/`），保证插件的裸导入（`@deepseek-ai/dsh-llm`、`@deepseek-ai/dsh-settings`）和 `check-update` 的版本号相对路径能正确解析；
2. `cordis.patch.yml` 用 **`file:///` URL** 引用插件主文件（Loader 对该形式原样传给 Node ESM 加载器，不会触发 npm 解析，也不会触发 `protocol 'c:'` 报错）。

## 用法

### 方式一：安装脚本（推荐）

```powershell
# 下载安装脚本
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/xiaoxingdelabi1/dsh-profile-pack/main/install.ps1" -OutFile install.ps1

# 运行
.\install.ps1
```

脚本会自动：

- 探测你本机的 dsh 安装位置（`npm root -g`）
- 从 GitHub 下载两个插件，装入 dsh 依赖树
- 备份旧的 `cordis.patch.yml`，生成带 `file:///` URL 的新配置文件

### 方式二：已有 check-update 插件

如果你已经装了 `dsh-command-check-update` 插件，直接在聊天框里输入：

```
/install-pack
```

### 3. 重启 DSH

重启后，在聊天框里就能用这些命令了：

```
/retry-count my-provider 5    # 设置重试次数（0-20）
/check-update                 # 检查更新
/check-update to 0.1.0-rc.6   # 升级到指定版本
/version                      # 查看当前版本
```

## 没有 API key

所有插件都是公开的 GitHub 仓库，安装过程不需要任何 API key 或 token。

## 更新插件

再次运行 `install.ps1` 即可从 GitHub 拉取最新版本并重写 `cordis.patch.yml`。

## 注意事项

- 如果你重新安装/升级了 dsh（npm 全局包），dsh 的 `node_modules` 会被重置，需要**重新运行 `install.ps1`** 恢复插件。
- 脚本只针对 **npm 全局安装**的 dsh。如果你用 pnpm/其他方式安装，请手动调整 `Get-DshInstallDir`。
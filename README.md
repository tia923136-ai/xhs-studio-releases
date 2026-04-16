# xhs-studio-releases

小红书 Studio 的安装分发仓库（仅存放 release 构件，源码不公开）。

## 客户入口

**安装页**：https://tia923136-ai.github.io/xhs-studio-releases/

客户访问 → 点「复制」按钮 → 终端粘贴 → 自动完成安装。

## 内部维护

### 发新版
1. 在 `04-📣市场与营销/电商二创/` 跑 `bash pack_deploy.sh` 生成 `dist/xhs-studio-vX.Y.zip`
2. 清理冗余文件（删 `install.command`，更新「使用说明.md」）
3. 在 GitHub 打 tag 并上传 release asset：
   ```bash
   gh release create vX.Y dist/xhs-studio-vX.Y.zip -t "vX.Y" -n "..."
   ```
4. 如改了 bootstrap，push 到 `main`（GitHub Pages 自动更新）

### 升级逻辑

`install.sh` 会：
- 检测 `~/Desktop/xhs-studio/.env` 是否存在 → 存在则备份再恢复（保留激活码+API Key）
- 停掉 LaunchAgent（若已运行）
- 下载最新 release zip 替换
- 调用 `安装.command` 重建依赖
- 重新加载 LaunchAgent → 打开 localhost:8088

客户侧永远只记一条命令。

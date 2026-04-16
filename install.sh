#!/bin/bash
# 小红书 Studio 一键安装引导脚本
# 使用方法：curl -fsSL https://tia923136-ai.github.io/xhs-studio-releases/install.sh | bash

set -e

VERSION="${XHS_VERSION:-v9.2}"
RELEASE_URL="https://github.com/tia923136-ai/xhs-studio-releases/releases/download/${VERSION}/xhs-studio-${VERSION}.zip"
INSTALL_DIR="$HOME/Desktop/xhs-studio"
BACKUP_ENV=""

echo ""
echo "============================================"
echo "  小红书 Studio 安装器  ${VERSION}"
echo "============================================"
echo ""

# ── 0. 检查必备工具 ──
for cmd in curl unzip python3; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ 未找到 $cmd，请先安装 Xcode 命令行工具："
        echo "   xcode-select --install"
        exit 1
    fi
done

# ── 1. 保护已有 .env（升级场景）──
if [ -f "$INSTALL_DIR/.env" ]; then
    echo "[1/5] 检测到已安装版本，备份 .env..."
    BACKUP_ENV=$(mktemp -t xhs-env.XXXXXX)
    cp "$INSTALL_DIR/.env" "$BACKUP_ENV"
    echo "      .env 已备份 ✓"
else
    echo "[1/5] 全新安装 → $INSTALL_DIR"
fi

# ── 2. 停止正在运行的服务（升级场景）──
PLIST="$HOME/Library/LaunchAgents/com.xhs-studio.server.plist"
if [ -f "$PLIST" ]; then
    launchctl unload "$PLIST" 2>/dev/null || true
fi

# ── 3. 下载最新包 ──
echo "[2/5] 下载安装包..."
TMPZIP=$(mktemp -t xhs-studio.XXXXXX.zip)
trap "rm -f '$TMPZIP'" EXIT

if ! curl -fL --progress-bar "$RELEASE_URL" -o "$TMPZIP"; then
    echo "❌ 下载失败，请检查网络（可能需要梯子）"
    exit 1
fi
echo "      下载完成 ✓"

# ── 4. 解压到桌面 ──
echo "[3/5] 解压到桌面..."
TMPDIR=$(mktemp -d -t xhs-unpack.XXXXXX)
trap "rm -f '$TMPZIP'; rm -rf '$TMPDIR'" EXIT

unzip -q "$TMPZIP" -d "$TMPDIR"
INNER=$(find "$TMPDIR" -mindepth 1 -maxdepth 1 -type d | head -1)
if [ -z "$INNER" ]; then
    echo "❌ 包结构异常"
    exit 1
fi

rm -rf "$INSTALL_DIR"
mv "$INNER" "$INSTALL_DIR"
xattr -cr "$INSTALL_DIR" 2>/dev/null || true
echo "      已解压到 $INSTALL_DIR ✓"

# ── 5. 恢复备份的 .env ──
if [ -n "$BACKUP_ENV" ] && [ -f "$BACKUP_ENV" ]; then
    cp "$BACKUP_ENV" "$INSTALL_DIR/.env"
    rm -f "$BACKUP_ENV"
    echo "      .env 已恢复，激活码保留 ✓"
fi

# ── 6. 运行安装脚本 ──
echo "[4/5] 运行安装（预计 3-5 分钟）..."
echo ""
cd "$INSTALL_DIR"
bash 安装.command

# ── 7. 自动打开浏览器 ──
echo "[5/5] 打开浏览器..."
sleep 2
open "http://localhost:8088" 2>/dev/null || true

echo ""
echo "============================================"
echo "  ✅ 全部完成"
echo "============================================"
echo ""
echo "  访问地址：http://localhost:8088"
echo "  密码：vivian88"
echo "  建议收藏此网址到书签栏"
echo ""

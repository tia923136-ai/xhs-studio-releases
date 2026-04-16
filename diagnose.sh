#!/bin/bash
# 小红书 Studio 诊断脚本
# 使用：curl -fsSL https://tia923136-ai.github.io/xhs-studio-releases/diagnose.sh | bash

DIR="$HOME/Desktop/xhs-studio"

echo ""
echo "============================================"
echo "  诊断报告  $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================"
echo ""

echo "── 1. 安装目录 ──"
if [ -d "$DIR" ]; then
    echo "✓ $DIR 存在"
    ls "$DIR" | head -30
else
    echo "❌ $DIR 不存在 —— 安装未完成"
fi
echo ""

echo "── 2. Python 虚拟环境 ──"
if [ -f "$DIR/.venv/bin/python" ]; then
    echo "✓ .venv 存在"
    "$DIR/.venv/bin/python" --version 2>&1
else
    echo "❌ .venv 不存在 —— 依赖安装阶段失败"
fi
echo ""

echo "── 3. 关键模板文件 ──"
for f in templates/activate.html templates/login.html templates/review.html review_server.py; do
    if [ -f "$DIR/$f" ]; then
        echo "✓ $f"
    else
        echo "❌ 缺失 $f"
    fi
done
echo ""

echo "── 4. LaunchAgent 状态 ──"
PLIST="$HOME/Library/LaunchAgents/com.xhs-studio.server.plist"
if [ -f "$PLIST" ]; then
    echo "✓ plist 存在"
else
    echo "❌ plist 不存在 —— 安装最后一步未执行"
fi
echo "launchctl list 输出："
launchctl list 2>&1 | grep -i xhs || echo "(未找到 xhs 相关服务)"
echo ""

echo "── 5. 8088 端口占用 ──"
LSOF_OUT=$(lsof -nP -iTCP:8088 -sTCP:LISTEN 2>&1)
if [ -n "$LSOF_OUT" ]; then
    echo "$LSOF_OUT"
else
    echo "(8088 端口无进程监听 → 服务没跑起来)"
fi
echo ""

echo "── 6. 服务日志（最后 40 行）──"
if [ -f "$DIR/logs/server.log" ]; then
    tail -40 "$DIR/logs/server.log" 2>&1
else
    echo "(日志文件不存在)"
fi
echo ""

echo "── 7. 残留的 review_server 进程 ──"
pgrep -af "review_server" 2>&1 | head -5 || echo "(无)"
echo ""

echo "── 8. 网络连通 ──"
echo -n "  pypi.tuna.tsinghua.edu.cn: "
curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 https://pypi.tuna.tsinghua.edu.cn/simple/
echo -n "  GitHub: "
curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 https://github.com/
echo ""

echo "============================================"
echo "  请把以上全部内容截图发给 Tia"
echo "============================================"

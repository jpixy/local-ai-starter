#!/bin/bash

# Ollama + Qwen 72B + Nginx 完整部署启动脚本
# 一键启动完整的AI服务栈

set -e

echo "🚀 启动 Ollama + Qwen 72B + Nginx 完整服务栈"
echo "========================================"

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker服务"
    echo "   sudo systemctl start docker"
    exit 1
fi

# 检查GPU支持
if command -v nvidia-smi > /dev/null 2>&1; then
    echo "✅ 检测到NVIDIA GPU"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
else
    echo "⚠️  未检测到NVIDIA GPU，将使用CPU模式"
fi

# 获取服务器信息
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "📍 服务器IP: $SERVER_IP"
echo "🌐 访问域名: $SERVER_IP.nip.io"

# 检查系统资源
MEMORY_GB=$(free -g | awk '/^Mem:/ {print $2}')
DISK_GB=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')

echo "💾 系统内存: ${MEMORY_GB}GB"
echo "💿 可用磁盘: ${DISK_GB}GB"

if [ "$MEMORY_GB" -lt 32 ]; then
    echo "⚠️  警告：内存不足32GB，72B模型可能无法正常运行"
fi

if [ "$DISK_GB" -lt 50 ]; then
    echo "⚠️  警告：磁盘空间不足50GB，模型下载可能失败"
fi

# 创建必要目录
echo "📁 创建必要目录..."
mkdir -p logs nginx_logs scripts

# 停止可能冲突的服务
echo "🛑 停止可能冲突的服务..."
if sudo systemctl is-active --quiet ollama; then
    echo "   停止host上的ollama服务..."
    sudo systemctl stop ollama
fi

if sudo systemctl is-active --quiet nginx; then
    echo "   停止host上的nginx服务..."
    sudo systemctl stop nginx
fi

# 停止之前的Docker服务
if docker compose -f docker-compose-complete.yml ps --services --filter status=running | grep -q .; then
    echo "🔄 停止之前的Docker服务..."
    docker compose -f docker-compose-complete.yml down
fi

echo ""
echo "🐳 启动Docker Compose服务..."
echo "   配置文件: docker-compose-complete.yml"
echo "   模型下载: 自动进行 (qwen2.5:32b + qwen2.5:72b)"
echo "   预计时间: 首次启动30-60分钟 (取决于网络速度)"
echo ""

# 启动服务
docker compose -f docker-compose-complete.yml up -d

echo ""
echo "⏳ 等待服务启动..."
sleep 5

# 检查服务状态
echo "📊 服务状态检查..."
docker compose -f docker-compose-complete.yml ps

echo ""
echo "📋 查看实时日志 (Ctrl+C 退出)..."
echo "   如果需要后台运行，请使用: docker compose -f docker-compose-complete.yml logs -f"
echo ""

# 显示访问信息
echo "✅ 服务启动完成！"
echo ""
echo "🔗 访问地址："
echo "   主页面: http://$SERVER_IP.nip.io"
echo "   API文档: http://$SERVER_IP.nip.io/docs"
echo "   健康检查: http://$SERVER_IP.nip.io/health"
echo "   直接IP访问: http://$SERVER_IP"
echo ""
echo "🧪 快速测试："
echo "   curl http://$SERVER_IP.nip.io/api/tags"
echo ""
echo "📝 查看日志："
echo "   docker compose -f docker-compose-complete.yml logs -f ollama"
echo "   docker compose -f docker-compose-complete.yml logs -f nginx"
echo ""
echo "🛑 停止服务："
echo "   docker compose -f docker-compose-complete.yml down"
echo ""

# 显示一段时间的日志
timeout 30 docker compose -f docker-compose-complete.yml logs -f || true

echo ""
echo "🎉 部署完成！服务正在后台运行..."

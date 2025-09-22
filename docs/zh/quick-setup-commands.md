# 快速安装命令参考

从裸机到Ollama + Qwen 32B完整部署的所有命令，适合有经验的用户快速部署。

## 前提条件

- Red Hat Enterprise Linux 9.6
- 管理员权限
- 稳定的网络连接
- 建议64GB+内存，50GB+存储

---

## Host完整部署脚本 (推荐)

### 一键完整安装脚本 (Host模式)

```bash
#!/bin/bash
set -e

echo "🚀 开始 Ollama + Qwen Host 完整部署..."

# 1. 检查系统环境
echo "🔍 检查系统环境..."
cat /etc/os-release | grep "Red Hat Enterprise Linux"
free -h
df -h

# 2. 安装 NVIDIA 驱动
echo "📦 安装 NVIDIA 驱动..."
sudo dnf install -y nvidia-driver-cuda nvidia-driver-cuda-libs cuda-toolkit

# 3. 安装 Docker
echo "🐳 安装 Docker..."
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker

# 4. 安装 NVIDIA Container Toolkit
echo "🎯 安装 NVIDIA Container Toolkit..."
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sed 's#deb#rpm#g' | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
sudo dnf update
sudo dnf install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# 5. 安装 Ollama
echo "🦙 安装 Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# 6. 配置 Ollama 外部访问
echo "🌐 配置 Ollama 外部访问..."
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/environment.conf << EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_PORT=11434"
EOF
sudo systemctl daemon-reload
sudo systemctl restart ollama
sudo systemctl enable ollama

# 7. 下载模型
echo "📥 下载 Qwen 模型..."
ollama pull qwen2.5:32b
ollama pull qwen2.5:72b

# 8. 验证部署
echo "✅ 验证部署..."
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "📍 服务器 IP: $SERVER_IP"
echo "🔗 API 地址: http://$SERVER_IP:11434"

# 测试 API
curl -s http://localhost:11434/api/tags | jq .

echo "🎉 Host 部署完成！"
echo "📋 接下来可以配置 Nginx 反向代理以使用 80 端口访问"
```

### Host模式测试命令

```bash
# 测试模型列表
curl -s http://localhost:11434/api/tags | jq .

# 测试72B模型
curl -s -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "qwen2.5:72b", "prompt": "Hello", "stream": false}' | jq -r '.response'

# 使用IP远程测试
SERVER_IP=$(hostname -I | awk '{print $1}')
curl -s http://$SERVER_IP:11434/api/tags | jq .
```

---

## 一键复制安装脚本 (Docker模式)

### 1. 安装NVIDIA驱动和CUDA

```bash
# 添加NVIDIA仓库并安装驱动
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
sudo dnf install -y nvidia-driver-cuda nvidia-driver-cuda-libs
sudo dnf install -y cuda-toolkit

# 验证安装
nvidia-smi
```

### 2. 安装Docker

```bash
# 添加Docker仓库并安装
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# 验证安装
sudo docker --version
sudo docker compose version
```

### 3. 安装NVIDIA Container Toolkit

```bash
# 准备环境
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

# 安装并配置
sudo dnf install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### 4. 部署Ollama + Qwen 32B

```bash
# 回到项目目录
cd /localhome/admink8s/Development/local-ai-starter

# 创建日志目录
mkdir -p logs

# 启动服务（首次需要下载18GB模型）
sudo docker-compose up -d

# 查看启动日志
sudo docker-compose logs -f
```

---

## 验证命令

```bash
# 健康检查
curl http://localhost:8000/health

# 文本生成测试
curl -X POST http://localhost:8000/generate \
     -H "Content-Type: application/json" \
     -d '{"prompt": "你好"}'

# 运行完整测试
./test-api.sh
```

---

## 常用管理命令

```bash
# 服务管理
sudo docker-compose ps          # 查看状态
sudo docker-compose down        # 停止服务  
sudo docker-compose restart     # 重启服务
sudo docker-compose logs -f     # 查看日志

# 系统监控
nvidia-smi                       # GPU状态
sudo docker stats               # 容器资源
free -h                         # 内存使用
df -h                           # 磁盘空间
```

---

## 外部访问配置

```bash
# 获取服务器IP
hostname -I | awk '{print $1}'

# 配置防火墙（如果需要）
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --permanent --add-port=11434/tcp
sudo firewall-cmd --reload
```

---

## 故障排除快速命令

```bash
# 检查端口占用
sudo netstat -tulnp | grep :8000
sudo netstat -tulnp | grep :11434

# 重新下载模型
sudo docker exec -it local-ai-starter_ollama_1 ollama pull qwen2.5:32b

# 清理并重新部署
sudo docker-compose down -v
sudo docker-compose up -d --build
```

---

## 估算时间

- **NVIDIA驱动安装**: 10-15分钟
- **Docker安装**: 5-10分钟  
- **Container Toolkit**: 3-5分钟
- **首次模型下载**: 30-60分钟
- **总时间**: 50-90分钟

---

## 访问地址

替换`YOUR_SERVER_IP`为实际服务器IP：

- **API服务**: http://YOUR_SERVER_IP:8000
- **API文档**: http://YOUR_SERVER_IP:8000/docs
- **Ollama直接访问**: http://YOUR_SERVER_IP:11434

部署完成后即可通过RESTful API使用Qwen 32B模型进行AI推理任务。

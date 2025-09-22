# 裸机完整部署指南

从零开始在Red Hat Enterprise Linux 9.6上完整部署Ollama + Qwen 32B的详细指南。

## 环境概览

本指南基于以下硬件环境：

### 硬件配置
- **系统**: Red Hat Enterprise Linux 9.6 (Plow)
- **CPU**: x86_64架构
- **内存**: 251GB
- **存储**: 1.8TB可用空间
- **GPU**: NVIDIA H100 SXM5 80GB
- **网络**: 稳定的互联网连接

### 目标配置
- **模型**: Qwen 2.5 32B
- **容器化**: Docker + Docker Compose
- **GPU加速**: NVIDIA Container Toolkit
- **外部访问**: 开放RESTful API端口

---

## 第一步：系统环境检查

### 1.1 检查系统信息

```bash
# 检查系统版本
uname -a
cat /etc/os-release

# 检查硬件资源
free -h
df -h
lspci | grep -i nvidia
```

**预期输出示例：**
```
Linux ipp2-0051.ipp2a1.colossus.nvidia.com 5.14.0-570.12.1.el9_6.x86_64
NAME="Red Hat Enterprise Linux"
VERSION="9.6 (Plow)"

               total        used        free      shared  buff/cache   available
Mem:           251Gi       4.7Gi       243Gi        44Mi       5.4Gi       246Gi

45:00.0 3D controller: NVIDIA Corporation GH100 [H100 SXM5 80GB] (rev a1)
```

### 1.2 确认系统要求
- ✅ 内存 > 64GB（推荐用于32B模型）
- ✅ 存储 > 50GB（模型文件约18GB）
- ✅ NVIDIA GPU（可选但强烈推荐）

---

## 第二步：安装NVIDIA驱动和CUDA

### 2.1 添加NVIDIA仓库

```bash
# 添加NVIDIA CUDA仓库
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
```

### 2.2 安装NVIDIA驱动

```bash
# 安装NVIDIA驱动
sudo dnf install -y nvidia-driver-cuda nvidia-driver-cuda-libs

# 安装CUDA工具包（包含nvidia-smi）
sudo dnf install -y cuda-toolkit
```

**重要说明：**
- 安装过程会下载约3.8GB的文件
- 首次安装可能需要10-20分钟
- 安装完成后无需重启

### 2.3 验证NVIDIA驱动

```bash
# 检查nvidia-smi
nvidia-smi
```

**预期输出：**
```
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.82.07              Driver Version: 580.82.07      CUDA Version: 13.0     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA H100 80GB HBM3          Off |   00000000:45:00.0 Off |                    0 |
| N/A   29C    P0             65W /  700W |       4MiB /  81559MiB |      0%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
```

---

## 第三步：安装Docker

### 3.1 添加Docker仓库

```bash
# 添加Docker官方仓库
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
```

### 3.2 安装Docker CE

```bash
# 安装Docker CE和相关组件
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 3.3 启动Docker服务

```bash
# 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到docker组
sudo usermod -aG docker $USER
```

### 3.4 验证Docker安装

```bash
# 检查Docker版本
sudo docker --version
sudo docker compose version
```

**预期输出：**
```
Docker version 28.4.0, build d8eb465
Docker Compose version v2.39.4
```

---

## 第四步：安装NVIDIA Container Toolkit

### 4.1 添加NVIDIA Container Toolkit仓库

```bash
# 创建keyrings目录
sudo mkdir -p /usr/share/keyrings

# 添加GPG密钥
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

# 添加仓库
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
```

### 4.2 安装NVIDIA Container Toolkit

```bash
# 安装NVIDIA Container Toolkit
sudo dnf install -y nvidia-container-toolkit
```

### 4.3 配置Docker使用NVIDIA runtime

```bash
# 配置Docker
sudo nvidia-ctk runtime configure --runtime=docker

# 重启Docker服务
sudo systemctl restart docker
```

---

## 第五步：测试GPU + Docker环境

### 5.1 测试官方Ollama镜像

```bash
# 测试Ollama镜像GPU支持
sudo docker run --rm --gpus all -v ollama_test:/root/.ollama -p 11434:11434 ollama/ollama:latest
```

**成功标志：**
- 镜像成功下载
- 出现"Looking for compatible GPUs"日志
- 服务监听在0.0.0.0:11434

**预期日志输出：**
```
time=2025-09-22T09:19:09.551Z level=INFO source=routes.go:1519 msg="Listening on [::]:11434 (version 0.12.0)"
time=2025-09-22T09:19:09.551Z level=INFO source=gpu.go:217 msg="looking for compatible GPUs"
```

---

## 第六步：部署Ollama + Qwen 32B

### 6.1 准备项目文件

确保项目目录包含以下文件：
```
local-ai-starter/
├── docker-compose.yml      # 主要部署配置
├── start.sh               # 一键启动脚本
├── test-api.sh           # API测试脚本
├── api_server.py         # RESTful API服务器
├── ollama_client.py      # Ollama客户端
└── requirements.txt      # Python依赖
```

### 6.2 启动服务

**方法1: 使用Docker Compose（推荐）**
```bash
# 回到项目目录
cd /localhome/admink8s/Development/local-ai-starter

# 创建日志目录
mkdir -p logs

# 启动服务
sudo docker-compose up -d

# 查看启动日志
sudo docker-compose logs -f
```

**方法2: 使用启动脚本**
```bash
# 给脚本执行权限
chmod +x start.sh

# 运行一键启动
./start.sh
```

### 6.3 监控部署进度

**首次部署时间估算：**
- 下载Qwen 32B模型：30-60分钟（约18GB）
- 构建API服务：2-5分钟
- 总启动时间：35-65分钟

**监控命令：**
```bash
# 查看容器状态
sudo docker-compose ps

# 查看实时日志
sudo docker-compose logs -f ollama

# 查看API服务日志
sudo docker-compose logs -f api-server
```

---

## 第七步：验证部署

### 7.1 健康检查

```bash
# 检查服务状态
curl http://localhost:8000/health

# 检查模型列表
curl http://localhost:11434/api/tags
```

### 7.2 API测试

```bash
# 运行测试脚本
./test-api.sh

# 手动测试文本生成
curl -X POST http://localhost:8000/generate \
     -H "Content-Type: application/json" \
     -d '{"prompt": "你好，请介绍一下你自己"}'

# 测试对话功能
curl -X POST http://localhost:8000/chat \
     -H "Content-Type: application/json" \
     -d '{
       "messages": [
         {"role": "user", "content": "什么是人工智能？"}
       ]
     }'
```

### 7.3 外部访问验证

获取服务器IP地址：
```bash
hostname -I | awk '{print $1}'
```

从其他机器测试：
```bash
# 替换YOUR_SERVER_IP为实际IP
curl http://YOUR_SERVER_IP:8000/health
curl http://YOUR_SERVER_IP:8000/docs
```

---

## 服务访问信息

### API端点
- **本地访问**: http://localhost:8000
- **外部访问**: http://YOUR_SERVER_IP:8000
- **API文档**: http://YOUR_SERVER_IP:8000/docs

### Ollama直接访问
- **本地访问**: http://localhost:11434
- **外部访问**: http://YOUR_SERVER_IP:11434

### 常用管理命令

```bash
# 查看服务状态
sudo docker-compose ps

# 停止服务
sudo docker-compose down

# 重启服务
sudo docker-compose restart

# 查看GPU使用情况
nvidia-smi

# 查看容器资源使用
sudo docker stats
```

---

## 故障排除

### 常见问题

**1. GPU未识别**
```bash
# 检查驱动
nvidia-smi

# 检查Docker GPU支持
sudo docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

**2. 端口被占用**
```bash
# 检查端口占用
sudo netstat -tulnp | grep :8000
sudo netstat -tulnp | grep :11434

# 停止占用端口的服务
sudo kill $(sudo lsof -t -i:8000)
```

**3. 内存不足**
```bash
# 检查内存使用
free -h
sudo docker stats

# 调整Docker内存限制（在docker-compose.yml中）
```

**4. 模型下载失败**
```bash
# 手动下载模型
sudo docker exec -it local-ai-starter_ollama_1 ollama pull qwen2.5:32b

# 检查网络连接
curl -I https://ollama.ai
```

### 性能优化建议

1. **GPU优化**
   - 确保使用最新的NVIDIA驱动
   - 监控GPU内存使用情况
   - 根据需要调整模型并发数

2. **内存优化**
   - 为32B模型至少分配64GB内存
   - 监控交换分区使用情况
   - 考虑使用内存映射

3. **网络优化**
   - 使用高速网络下载模型
   - 配置适当的超时设置
   - 考虑本地模型缓存

---

## 安全注意事项

1. **防火墙配置**
```bash
# Ubuntu/Debian
sudo ufw allow 8000
sudo ufw allow 11434

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --permanent --add-port=11434/tcp
sudo firewall-cmd --reload
```

2. **访问控制**
- 生产环境建议配置认证
- 限制API访问来源
- 定期更新容器镜像

3. **资源监控**
- 监控GPU和内存使用
- 设置资源使用告警
- 定期检查日志

---

## 总结

通过以上步骤，您已经成功在裸机上部署了：

✅ **NVIDIA H100 GPU环境** - 580.82.07驱动，CUDA 13.0  
✅ **Docker容器化环境** - 28.4.0版本，支持GPU加速  
✅ **Ollama + Qwen 32B** - 官方镜像，自动GPU检测  
✅ **RESTful API服务** - 外部可访问，完整文档  
✅ **监控和测试工具** - 健康检查，性能监控  

整个部署过程大约需要1-2小时，其中大部分时间用于下载模型文件。服务启动后，您将拥有一个强大的本地AI推理环境，支持高性能的自然语言处理任务。

如有问题，请参考故障排除部分或查看项目日志获取详细错误信息。

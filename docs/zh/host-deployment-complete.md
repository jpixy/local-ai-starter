# Ollama + Qwen 大模型 Host 部署完整指南

本文档记录了从裸机环境开始，完整部署 Ollama + Qwen 大模型的详细过程，直到服务在 11434 端口成功运行。

## 目录
1. [环境准备](#环境准备)
2. [系统信息检查](#系统信息检查)
3. [NVIDIA 驱动安装](#nvidia-驱动安装)
4. [Docker 安装](#docker-安装)
5. [NVIDIA Container Toolkit 安装](#nvidia-container-toolkit-安装)
6. [Ollama 安装](#ollama-安装)
7. [模型下载与测试](#模型下载与测试)
8. [外部访问配置](#外部访问配置)
9. [API 测试验证](#api-测试验证)

---

## 环境准备

### 系统要求
- **操作系统**: Red Hat Enterprise Linux 9.6
- **内存**: 建议 64GB+ (支持 72B 模型)
- **存储**: 100GB+ 可用空间
- **GPU**: NVIDIA GPU (推荐)

---

## 系统信息检查

首先检查系统基本信息：

```bash
# 检查操作系统版本
cat /etc/os-release

# 检查内存
free -h

# 检查磁盘空间
df -h

# 检查 CPU 信息
lscpu | grep -E "Model name|CPU\(s\)|Thread"
```

**预期输出示例**:
```
NAME="Red Hat Enterprise Linux"
VERSION="9.6 (Plow)"

              total        used        free      shared  buff/cache   available
Mem:          251Gi       2.1Gi       247Gi       434Mi       1.8Gi       248Gi

Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       500G   50G  425G  11% /

Model name:     Intel(R) Xeon(R) CPU
CPU(s):         48
Thread(s) per core: 2
```

---

## NVIDIA 驱动安装

### 1. 检查是否已安装 NVIDIA 驱动

```bash
# 检查 nvidia-smi 命令
nvidia-smi

# 如果提示 "command not found"，则需要安装驱动
```

### 2. 搜索可用的 NVIDIA 驱动包

```bash
# 搜索 NVIDIA 驱动相关包
sudo dnf search nvidia-driver cuda
```

### 3. 安装 NVIDIA 驱动

```bash
# 安装 NVIDIA 驱动 (RHEL 9.6 特定包名)
sudo dnf install -y nvidia-driver-cuda nvidia-driver-cuda-libs

# 安装 CUDA 工具包 (包含 nvidia-smi)
sudo dnf install -y cuda-toolkit
```

### 4. 验证安装

```bash
# 重新加载模块或重启系统
sudo modprobe nvidia

# 验证 nvidia-smi
nvidia-smi
```

**成功输出示例**:
```
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 525.xx.xx              Driver Version: 525.xx.xx     CUDA Version: 12.1  |
|---------|------------------------|----------------------|----------------------|
| GPU  Name                 TCC/WDDM | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|   0  NVIDIA A100-SXM4...      On   | 00000000:07:00.0 Off |                    0 |
```

---

## Docker 安装

### 1. 添加 Docker 官方仓库

```bash
# 添加 Docker CE 仓库
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
```

### 2. 安装 Docker

```bash
# 安装 Docker CE 及相关组件
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 3. 启动并启用 Docker 服务

```bash
# 启动 Docker 服务
sudo systemctl start docker

# 设置开机自启
sudo systemctl enable docker

# 验证 Docker 状态
sudo systemctl status docker
```

### 4. 验证 Docker 安装

```bash
# 检查 Docker 版本
sudo docker --version

# 运行测试容器
sudo docker run hello-world
```

**成功输出**:
```
Docker version 28.4.0, build 124ca02

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

---

## NVIDIA Container Toolkit 安装

### 1. 创建必要目录

```bash
# 创建 keyrings 目录
sudo mkdir -p /usr/share/keyrings
```

### 2. 添加 NVIDIA Container Toolkit 仓库

```bash
# 下载并添加 GPG 密钥
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

# 添加仓库
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
    sed 's#deb#rpm#g' | \
    sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
```

### 3. 安装 NVIDIA Container Toolkit

```bash
# 更新包索引
sudo dnf update

# 安装 NVIDIA Container Toolkit
sudo dnf install -y nvidia-container-toolkit
```

### 4. 配置 Docker 运行时

```bash
# 配置 Docker 使用 NVIDIA 运行时
sudo nvidia-ctk runtime configure --runtime=docker

# 重启 Docker 服务
sudo systemctl restart docker
```

### 5. 验证 GPU 容器支持

```bash
# 测试 GPU 容器
sudo docker run --rm --gpus all nvidia/cuda:12.1-base-ubuntu22.04 nvidia-smi
```

**成功输出**: 应显示与 host 相同的 `nvidia-smi` 输出。

---

## Ollama 安装

### 1. 下载并安装 Ollama

```bash
# 下载 Ollama 安装脚本
curl -fsSL https://ollama.com/install.sh | sh
```

### 2. 验证 Ollama 安装

```bash
# 检查 Ollama 版本
ollama --version

# 检查 Ollama 服务状态
sudo systemctl status ollama
```

### 3. 配置 Ollama 服务

```bash
# 创建 Ollama 服务配置目录
sudo mkdir -p /etc/systemd/system/ollama.service.d

# 创建环境配置文件
sudo tee /etc/systemd/system/ollama.service.d/environment.conf << EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_PORT=11434"
EOF

# 重新加载 systemd 配置
sudo systemctl daemon-reload

# 重启 Ollama 服务
sudo systemctl restart ollama

# 启用开机自启
sudo systemctl enable ollama
```

---

## 模型下载与测试

### 1. 下载 Qwen 2.5 32B 模型

```bash
# 下载 32B 模型 (约 20GB)
ollama pull qwen2.5:32b
```

**下载过程示例**:
```
pulling manifest 
pulling 9f13ba1299af... 100% ▕████████████████▏  19 GB                         
pulling 8ab4849b038c... 100% ▕████████████████▏  1.7 KB                        
pulling 6b9739b4dbf1... 100% ▕████████████████▏   65 B                         
pulling c156bbdfc557... 100% ▕████████████████▏  182 B                         
verifying sha256 digest 
writing manifest 
success
```

### 2. 下载 Qwen 2.5 72B 模型 (可选)

```bash
# 下载 72B 模型 (约 44GB) - 需要更多内存
ollama pull qwen2.5:72b
```

### 3. 验证模型安装

```bash
# 列出已安装的模型
ollama list
```

**预期输出**:
```
NAME                ID              SIZE    MODIFIED       
qwen2.5:32b         9f13ba1299af    19 GB   2 hours ago    
qwen2.5:72b         424bad2cc13f    44 GB   1 hour ago     
```

### 4. 测试模型推理

```bash
# 测试 32B 模型
ollama run qwen2.5:32b "Hello, how are you?"

# 测试 72B 模型
ollama run qwen2.5:72b "你好，请介绍一下你自己"
```

---

## 外部访问配置

### 1. 检查服务监听状态

```bash
# 检查 Ollama 服务监听端口
sudo netstat -tlnp | grep 11434

# 或使用 ss 命令
sudo ss -tlnp | grep 11434
```

**预期输出**:
```
tcp6       0      0 :::11434                :::*                    LISTEN      1234/ollama
```

### 2. 获取服务器 IP

```bash
# 获取服务器 IP 地址
hostname -I | awk '{print $1}'
```

### 3. 防火墙配置 (如果启用)

```bash
# 检查防火墙状态
sudo systemctl status firewalld

# 如果防火墙启用，开放端口
sudo firewall-cmd --permanent --add-port=11434/tcp
sudo firewall-cmd --reload
```

---

## API 测试验证

### 1. 本地测试

```bash
# 测试健康检查
curl -s http://localhost:11434/api/tags | jq .

# 测试文本生成
curl -s -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:32b",
    "prompt": "Hello",
    "stream": false
  }' | jq -r '.response'
```

### 2. 远程 IP 测试

```bash
# 使用服务器 IP 测试 (替换为实际 IP)
SERVER_IP=$(hostname -I | awk '{print $1}')

# 测试模型列表
curl -s http://$SERVER_IP:11434/api/tags | jq .

# 测试 72B 模型推理
curl -s -X POST http://$SERVER_IP:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:72b",
    "prompt": "简单介绍一下人工智能的发展历程",
    "stream": false
  }' | jq -r '.response'
```

### 3. 性能监控

```bash
# 监控 GPU 使用情况
watch -n 1 nvidia-smi

# 监控系统资源
htop

# 查看 Ollama 日志
sudo journalctl -u ollama -f
```

---

## 部署结果总结

### 成功指标
- ✅ NVIDIA 驱动正常工作 (`nvidia-smi` 有输出)
- ✅ Docker 运行正常 (GPU 容器测试通过)
- ✅ Ollama 服务运行在 `0.0.0.0:11434`
- ✅ 模型下载完成 (`qwen2.5:32b`, `qwen2.5:72b`)
- ✅ API 响应正常 (本地和远程 IP 访问)
- ✅ GPU 推理加速工作

### 关键配置
- **Ollama Host**: `0.0.0.0:11434` (允许外部访问)
- **模型存储**: `/usr/share/ollama/.ollama/models/`
- **服务配置**: `/etc/systemd/system/ollama.service.d/`

### 访问方式
- **直接 IP 访问**: `http://SERVER_IP:11434/api/`
- **API 端点**:
  - 模型列表: `GET /api/tags`
  - 文本生成: `POST /api/generate`
  - 聊天对话: `POST /api/chat`

### 下一步
现在 Ollama 服务已在 host 上成功运行，可以继续配置：
1. **Nginx 反向代理** (端口 80/443)
2. **Docker 容器化部署**
3. **负载均衡和高可用**

---

## 故障排查

### 常见问题

1. **nvidia-smi 命令未找到**
   ```bash
   sudo dnf install cuda-toolkit
   ```

2. **Docker 安装失败**
   ```bash
   sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
   ```

3. **端口被占用**
   ```bash
   sudo lsof -i :11434
   sudo systemctl stop ollama
   ```

4. **模型下载慢**
   - 检查网络连接
   - 考虑使用代理或镜像源

5. **内存不足**
   - 72B 模型需要 32GB+ 内存
   - 32B 模型需要 16GB+ 内存
   - 检查: `free -h`

### 日志查看
```bash
# Ollama 服务日志
sudo journalctl -u ollama -f

# Docker 日志
sudo journalctl -u docker -f

# 系统日志
sudo dmesg | tail -50
```

---

**部署完成时间**: 约 30-60 分钟 (取决于网络和硬件)
**文档版本**: v1.0
**最后更新**: 2025-09-22

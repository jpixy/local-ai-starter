# 详细安装指南

## 系统要求

### 硬件要求

- **CPU**: 现代多核处理器，推荐 8 核以上
- **内存**: 
  - 最低: 8GB RAM
  - 推荐: 16GB+ RAM 
  - 最佳: 32GB+ RAM
- **存储**: 
  - 最低: 10GB 可用空间
  - 推荐: SSD 硬盘 20GB+ 可用空间
- **GPU**: 可选，支持 CUDA 的 NVIDIA GPU 可加速推理

### 软件要求

- **操作系统**: 
  - Linux (推荐 Ubuntu 20.04+, CentOS 8+)
  - macOS 10.15+
  - Windows 10/11
- **Python**: 3.8.0 或更高版本
- **Git**: 用于克隆项目
- **curl**: 用于下载 Ollama

## 安装步骤

### 1. 准备系统环境

#### Linux (Ubuntu/Debian)

```bash
# 更新系统包
sudo apt update && sudo apt upgrade -y

# 安装必要工具
sudo apt install -y curl git python3 python3-pip python3-venv

# 检查 Python 版本
python3 --version
```

#### Linux (CentOS/RHEL)

```bash
# 更新系统包
sudo yum update -y

# 安装必要工具
sudo yum install -y curl git python3 python3-pip

# 检查 Python 版本
python3 --version
```

#### macOS

```bash
# 安装 Homebrew (如果未安装)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装必要工具
brew install curl git python3

# 检查 Python 版本
python3 --version
```

#### Windows

1. 下载并安装 [Python 3.8+](https://www.python.org/downloads/)
2. 安装 [Git for Windows](https://gitforwindows.org/)
3. 确保 Python 和 Git 已添加到 PATH 环境变量

### 2. 下载项目

```bash
# 克隆项目到本地
git clone <your-repo-url>
cd local-ai-starter

# 或者下载 ZIP 文件解压
```

### 3. 自动安装 Ollama 和模型

```bash
# 给安装脚本执行权限
chmod +x setup_ollama.sh

# 运行自动安装脚本
./setup_ollama.sh
```

**注意**: 首次运行会下载大约 4GB 的模型文件，请确保网络连接稳定。

### 4. 手动安装（可选）

如果自动安装失败，可以手动执行以下步骤：

#### 4.1 安装 Ollama

**Linux/macOS:**
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**Windows:**
下载并运行 [Ollama Windows 安装程序](https://ollama.ai/download)

#### 4.2 启动 Ollama 服务

```bash
# 启动服务（后台运行）
ollama serve &

# 或者前台运行（用于调试）
ollama serve
```

#### 4.3 下载 Qwen 7B 模型

```bash
# 下载模型（大约 4GB，需要时间）
ollama pull qwen:7b

# 验证模型是否下载成功
ollama list
```

### 5. 设置 Python 环境

```bash
# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate  # Linux/macOS
# 或者
venv\Scripts\activate     # Windows PowerShell
# 或者
venv\Scripts\activate.bat # Windows CMD

# 升级 pip
python -m pip install --upgrade pip

# 安装项目依赖
pip install -r requirements.txt
```

### 6. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑配置文件
nano .env  # Linux
# 或
notepad .env  # Windows
```

根据你的环境修改配置：

```bash
# Ollama 服务器配置
OLLAMA_HOST=localhost
OLLAMA_PORT=11434
OLLAMA_MODEL=qwen:7b
OLLAMA_TIMEOUT=60

# 可选：模型参数
OLLAMA_TEMPERATURE=0.7
OLLAMA_TOP_P=0.9
OLLAMA_MAX_TOKENS=2048
```

### 7. 验证安装

```bash
# 运行测试脚本
python test_client.py
```

如果看到所有测试都通过，说明安装成功！

## 常见安装问题

### 问题 1: Ollama 安装失败

**解决方案:**
```bash
# 检查网络连接
ping ollama.ai

# 手动下载安装脚本
curl -fsSL https://ollama.ai/install.sh -o install_ollama.sh
chmod +x install_ollama.sh
./install_ollama.sh
```

### 问题 2: 模型下载失败

**解决方案:**
```bash
# 检查磁盘空间
df -h

# 清理可能的缓存
ollama rm qwen:7b
ollama pull qwen:7b

# 如果网络不稳定，可以多次尝试
for i in {1..5}; do ollama pull qwen:7b && break || sleep 10; done
```

### 问题 3: Python 依赖安装失败

**解决方案:**
```bash
# 更新 pip
python -m pip install --upgrade pip

# 清理缓存
pip cache purge

# 逐个安装依赖
pip install ollama
pip install requests
pip install aiohttp
pip install python-dotenv
```

### 问题 4: 服务启动失败

**解决方案:**
```bash
# 检查端口是否被占用
netstat -tlnp | grep 11434
# 或
lsof -i :11434

# 杀死占用端口的进程
sudo kill -9 <PID>

# 重新启动服务
ollama serve
```

### 问题 5: 权限问题

**Linux/macOS 解决方案:**
```bash
# 给当前用户添加执行权限
chmod +x setup_ollama.sh
chmod +x test_client.py

# 如果需要管理员权限
sudo ./setup_ollama.sh
```

**Windows 解决方案:**
以管理员身份运行 PowerShell 或 CMD

## 性能调优

### 内存优化

```bash
# 检查内存使用
free -h  # Linux
# 或
vm_stat  # macOS

# 如果内存不足，可以创建交换文件
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### GPU 加速（可选）

如果有支持 CUDA 的 NVIDIA GPU：

```bash
# 安装 NVIDIA 驱动和 CUDA
# Ubuntu
sudo apt install nvidia-driver-470 nvidia-cuda-toolkit

# 验证 GPU 可用
nvidia-smi

# Ollama 会自动检测并使用 GPU
```

## 卸载

如果需要完全卸载：

```bash
# 停止 Ollama 服务
pkill ollama

# 删除 Ollama 二进制文件
sudo rm -f /usr/local/bin/ollama

# 删除模型和数据
rm -rf ~/.ollama

# 删除项目文件
rm -rf local-ai-starter

# 删除 Python 虚拟环境
rm -rf venv
```

## 下一步

安装完成后，请查看 [使用指南](README.md) 了解如何使用系统。

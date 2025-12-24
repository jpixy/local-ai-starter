# 安装指南

## 系统要求

### 硬件要求

- **内存**: 8GB+ RAM（推荐 16GB+）
- **存储**: 10GB+ 可用空间（推荐 SSD）
- **GPU**: 可选，NVIDIA GPU 可加速推理

### 软件要求

- Linux 操作系统
- curl
- 稳定的网络连接

## 安装步骤

### 1. 获取项目

```bash
git clone <your-repo-url>
cd local-ai-starter
```

### 2. 安装 Ollama 和模型

```bash
make install
# 或
./setup_ollama.sh
```

脚本会自动：
1. 安装 Ollama
2. 启动 Ollama 服务
3. 下载 Qwen 2.5 7B 模型（约 4.7GB）

### 3. 验证安装

```bash
# 检查状态
make status

# 测试 API
make test
```

## 手动安装

如果自动安装失败：

### 安装 Ollama

```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

### 启动服务

```bash
ollama serve &
```

### 下载模型

```bash
ollama pull qwen2.5:7b
```

### 验证

```bash
ollama list
curl http://localhost:11434/api/tags
```

## 常见问题

### 服务无法启动

```bash
# 检查端口是否被占用
netstat -tlnp | grep 11434

# 杀死占用进程
sudo kill -9 <PID>

# 重新启动
ollama serve
```

### 模型下载失败

```bash
# 清理后重试
ollama rm qwen2.5:7b
ollama pull qwen2.5:7b
```

### 内存不足

- 确保至少 8GB 可用内存
- 关闭其他占用内存的应用

## 卸载

```bash
# 停止服务
make stop

# 清理数据
make clean

# 删除 Ollama
sudo rm -f /usr/local/bin/ollama
```

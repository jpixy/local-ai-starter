# Local AI Starter with Ollama and Qwen Models

一个完整的本地 AI 解决方案，使用 Ollama 和 Qwen 系列模型（7B/32B/72B），支持 Docker Compose 一键部署和 Python 客户端集成。

## ⚡ 快速参考

```bash
# 🚀 启动服务（Docker Compose）
docker compose -f docker-compose-complete.yml up -d

# 📊 查看状态
docker compose -f docker-compose-complete.yml ps

# 🔍 查看已安装模型
docker exec ollama-service ollama list

# 🧪 快速测试
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{"model": "qwen2.5:7b", "prompt": "你好", "stream": false}'

# 🐍 Python 测试
poetry run python test_client.py

# 📝 查看日志
docker compose -f docker-compose-complete.yml logs -f ollama

# 🛑 停止服务
docker compose -f docker-compose-complete.yml down
```

**当前服务器访问地址：**
- 本地：`http://localhost:11434`
- 外部：`http://10.176.202.207:11434`（根据实际 IP）

## ✨ 特性

- **🐳 Docker 部署**: 使用 Docker Compose 一键部署完整服务栈（Ollama + Nginx）
- **🚀 多模型支持**: 支持 Qwen 2.5 7B/32B/72B 模型，可根据需求选择
- **🔌 Python 集成**: 提供同步和异步 Python 客户端库
- **🌐 外部访问**: 配置 Nginx 反向代理，支持域名和外部访问
- **⚡ GPU 加速**: 自动检测并使用 NVIDIA GPU 加速推理
- **📊 健康检查**: 完整的服务健康检查和监控
- **🧪 完整测试**: 提供全面的测试套件和示例

## 📋 系统要求

### 硬件要求（根据模型选择）

| 模型 | 最小内存 | 推荐内存 | 磁盘空间 | GPU 显存 |
|------|---------|---------|---------|---------|
| Qwen 2.5 7B | 8GB | 16GB | 5GB | 6GB+ |
| Qwen 2.5 32B | 16GB | 32GB | 20GB | 24GB+ |
| Qwen 2.5 72B | 32GB | 64GB | 50GB | 48GB+ |

### 软件要求

- Linux 系统（推荐 Ubuntu 20.04+）
- Docker 和 Docker Compose
- Python 3.9+（用于客户端）
- NVIDIA GPU + nvidia-docker（可选，用于 GPU 加速）
- 稳定的网络连接（首次下载模型）

## 🚀 快速开始

### 方式一：Docker Compose 部署（推荐）

这是最简单、最稳定的部署方式，适合生产环境使用。

#### 1. 检查 Docker 环境

```bash
# 确保 Docker 和 Docker Compose 已安装
docker --version
docker compose version

# 如果有 NVIDIA GPU，检查 nvidia-docker
nvidia-smi
```

#### 2. 启动服务

```bash
# 一键启动完整服务栈（Ollama + Nginx）
./start-complete.sh

# 或者手动启动
docker compose -f docker-compose-complete.yml up -d
```

**首次启动说明：**
- 会自动下载 Ollama 镜像
- 会自动拉取 Qwen 2.5 7B 模型（约 4.7GB）
- 如果配置了 32B/72B 模型，会自动下载（需要较长时间）
- 预计首次启动时间：10-30 分钟（取决于网络速度）

#### 3. 检查服务状态

```bash
# 查看容器状态
docker compose -f docker-compose-complete.yml ps

# 查看日志
docker compose -f docker-compose-complete.yml logs -f ollama

# 检查已安装的模型
docker exec ollama-service ollama list
```

#### 4. 测试服务

```bash
# 获取服务器 IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# 测试 API 连接
curl http://localhost:11434/api/tags

# 测试模型生成（使用 7B 模型，响应快）
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5:7b",
    "prompt": "你好，请介绍一下你自己",
    "stream": false
  }'
```

#### 5. 配置 Python 客户端

```bash
# 安装 Python 依赖（使用 Poetry）
poetry install

# 或使用 pip
pip install -r requirements.txt

# 运行测试脚本
poetry run python test_client.py
```

### 方式二：直接在主机上运行 Ollama

如果不想使用 Docker，可以直接在主机上安装 Ollama。

#### 1. 安装 Ollama

```bash
# 使用官方安装脚本
curl -fsSL https://ollama.ai/install.sh | sh

# 或使用项目提供的脚本
chmod +x setup_ollama.sh
./setup_ollama.sh
```

#### 2. 配置外部访问

```bash
# 配置 Ollama 监听所有网络接口
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf << EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_ORIGINS=*"
EOF

# 重启服务
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

#### 3. 下载模型

```bash
# 下载 7B 模型（推荐，响应快）
ollama pull qwen2.5:7b

# 下载 32B 模型（平衡性能和质量）
ollama pull qwen2.5:32b

# 下载 72B 模型（最佳质量，需要大量资源）
ollama pull qwen2.5:72b

# 查看已安装的模型
ollama list
```

#### 4. 测试服务

```bash
# 命令行交互测试
ollama run qwen2.5:7b

# API 测试
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{"model": "qwen2.5:7b", "prompt": "Hello", "stream": false}'
```

## 🎯 模型选择指南

根据您的硬件资源和使用场景选择合适的模型：

### Qwen 2.5 7B（推荐日常使用）

**适用场景：**
- 日常对话和问答
- 代码生成和解释
- 文本摘要和翻译
- 快速原型开发

**性能特点：**
- 响应速度快（2-5秒）
- 内存占用低（8GB 可运行）
- 适合笔记本和工作站

**使用方法：**
```bash
# Docker 环境
docker exec ollama-service ollama run qwen2.5:7b

# 主机环境
ollama run qwen2.5:7b

# API 调用
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{"model": "qwen2.5:7b", "prompt": "你的问题"}'
```

### Qwen 2.5 32B（平衡性能）

**适用场景：**
- 复杂推理任务
- 专业领域问答
- 长文本处理
- 代码审查和优化

**性能特点：**
- 响应速度中等（5-15秒）
- 内存占用中等（16-32GB）
- 质量明显优于 7B

**使用方法：**
```bash
# 切换到 32B 模型
docker exec ollama-service ollama run qwen2.5:32b

# API 调用
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{"model": "qwen2.5:32b", "prompt": "你的问题"}'
```

### Qwen 2.5 72B（最佳质量）

**适用场景：**
- 高质量内容创作
- 复杂逻辑推理
- 专业技术咨询
- 研究和分析

**性能特点：**
- 响应速度较慢（15-60秒）
- 内存占用高（32-64GB）
- 质量接近 GPT-4

**使用方法：**
```bash
# 切换到 72B 模型
docker exec ollama-service ollama run qwen2.5:72b

# API 调用
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{"model": "qwen2.5:72b", "prompt": "你的问题"}'
```

## 💻 Python 客户端使用

### 基础示例

```python
from ollama_client import create_client

# 创建客户端（默认使用 qwen2.5:7b）
client = create_client()

# 健康检查
if client.health_check():
    # 生成文本
    response = client.generate("什么是人工智能？")
    print(response['response'])
```

### 指定模型

```python
from ollama_client import OllamaConfig, OllamaClient

# 使用 32B 模型
config = OllamaConfig(
    host="localhost",
    port=11434,
    model="qwen2.5:32b",  # 指定模型
    timeout=60
)
client = OllamaClient(config)

response = client.generate("解释量子计算的原理")
print(response['response'])
```

### 聊天对话

```python
# 多轮对话
messages = [
    {"role": "user", "content": "你好！能帮我学习 Python 吗？"}
]

response = client.chat(messages)
print(response['message']['content'])

# 继续对话
messages.append(response['message'])
messages.append({"role": "user", "content": "如何定义一个函数？"})
response = client.chat(messages)
print(response['message']['content'])
```

### 流式响应

```python
# 实时流式输出
print("AI 回答：", end='')
for chunk in client.generate_stream("讲一个关于AI的故事"):
    if chunk.get('response'):
        print(chunk['response'], end='', flush=True)
    if chunk.get('done'):
        break
print()
```

### 异步使用

```python
import asyncio
from ollama_client import create_async_client

async def async_example():
    async with create_async_client() as client:
        # 异步生成
        result = await client.generate("什么是深度学习？")
        print(result['response'])
        
        # 异步流式
        async for chunk in client.generate_stream("解释神经网络"):
            if chunk.get('response'):
                print(chunk['response'], end='', flush=True)
            if chunk.get('done'):
                break

asyncio.run(async_example())
```

## ⚙️ 配置说明

### 环境变量配置

客户端会自动读取以下环境变量：

```bash
# 创建 .env 文件（可选）
cat > .env << EOF
OLLAMA_HOST=localhost
OLLAMA_PORT=11434
OLLAMA_MODEL=qwen2.5:7b
OLLAMA_TIMEOUT=60
EOF
```

### 自定义配置

```python
from ollama_client import OllamaConfig, OllamaClient

# 连接到远程服务器
config = OllamaConfig(
    host="10.176.202.207",  # 远程服务器 IP
    port=11434,
    model="qwen2.5:32b",
    timeout=120  # 大模型需要更长超时时间
)

client = OllamaClient(config)
```

## 🧪 测试验证

### 快速测试

运行完整的测试套件：

```bash
# 使用 Poetry（推荐）
poetry run python test_client.py

# 或使用 Makefile
make test

# 或直接运行
python test_client.py
```

### 测试内容

测试脚本会验证以下功能：
- ✅ 服务连接性检查
- ✅ 模型列表获取
- ✅ 文本生成功能
- ✅ 聊天对话接口
- ✅ 流式响应
- ✅ 异步功能

### 手动测试命令

```bash
# 1. 检查服务状态
curl http://localhost:11434/api/tags

# 2. 测试 7B 模型（快速）
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5:7b",
    "prompt": "用一句话介绍人工智能",
    "stream": false
  }' | python3 -m json.tool

# 3. 测试 32B 模型（质量更好）
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5:32b",
    "prompt": "解释深度学习的工作原理",
    "stream": false
  }' | python3 -m json.tool

# 4. 测试聊天接口
curl http://localhost:11434/api/chat -X POST \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5:7b",
    "messages": [
      {"role": "user", "content": "你好，请介绍一下你自己"}
    ]
  }' | python3 -m json.tool

# 5. 测试流式响应
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5:7b",
    "prompt": "讲一个笑话",
    "stream": true
  }'
```

## 🔧 服务管理

### Docker Compose 命令

```bash
# 查看服务状态
docker compose -f docker-compose-complete.yml ps

# 查看实时日志
docker compose -f docker-compose-complete.yml logs -f

# 查看 Ollama 服务日志
docker compose -f docker-compose-complete.yml logs -f ollama

# 查看 Nginx 日志
docker compose -f docker-compose-complete.yml logs -f nginx

# 重启服务
docker compose -f docker-compose-complete.yml restart

# 重启特定服务
docker compose -f docker-compose-complete.yml restart ollama

# 停止服务
docker compose -f docker-compose-complete.yml down

# 停止并删除数据卷（谨慎使用）
docker compose -f docker-compose-complete.yml down -v

# 启动服务
docker compose -f docker-compose-complete.yml up -d

# 查看资源占用
docker stats ollama-service nginx-proxy
```

### 容器内操作

```bash
# 进入 Ollama 容器
docker exec -it ollama-service bash

# 在容器内查看模型
docker exec ollama-service ollama list

# 在容器内运行模型
docker exec -it ollama-service ollama run qwen2.5:7b

# 在容器内下载新模型
docker exec ollama-service ollama pull qwen2.5:14b

# 在容器内删除模型
docker exec ollama-service ollama rm qwen2.5:72b
```

### 模型管理

```bash
# 查看已安装的模型
docker exec ollama-service ollama list

# 查看模型详细信息
docker exec ollama-service ollama show qwen2.5:7b

# 下载其他模型
docker exec ollama-service ollama pull llama2:7b
docker exec ollama-service ollama pull codellama:13b
docker exec ollama-service ollama pull mistral:7b

# 删除不需要的模型（释放空间）
docker exec ollama-service ollama rm qwen2.5:72b
```

## 🛠️ 开发指南

### 使用 Poetry（推荐）

```bash
# 激活虚拟环境
poetry shell

# 安装依赖
poetry install

# 安装完整依赖（包括可选功能）
poetry install --extras "full"

# 添加新依赖
poetry add requests

# 添加开发依赖
poetry add --group dev pytest

# 更新依赖
poetry update

# 查看依赖树
poetry show --tree
```

### 使用 Makefile

```bash
# 查看所有可用命令
make help

# 设置项目
make setup

# 运行测试
make test

# 代码格式化
make format

# 代码检查
make lint

# 清理缓存
make clean
```

### API 开发

如果需要开发自己的 API 服务：

```bash
# 安装 API 依赖
poetry install --extras "api"

# 启动开发服务器
make dev-server

# 或手动启动
poetry run uvicorn api_server:app --reload --host 0.0.0.0 --port 8000
```

## 📚 文档资源

- [中文文档](docs/zh/README.md) - 完整中文文档
- **[快速部署指南](docs/zh/quick-start.md)** - 快速部署和测试指南
- **[Docker Compose完整指南](docs/zh/docker-compose-complete-guide.md)** - 一键部署Ollama+Nginx完整服务栈
- **[性能优化指南](docs/zh/performance-optimization.md)** - 解决大模型推理性能问题
- **[Host完整部署指南](docs/zh/host-deployment-complete.md)** - 从裸机到Host服务运行的完整过程
- **[裸机完整部署指南](docs/zh/bare-metal-deployment.md)** - Complete bare-metal deployment guide
- **[快速安装命令参考](docs/zh/quick-setup-commands.md)** - Quick setup commands reference
- [安装指南](docs/zh/installation.md) - Installation guide
- [第三方集成指南](docs/zh/third-party-integration.md) - Third-party integration guide

## 🔍 故障排查

### 服务无法启动

```bash
# 检查 Docker 服务
sudo systemctl status docker

# 检查容器状态
docker compose -f docker-compose-complete.yml ps

# 查看错误日志
docker compose -f docker-compose-complete.yml logs ollama

# 检查端口占用
sudo lsof -i :11434
sudo lsof -i :80

# 重启服务
docker compose -f docker-compose-complete.yml restart
```

### 端口冲突

如果 11434 或 80 端口被占用：

```bash
# 查看占用端口的进程
sudo lsof -i :11434
sudo lsof -i :80

# 停止冲突的服务
sudo systemctl stop ollama  # 如果主机上有 Ollama
sudo systemctl stop nginx   # 如果主机上有 Nginx

# 或者修改 docker-compose-complete.yml 中的端口映射
# 例如将 11434 改为 11435
```

### 模型下载失败

```bash
# 进入容器手动下载
docker exec -it ollama-service bash
ollama pull qwen2.5:7b

# 或者从外部下载
docker exec ollama-service ollama pull qwen2.5:7b

# 检查网络连接
docker exec ollama-service ping -c 3 ollama.ai

# 如果网络有问题，可以配置代理
# 编辑 docker-compose-complete.yml，添加环境变量：
# environment:
#   - HTTP_PROXY=http://your-proxy:port
#   - HTTPS_PROXY=http://your-proxy:port
```

### 性能问题

#### 响应速度慢

```bash
# 1. 切换到更小的模型
# 从 72B → 32B → 7B

# 2. 检查 GPU 使用情况
nvidia-smi

# 3. 检查系统资源
docker stats ollama-service

# 4. 查看容器日志
docker compose -f docker-compose-complete.yml logs ollama | tail -100
```

#### 内存不足

```bash
# 1. 使用更小的模型
docker exec ollama-service ollama rm qwen2.5:72b
docker exec ollama-service ollama pull qwen2.5:7b

# 2. 调整 Docker 内存限制
# 编辑 docker-compose-complete.yml
# 增加 memory 限制

# 3. 检查系统内存
free -h
```

#### GPU 未被使用

```bash
# 检查 nvidia-docker 是否安装
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi

# 检查容器是否能访问 GPU
docker exec ollama-service nvidia-smi

# 如果看不到 GPU，重新安装 nvidia-container-toolkit
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
docker compose -f docker-compose-complete.yml restart
```

### API 调用失败

```bash
# 1. 检查服务是否运行
curl http://localhost:11434/api/tags

# 2. 检查模型是否加载
docker exec ollama-service ollama list

# 3. 测试简单请求
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{"model": "qwen2.5:7b", "prompt": "Hi", "stream": false}'

# 4. 检查超时设置
# 大模型可能需要更长的超时时间
# 在 Python 客户端中增加 timeout 参数
```

### 容器健康检查失败

```bash
# 查看健康检查日志
docker inspect ollama-service | grep -A 10 Health

# 手动运行健康检查命令
docker exec ollama-service ollama list

# 如果失败，重启容器
docker compose -f docker-compose-complete.yml restart ollama
```

## 🌐 外部访问配置

### 通过 IP 访问

```bash
# 获取服务器 IP
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "访问地址: http://$SERVER_IP:11434"

# 测试外部访问
curl http://$SERVER_IP:11434/api/tags
```

### 通过 Nginx 访问

当前配置已包含 Nginx 反向代理：

```bash
# 通过 Nginx 访问（80 端口）
curl http://$SERVER_IP/api/tags

# 查看 Nginx 配置
cat nginx/ollama-docker.conf

# 查看 Nginx 日志
docker compose -f docker-compose-complete.yml logs nginx
```

### 配置域名访问

如果有域名，可以配置 DNS 指向服务器 IP，然后：

```bash
# 编辑 Nginx 配置
vim nginx/ollama-docker.conf

# 添加 server_name
# server_name your-domain.com;

# 重启 Nginx
docker compose -f docker-compose-complete.yml restart nginx
```

## 🚀 性能优化建议

### 选择合适的模型

| 场景 | 推荐模型 | 原因 |
|------|---------|------|
| 快速原型开发 | qwen2.5:7b | 响应快，资源占用少 |
| 日常使用 | qwen2.5:7b | 性价比最高 |
| 专业应用 | qwen2.5:32b | 质量和速度平衡 |
| 高质量输出 | qwen2.5:72b | 最佳质量，需要强大硬件 |

### GPU 加速

如果有 NVIDIA GPU，确保正确配置：

```bash
# 检查 GPU 是否被容器使用
docker exec ollama-service nvidia-smi

# 查看 GPU 利用率
watch -n 1 nvidia-smi
```

### 并发优化

在 `docker-compose-complete.yml` 中调整并发参数：

```yaml
environment:
  - OLLAMA_NUM_PARALLEL=2  # 允许同时处理的请求数
  - OLLAMA_MAX_LOADED_MODELS=1  # 同时加载的模型数
```

### 内存优化

```bash
# 1. 只保留需要的模型
docker exec ollama-service ollama list
docker exec ollama-service ollama rm <不需要的模型>

# 2. 调整 Docker 内存限制
# 编辑 docker-compose-complete.yml 中的 memory 设置

# 3. 使用量化版本的模型（默认已是 Q4_K_M 量化）
```

## 📊 API 参考

### Python 客户端 API

#### OllamaClient

同步客户端，适合简单脚本和应用：

```python
from ollama_client import OllamaClient, OllamaConfig

# 创建客户端
client = OllamaClient()

# 主要方法
client.health_check()                    # 健康检查
client.list_models()                     # 列出模型
client.generate(prompt, **kwargs)        # 生成文本
client.generate_stream(prompt, **kwargs) # 流式生成
client.chat(messages, **kwargs)          # 聊天对话
```

#### AsyncOllamaClient

异步客户端，适合高并发应用：

```python
from ollama_client import AsyncOllamaClient

async with AsyncOllamaClient() as client:
    result = await client.generate("Hello")
    async for chunk in client.generate_stream("Hi"):
        print(chunk)
```

### REST API 端点

#### 生成文本

```bash
POST http://localhost:11434/api/generate
Content-Type: application/json

{
  "model": "qwen2.5:7b",
  "prompt": "你的提示词",
  "stream": false,
  "temperature": 0.7,
  "top_p": 0.9,
  "max_tokens": 2048
}
```

#### 聊天对话

```bash
POST http://localhost:11434/api/chat
Content-Type: application/json

{
  "model": "qwen2.5:7b",
  "messages": [
    {"role": "system", "content": "你是一个有帮助的助手"},
    {"role": "user", "content": "你好"}
  ]
}
```

#### 列出模型

```bash
GET http://localhost:11434/api/tags
```

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 💬 支持与反馈

遇到问题或有建议？

- 📝 [提交 Issue](../../issues)
- 📖 查看[中文文档](docs/zh/)获取详细指南
- 💡 查看测试脚本了解使用示例
- 🔍 查看故障排查部分解决常见问题

## 🙏 致谢

- [Ollama](https://ollama.ai/) - 优秀的本地 LLM 运行时
- [Qwen](https://github.com/QwenLM/Qwen) - 强大的语言模型
- [Alibaba Cloud](https://www.alibabacloud.com/) - Qwen 模型的开发者
- 所有贡献者和社区反馈

## 📈 项目状态

- ✅ Docker Compose 部署：稳定运行
- ✅ 多模型支持：7B/32B/72B
- ✅ Python 客户端：同步/异步支持
- ✅ Nginx 反向代理：生产就绪
- ✅ GPU 加速：NVIDIA GPU 支持
- ✅ 健康检查：完整监控
- 🔄 持续更新中...

---

**快速链接：**
- [快速开始](#-快速开始)
- [模型选择](#-模型选择指南)
- [Python 使用](#-python-客户端使用)
- [故障排查](#-故障排查)
- [性能优化](#-性能优化建议)
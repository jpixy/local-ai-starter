# Local AI Starter

本地 AI 服务启动器，用于安装和管理 Ollama + Qwen 2.5 模型。

## 系统要求

- Linux 操作系统
- 8GB+ RAM（推荐 16GB+）
- 10GB+ 可用磁盘空间
- curl
- GPU 可选（NVIDIA + CUDA 显著提升速度）

## 快速开始

### 方式一：Host 部署（推荐）

```bash
# 1. 安装 Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# 2. 启动服务
ollama serve &

# 3. 下载 7B 模型（推荐，4.7 GB）
ollama pull qwen2.5:7b

# 4. 验证
ollama list
curl http://localhost:11434/api/tags | jq
```

### 方式二：Docker 部署

```bash
# 启动完整服务栈（Ollama + Nginx）
docker compose -f docker-compose-complete.yml up -d

# 查看状态
docker compose -f docker-compose-complete.yml ps
```

## 使用 Makefile

```bash
make install   # 安装 Ollama + 下载模型
make start     # 启动服务
make stop      # 停止服务
make status    # 检查状态
make test      # 测试 API
make models    # 列出模型
make clean     # 清理数据
```

## 测试 API

```bash
# 文本生成
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5:7b",
  "prompt": "什么是人工智能？",
  "stream": false
}'

# 聊天对话
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5:7b",
  "messages": [{"role": "user", "content": "你好"}],
  "stream": false
}'

# 模型列表
curl http://localhost:11434/api/tags
```

## 配置外部访问

Ollama 默认只监听 localhost。配置外部访问：

```bash
# 方式一：临时（命令行）
OLLAMA_HOST=0.0.0.0 ollama serve

# 方式二：永久（systemd）
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/environment.conf << EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
EOF
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

## 模型选择

| 模型 | 大小 | 内存需求 | 适用场景 |
|------|------|---------|---------|
| **qwen2.5:7b** | 4.7 GB | 8 GB | 日常使用、media_organizer（推荐） |
| qwen2.5:32b | 19 GB | 32 GB | 复杂推理任务 |
| qwen2.5:72b | 47 GB | 64 GB | 最高质量输出 |

```bash
# 下载其他模型
ollama pull qwen2.5:32b
ollama pull qwen2.5:72b
```

## API 端点

| 端点 | 方法 | 描述 |
|------|------|------|
| `/api/generate` | POST | 文本生成 |
| `/api/chat` | POST | 聊天对话 |
| `/api/tags` | GET | 列出模型 |
| `/api/show` | POST | 模型详情 |
| `/api/pull` | POST | 下载模型 |

## 项目文件

```
local-ai-starter/
├── QUICKSTART.md              # 快速开始指南
├── README.md                  # 本文档
├── Makefile                   # 常用命令
├── setup_ollama.sh            # 安装脚本
├── docker-compose-complete.yml # Docker 部署配置
├── start-complete.sh          # Docker 启动脚本
├── test-complete.sh           # 测试脚本
├── nginx/                     # Nginx 配置
└── docs/                      # 详细文档
```

## 文档

- [快速开始](QUICKSTART.md)
- [API 参考](docs/api-reference.md)
- [中文文档](docs/zh/README.md)

官方 API 文档：https://github.com/ollama/ollama/blob/main/docs/api.md

## License

MIT

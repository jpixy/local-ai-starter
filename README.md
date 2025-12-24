# Local AI Starter

本地 AI 服务启动器，用于安装和管理 Ollama + Qwen 2.5 7B 模型。

## 功能

- 一键安装 Ollama
- 自动下载 Qwen 2.5 7B 模型
- 提供 Ollama 原生 REST API

## 系统要求

- Linux 操作系统
- 8GB+ RAM（推荐 16GB+）
- 10GB+ 可用磁盘空间
- curl

## 快速开始

### 安装

```bash
# 克隆项目
git clone <your-repo-url>
cd local-ai-starter

# 安装 Ollama 并下载模型
make install
# 或
./setup_ollama.sh
```

### 启动服务

```bash
make start
```

### 检查状态

```bash
make status
```

### 测试 API

```bash
make test
```

## API 使用

Ollama 提供 REST API，默认运行在 `http://localhost:11434`。

### 文本生成

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5:7b",
  "prompt": "什么是人工智能？",
  "stream": false
}'
```

### 聊天对话

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5:7b",
  "messages": [
    {"role": "user", "content": "你好"}
  ],
  "stream": false
}'
```

### 列出模型

```bash
curl http://localhost:11434/api/tags
```

## 命令参考

| 命令 | 描述 |
|------|------|
| `make install` | 安装 Ollama 并下载模型 |
| `make start` | 启动 Ollama 服务 |
| `make stop` | 停止 Ollama 服务 |
| `make status` | 检查服务状态 |
| `make test` | 测试 API |
| `make models` | 列出已安装模型 |
| `make clean` | 清理所有数据 |

## API 端点

| 端点 | 方法 | 描述 |
|------|------|------|
| `/api/generate` | POST | 文本生成 |
| `/api/chat` | POST | 聊天对话 |
| `/api/tags` | GET | 列出模型 |
| `/api/show` | POST | 模型详情 |
| `/api/pull` | POST | 下载模型 |

## 文档

- [API 参考](docs/api-reference.md) - 完整的 Ollama API 端点文档
- [中文文档](docs/zh/README.md)

官方 API 文档：https://github.com/ollama/ollama/blob/main/docs/api.md

## License

MIT

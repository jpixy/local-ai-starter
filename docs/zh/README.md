# Local AI Starter

本地 AI 服务启动器，用于安装和管理 Ollama + Qwen 2.5 模型。

## 功能

- 一键安装 Ollama
- 自动下载 Qwen 2.5 7B 模型
- 提供 Ollama 原生 REST API（端口 11434）

## 快速开始

### 方式一：直接安装

```bash
# 安装 Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# 启动服务
ollama serve &

# 下载模型
ollama pull qwen2.5:7b

# 验证
curl http://localhost:11434/api/tags | jq
```

### 方式二：使用 Makefile

```bash
make install   # 安装 Ollama + 下载模型
make start     # 启动服务
make status    # 检查状态
make test      # 测试 API
```

## API 使用

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
  "messages": [{"role": "user", "content": "你好"}],
  "stream": false
}'
```

## 模型选择

| 模型 | 大小 | 适用场景 |
|------|------|---------|
| **qwen2.5:7b** | 4.7 GB | 推荐，media_organizer 默认使用 |
| qwen2.5:32b | 19 GB | 复杂推理 |
| qwen2.5:72b | 47 GB | 最高质量 |

## 文档

- [快速部署](quick-start.md)
- [安装指南](installation.md)
- [Docker 部署](docker-compose-complete-guide.md)

## API 文档

完整 API 文档：https://github.com/ollama/ollama/blob/main/docs/api.md

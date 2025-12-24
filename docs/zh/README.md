# Local AI Starter

本地 AI 服务启动器，用于安装和管理 Ollama + Qwen 2.5 7B 模型。

## 功能

- 一键安装 Ollama
- 自动下载 Qwen 2.5 7B 模型
- 提供 Ollama 原生 REST API（端口 11434）

## 快速开始

```bash
# 安装
make install

# 启动
make start

# 检查状态
make status

# 测试
make test
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

## 文档

- [安装指南](installation.md)
- [快速部署](quick-start.md)

## API 文档

完整 API 文档：https://github.com/ollama/ollama/blob/main/docs/api.md

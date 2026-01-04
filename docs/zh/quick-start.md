# 快速部署指南

## 前置要求

- Linux 系统
- 8GB+ 内存
- 10GB+ 磁盘空间

## 一分钟部署（Host 方式）

```bash
# 1. 安装 Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# 2. 启动服务
ollama serve &

# 3. 下载模型（4.7 GB）
ollama pull qwen2.5:7b

# 4. 验证
curl http://localhost:11434/api/tags | jq
```

## 使用 Makefile

```bash
cd local-ai-starter

# 一键安装（约 5-10 分钟）
make install

# 验证
make status
make test
```

## Docker 部署

```bash
cd local-ai-starter

# 启动服务栈
docker compose -f docker-compose-complete.yml up -d

# 查看状态
docker compose -f docker-compose-complete.yml ps
```

## 测试 API

```bash
# 简单测试
make test

# 手动测试
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5:7b",
  "prompt": "你好",
  "stream": false
}'
```

## 日常使用

```bash
# 启动服务
make start

# 停止服务
make stop

# 查看状态
make status

# 列出模型
make models
```

## API 端点

| 端点 | 方法 | 描述 |
|------|------|------|
| `/api/generate` | POST | 文本生成 |
| `/api/chat` | POST | 聊天对话 |
| `/api/tags` | GET | 列出模型 |

## 模型选择

| 模型 | 大小 | 适用场景 |
|------|------|---------|
| **qwen2.5:7b** | 4.7 GB | 推荐，media_organizer 默认使用 |
| qwen2.5:32b | 19 GB | 复杂推理 |
| qwen2.5:72b | 47 GB | 最高质量 |

## 完成

服务运行后，其他项目可通过 `http://localhost:11434` 调用 Ollama API。

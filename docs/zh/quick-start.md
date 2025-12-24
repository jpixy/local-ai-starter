# 快速部署指南

## 前置要求

- Linux 系统
- 8GB+ 内存
- 10GB+ 磁盘空间

## 一分钟部署

```bash
# 1. 进入项目目录
cd local-ai-starter

# 2. 安装（约 5-10 分钟，取决于网速）
make install

# 3. 验证
make status
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

## 完成

服务运行后，其他项目可通过 `http://localhost:11434` 调用 Ollama API。

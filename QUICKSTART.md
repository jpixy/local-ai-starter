# 快速开始指南

## 当前系统状态 ✅

您的系统已经通过 Docker Compose 成功部署并运行！

### 运行中的服务

- **Ollama 服务**: `ollama-service` (运行中，健康)
- **Nginx 代理**: `nginx-proxy` (运行中，健康)
- **运行时长**: 12 天
- **访问端口**: 11434 (Ollama), 80/443 (Nginx)

### 已安装的模型

1. **qwen2.5:7b** - 4.7 GB (推荐日常使用)
2. **qwen2.5:32b** - 19 GB (平衡性能)
3. **qwen2.5:72b** - 47 GB (最佳质量)

## 一分钟快速测试

### 1. 检查服务状态

```bash
docker compose -f docker-compose-complete.yml ps
```

### 2. 测试 API（使用 7B 模型，最快）

```bash
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5:7b",
    "prompt": "用一句话介绍你自己",
    "stream": false
  }' | python3 -m json.tool
```

### 3. 测试 Python 客户端

```bash
# 安装依赖（如果还没安装）
poetry install

# 运行测试
poetry run python test_client.py
```

## 常用命令

```bash
# 查看日志
docker compose -f docker-compose-complete.yml logs -f ollama

# 查看模型列表
docker exec ollama-service ollama list

# 进入容器
docker exec -it ollama-service bash

# 重启服务
docker compose -f docker-compose-complete.yml restart

# 停止服务
docker compose -f docker-compose-complete.yml down

# 启动服务
docker compose -f docker-compose-complete.yml up -d
```

## 选择模型

根据您的需求选择合适的模型：

| 模型 | 响应速度 | 质量 | 内存需求 | 适用场景 |
|------|---------|------|---------|---------|
| 7B | ⚡⚡⚡ 快 | ⭐⭐⭐ 好 | 8GB | 日常对话、快速原型 |
| 32B | ⚡⚡ 中等 | ⭐⭐⭐⭐ 很好 | 16-32GB | 专业应用、复杂推理 |
| 72B | ⚡ 较慢 | ⭐⭐⭐⭐⭐ 优秀 | 32-64GB | 高质量内容创作 |

## Python 使用示例

```python
from ollama_client import create_client

# 创建客户端
client = create_client()

# 快速测试
if client.health_check():
    response = client.generate("什么是人工智能？")
    print(response['response'])
```

## 访问地址

- **本地访问**: http://localhost:11434
- **外部访问**: http://10.176.202.207:11434
- **Nginx 代理**: http://10.176.202.207 (端口 80)

## 更多信息

查看完整文档：[README.md](README.md)

---

**提示**: 如果遇到问题，请查看 README.md 中的"故障排查"部分。

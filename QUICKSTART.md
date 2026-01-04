# 快速开始指南

## 选择部署方式

| 方式 | 适用场景 | 启动时间 |
|------|---------|---------|
| **Host 部署** (推荐) | 开发环境、快速测试 | 5-10 分钟 |
| **Docker 部署** | 生产环境、多服务编排 | 10-15 分钟 |

---

## 方式一：Host 部署（推荐）

### 1. 安装 Ollama

```bash
# 一键安装
curl -fsSL https://ollama.ai/install.sh | sh
```

### 2. 启动服务

```bash
# 后台启动（推荐）
ollama serve &

# 或使用 systemd（需要配置外部访问）
sudo systemctl start ollama
```

### 3. 下载模型

```bash
# qwen2.5:7b (4.7 GB) - 推荐，适合大多数场景
ollama pull qwen2.5:7b

# 验证
ollama list
```

### 4. 测试

```bash
curl http://localhost:11434/api/generate -X POST \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5:7b",
    "prompt": "你好",
    "stream": false
  }' | jq '.response'
```

---

## 方式二：Docker 部署

```bash
cd local-ai-starter

# 启动服务栈（Ollama + Nginx）
docker compose -f docker-compose-complete.yml up -d

# 查看状态
docker compose -f docker-compose-complete.yml ps

# 查看日志
docker compose -f docker-compose-complete.yml logs -f ollama
```

---

## 常用命令

### Host 部署

```bash
# 启动
ollama serve &

# 停止
pkill ollama

# 状态
curl http://localhost:11434/api/tags | jq

# 模型列表
ollama list
```

### Docker 部署

```bash
# 启动
docker compose -f docker-compose-complete.yml up -d

# 停止
docker compose -f docker-compose-complete.yml down

# 状态
docker compose -f docker-compose-complete.yml ps

# 进入容器
docker exec -it ollama-service bash
```

---

## 使用 Makefile（Host 部署）

```bash
make install   # 安装 Ollama + 下载 7B 模型
make start     # 启动服务
make stop      # 停止服务
make status    # 检查状态
make test      # 测试 API
make models    # 列出模型
```

---

## 模型选择

| 模型 | 大小 | 内存需求 | 响应速度 | 适用场景 |
|------|------|---------|---------|---------|
| **qwen2.5:7b** | 4.7 GB | 8 GB | ⚡ 快 | 日常使用、media_organizer |
| qwen2.5:32b | 19 GB | 32 GB | 中等 | 复杂推理 |
| qwen2.5:72b | 47 GB | 64 GB | 慢 | 最高质量 |

**media_organizer 默认使用 `qwen2.5:7b`**

---

## 访问地址

- **本地**: http://localhost:11434
- **外部**: http://<server-ip>:11434

---

## 故障排查

```bash
# Ollama 未运行
ollama serve &

# 模型未下载
ollama pull qwen2.5:7b

# 端口被占用
lsof -i :11434
```

---

## 更多信息

- [README.md](README.md) - 完整文档
- [API 参考](docs/api-reference.md) - Ollama API 文档

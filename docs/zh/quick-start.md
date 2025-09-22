# 快速部署测试指南

本指南将带您从零开始，一步步完成 Ollama + Qwen 2.5 7B 本地 AI 系统的部署和测试。

## 前置要求

- **系统**: Linux、macOS 或 Windows
- **内存**: 8GB+ (推荐 16GB+)
- **磁盘**: 10GB+ 可用空间
- **Python**: 3.9+ 版本

## 第一步：检查系统环境

```bash
# 检查 Python 版本
python3 --version

# 检查内存 (Linux)
free -h

# 检查磁盘空间
df -h
```

**确保有足够的内存和磁盘空间。**

## 第二步：获取项目

```bash
# 克隆项目
git clone <your-repo-url>
cd local-ai-starter

# 查看项目文件
ls -la
```

## 第三步：安装 Poetry（推荐）

```bash
# 安装 Poetry
curl -sSL https://install.python-poetry.org | python3 -

# 验证安装
poetry --version
```

## 第四步：安装 Ollama 和模型

```bash
# 运行安装脚本
chmod +x setup_ollama.sh
./setup_ollama.sh
```

**注意**：模型下载约 4.7GB，需要稳定网络连接。

安装完成后验证：
```bash
# 检查 Ollama 版本
ollama --version

# 检查已安装模型
ollama list

# 检查服务状态
curl -s http://localhost:11434/api/tags
```

应该看到 `qwen2.5:7b` 模型已安装。

## 第五步：设置 Python 环境

```bash
# 使用 Poetry 安装依赖（会自动创建虚拟环境）
poetry install --no-root

# 安装 API 扩展功能
poetry install --extras "api" --no-root
```

**重要**：不需要手动创建 venv，Poetry 会自动管理虚拟环境。

## 第六步：测试 Python 客户端

```bash
# 运行测试脚本
poetry run python test_client.py
```

**成功标志**：看到以下输出
```
SUCCESS: All tests completed successfully!
Your Ollama Qwen 7B setup is working correctly.
```

测试包括：
- ✅ 同步客户端（文本生成、聊天、流式响应）
- ✅ 异步客户端（批量处理、并发调用）
- ✅ 配置管理（环境变量、自定义设置）

## 第七步：启动 REST API 服务

```bash
# 启动 API 服务器
poetry run python api_server.py
```

看到以下输出表示成功：
```
Starting Local AI API Server at http://0.0.0.0:8000
INFO:__main__:AI client initialized successfully
INFO:     Uvicorn running on http://0.0.0.0:8000
```

## 第八步：测试 API 接口

**新开一个终端**，运行以下测试：

### 健康检查
```bash
curl -s http://localhost:8000/health | python -m json.tool
```

期望输出：
```json
{
    "status": "healthy",
    "message": "Service is running",
    "ollama_available": true
}
```

### 模型列表
```bash
curl -s http://localhost:8000/models | python -m json.tool
```

### 文本生成
```bash
curl -X POST http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "什么是人工智能？",
    "temperature": 0.7
  }' | python -m json.tool
```

### 聊天对话
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "你好，介绍一下你自己"}
    ]
  }' | python -m json.tool
```

### 流式生成
```bash
curl -X POST http://localhost:8000/generate/stream \
  -H "Content-Type: application/json" \
  -d '{"prompt": "数从1到5"}' | head -10
```

## 第九步：访问 API 文档

在浏览器中打开：
- **Swagger UI**: http://localhost:8000/docs
- **API 根路径**: http://localhost:8000/

## 验证完成

如果以上所有步骤都成功，您现在拥有：

### ✅ 完整的本地 AI 系统
- Ollama 服务运行在 `localhost:11434`
- Qwen 2.5 7B 模型已加载
- Python 客户端库可用
- REST API 服务运行在 `localhost:8000`

### ✅ 两种使用方式

**Python 库方式**：
```python
from ollama_client import create_client
client = create_client()
response = client.generate("你的问题")
print(response['response'])
```

**REST API 方式**：
```bash
curl -X POST http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "你的问题"}'
```

## 常见问题

### Q: Poetry 安装失败怎么办？
A: 可以回退使用 pip 方式：
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Q: 模型下载很慢？
A: 这是正常的，qwen2.5:7b 约 4.7GB。确保网络稳定，耐心等待。

### Q: API 服务端口被占用？
A: 更改端口：
```bash
# 编辑 api_server.py，修改 port = 8001
poetry run python api_server.py
```

### Q: 内存不足？
A: 
- 关闭其他应用程序
- 确保至少 8GB 可用内存
- 考虑使用更小的模型

### Q: 测试失败？
A: 按顺序检查：
1. Ollama 服务是否运行: `ollama list`
2. 模型是否下载: 应看到 `qwen2.5:7b`
3. Python 依赖是否安装: `poetry show`
4. 端口是否冲突: `netstat -tlnp | grep 11434`

## 下一步

系统部署成功后，您可以：

1. **集成到您的应用**: 参考 [第三方集成指南](third-party-integration.md)
2. **自定义配置**: 修改 `.env` 文件中的参数
3. **部署到生产环境**: 使用 Docker 或 Kubernetes
4. **扩展功能**: 添加更多模型或自定义 API 端点

恭喜！您已成功部署了一个完整的本地 AI 系统。

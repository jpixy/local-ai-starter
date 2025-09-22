# Ollama Qwen 7B 本地AI系统使用指南

## 概述

本项目提供了一个完整的解决方案，使用 Ollama 在本地部署 Qwen 7B 模型，并通过 Python 库进行接入。支持同步和异步调用方式。

## 系统要求

- **操作系统**: Linux, macOS, 或 Windows
- **内存**: 至少 8GB RAM（推荐 16GB+）
- **存储**: 至少 10GB 可用空间
- **Python**: 3.8 或更高版本
- **网络**: 稳定的互联网连接（用于下载模型）

## 快速开始

### 方式一：使用 Poetry（推荐）

#### 1. 获取项目

```bash
# 克隆项目
git clone <your-repo-url>
cd local-ai-starter
```

#### 2. 设置 Poetry 环境

```bash
# 安装 Poetry（如果未安装）
curl -sSL https://install.python-poetry.org | python3 -

# 安装依赖（Poetry 会自动创建和管理虚拟环境）
poetry install

# 或使用自动设置脚本
chmod +x poetry_setup.sh
./poetry_setup.sh

# 或使用 Makefile
make setup
```

#### 3. 安装和配置 Ollama

```bash
# 运行安装脚本
./setup_ollama.sh
# 或
make run-ollama
```

#### 4. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，根据需要修改配置（默认模型为 qwen2.5:7b）
nano .env
```

#### 5. 测试安装

```bash
# 运行测试脚本
poetry run python test_client.py
# 或
make test
```

### 方式二：使用 pip（传统方式 - 不推荐）

**注意**: 推荐使用 Poetry，因为它提供更好的依赖管理。

#### 1. 获取项目

```bash
# 克隆项目
git clone <your-repo-url>
cd local-ai-starter
```

#### 2. 设置Python环境

```bash
# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/macOS
# 或 venv\Scripts\activate  # Windows

# 安装依赖
pip install -r requirements.txt
```

#### 3. 安装和配置 Ollama

```bash
# 运行安装脚本
chmod +x setup_ollama.sh
./setup_ollama.sh
```

#### 4. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，根据需要修改配置（默认模型为 qwen2.5:7b）
nano .env
```

#### 5. 测试安装

```bash
# 运行测试脚本
python test_client.py
```

## 使用方法

### 基础使用示例

```python
from ollama_client import create_client

# 创建客户端
client = create_client()

# 检查服务状态
if client.health_check():
    print("服务正常运行")
    
    # 简单文本生成
    response = client.generate("你好，请介绍一下人工智能")
    print(response['response'])
else:
    print("Ollama 服务未启动")
```

### 聊天对话

```python
# 聊天对话
messages = [
    {"role": "user", "content": "你好，我想学习Python编程"}
]

response = client.chat(messages)
print(response['message']['content'])
```

### 流式响应

```python
# 流式生成，实时获取响应
for chunk in client.generate_stream("请详细解释机器学习的原理"):
    if chunk.get('response'):
        print(chunk['response'], end='', flush=True)
    if chunk.get('done'):
        break
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
        
        # 异步流式生成
        async for chunk in client.generate_stream("解释神经网络"):
            if chunk.get('response'):
                print(chunk['response'], end='')
            if chunk.get('done'):
                break

# 运行异步函数
asyncio.run(async_example())
```

## 高级配置

### 环境变量配置

在 `.env` 文件中可以配置以下参数：

```bash
# Ollama 服务器配置
OLLAMA_HOST=localhost
OLLAMA_PORT=11434
OLLAMA_MODEL=qwen:7b
OLLAMA_TIMEOUT=60

# 模型参数
OLLAMA_TEMPERATURE=0.7
OLLAMA_TOP_P=0.9
OLLAMA_MAX_TOKENS=2048
```

### 自定义配置

```python
from ollama_client import OllamaConfig, OllamaClient

# 自定义配置
config = OllamaConfig(
    host="192.168.1.100",
    port=11434,
    model="qwen:7b",
    timeout=30
)

client = OllamaClient(config)
```

## 开发指南

### 使用 Poetry 进行开发

```bash
# 激活虚拟环境
poetry shell

# 添加新依赖
poetry add requests

# 添加开发依赖
poetry add --group dev pytest

# 在虚拟环境中运行命令
poetry run python test_client.py

# 安装可选功能
poetry install --extras "data api"

# 更新依赖
poetry update

# 查看依赖树
poetry show --tree
```

### 使用 Makefile 快速操作

```bash
# 查看所有可用命令
make help

# 设置项目环境
make setup

# 运行测试
make test

# 代码格式化
make format

# 代码检查
make lint

# 清理缓存文件
make clean
```

### 项目结构

```
local-ai-starter/
├── pyproject.toml          # Poetry 配置文件
├── Makefile               # 快速操作命令
├── poetry_setup.sh        # Poetry 自动设置脚本
├── setup_ollama.sh        # Ollama 设置脚本
├── requirements.txt       # pip 依赖文件（兼容性）
├── .env.example          # 环境变量模板
├── ollama_client.py      # 主客户端库
├── test_client.py        # 测试脚本
└── docs/zh/              # 中文文档
```

### 可选功能安装

Poetry 支持可选功能组合：

```bash
# 数据处理功能（pandas, numpy）
poetry install --extras "data"

# API 服务功能（fastapi, uvicorn）
poetry install --extras "api"

# 全部可选功能
poetry install --extras "full"

# 多个功能组合
poetry install --extras "data api"
```

## 常见问题

### Q: 模型下载失败怎么办？

A: 检查网络连接，确保有足够的磁盘空间。可以尝试手动下载：
```bash
ollama pull qwen:7b
```

### Q: 响应速度慢怎么办？

A: 
1. 确保有足够的内存
2. 检查系统负载
3. 调整 `timeout` 参数
4. 考虑使用更小的模型

### Q: 如何切换其他模型？

A: 修改环境变量 `OLLAMA_MODEL` 或在代码中指定：
```python
client = create_client(model="llama2:7b")
```

### Q: 如何处理长文本？

A: 可以分块处理或使用流式生成：
```python
# 流式处理长文本
for chunk in client.generate_stream(long_prompt):
    # 处理每个响应块
    process_chunk(chunk)
```

## 性能优化建议

1. **内存优化**: 确保系统有足够内存，关闭不必要的程序
2. **并发控制**: 避免同时发起过多请求
3. **超时设置**: 根据实际情况调整超时时间
4. **模型选择**: 根据性能要求选择合适大小的模型

## 安全注意事项

1. **API访问**: 如果对外开放服务，注意设置防火墙规则
2. **敏感信息**: 不要在代码中硬编码敏感信息，使用环境变量
3. **输入验证**: 对用户输入进行适当的验证和清理
4. **日志记录**: 注意日志中不要包含敏感信息

## 故障排除

### 检查服务状态

```bash
# 检查 Ollama 服务是否运行
ps aux | grep ollama

# 检查端口是否监听
netstat -tlnp | grep 11434

# 手动启动服务
ollama serve
```

### 重新安装模型

```bash
# 删除现有模型
ollama rm qwen:7b

# 重新下载
ollama pull qwen:7b
```

### 日志调试

```python
import logging

# 启用详细日志
logging.basicConfig(level=logging.DEBUG)

# 创建客户端进行调试
client = create_client()
```

## 更多资源

- **[快速部署测试指南](quick-start.md)** - 一步步部署和测试完整流程
- [第三方应用集成指南](third-party-integration.md) - 详细的集成方案
- [安装指南](installation.md) - 详细安装步骤
- [Ollama 官方文档](https://ollama.ai/docs)
- [Qwen 模型介绍](https://github.com/QwenLM/Qwen)
- [Python 异步编程指南](https://docs.python.org/3/library/asyncio.html)

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 许可证

本项目采用 MIT 许可证。

# Ollama API Reference

Ollama REST API 完整参考文档。

**Base URL**: `http://localhost:11434`

---

## 目录

- [Generate - 文本生成](#generate---文本生成)
- [Chat - 聊天对话](#chat---聊天对话)
- [Embeddings - 嵌入向量](#embeddings---嵌入向量)
- [List Models - 列出模型](#list-models---列出模型)
- [Show Model - 模型详情](#show-model---模型详情)
- [Pull Model - 拉取模型](#pull-model---拉取模型)
- [Push Model - 推送模型](#push-model---推送模型)
- [Create Model - 创建模型](#create-model---创建模型)
- [Copy Model - 复制模型](#copy-model---复制模型)
- [Delete Model - 删除模型](#delete-model---删除模型)
- [List Running Models - 运行中的模型](#list-running-models---运行中的模型)
- [Health Check - 健康检查](#health-check---健康检查)

---

## Generate - 文本生成

生成给定提示的文本响应。

**端点**: `POST /api/generate`

### 请求参数

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `model` | string | ✅ | 模型名称 |
| `prompt` | string | ✅ | 输入提示 |
| `stream` | boolean | ❌ | 是否流式输出，默认 `true` |
| `format` | string | ❌ | 输出格式，如 `"json"` |
| `options` | object | ❌ | 模型参数（temperature, top_p 等） |
| `system` | string | ❌ | 系统提示 |
| `template` | string | ❌ | 自定义模板 |
| `context` | array | ❌ | 上下文（来自之前响应） |
| `raw` | boolean | ❌ | 是否跳过模板处理 |
| `keep_alive` | string | ❌ | 模型保持加载时间，如 `"5m"` |

### Options 参数

| 参数 | 类型 | 描述 |
|------|------|------|
| `temperature` | float | 采样温度，0-2，默认 0.8 |
| `top_p` | float | 核采样，0-1 |
| `top_k` | int | Top-K 采样 |
| `num_predict` | int | 最大生成 token 数，-1 无限制 |
| `stop` | array | 停止序列 |
| `seed` | int | 随机种子 |

### 示例

```bash
# 基础请求
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5:7b",
  "prompt": "什么是人工智能？",
  "stream": false
}'

# 带参数
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5:7b",
  "prompt": "写一首诗",
  "stream": false,
  "options": {
    "temperature": 0.9,
    "num_predict": 100
  }
}'

# JSON 格式输出
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5:7b",
  "prompt": "列出三种水果，返回JSON数组",
  "stream": false,
  "format": "json"
}'
```

### 响应

```json
{
  "model": "qwen2.5:7b",
  "created_at": "2024-12-24T10:00:00.000000Z",
  "response": "人工智能是...",
  "done": true,
  "context": [1, 2, 3, ...],
  "total_duration": 5000000000,
  "load_duration": 1000000000,
  "prompt_eval_count": 10,
  "prompt_eval_duration": 500000000,
  "eval_count": 50,
  "eval_duration": 3000000000
}
```

---

## Chat - 聊天对话

多轮对话接口。

**端点**: `POST /api/chat`

### 请求参数

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `model` | string | ✅ | 模型名称 |
| `messages` | array | ✅ | 消息列表 |
| `stream` | boolean | ❌ | 是否流式输出，默认 `true` |
| `format` | string | ❌ | 输出格式 |
| `options` | object | ❌ | 模型参数 |
| `keep_alive` | string | ❌ | 模型保持加载时间 |

### Message 格式

| 字段 | 类型 | 描述 |
|------|------|------|
| `role` | string | `"system"`, `"user"`, `"assistant"` |
| `content` | string | 消息内容 |
| `images` | array | Base64 编码的图片（多模态模型） |

### 示例

```bash
# 单轮对话
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5:7b",
  "messages": [
    {"role": "user", "content": "你好"}
  ],
  "stream": false
}'

# 多轮对话
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5:7b",
  "messages": [
    {"role": "system", "content": "你是一个友好的助手"},
    {"role": "user", "content": "什么是机器学习？"},
    {"role": "assistant", "content": "机器学习是..."},
    {"role": "user", "content": "能举个例子吗？"}
  ],
  "stream": false
}'
```

### 响应

```json
{
  "model": "qwen2.5:7b",
  "created_at": "2024-12-24T10:00:00.000000Z",
  "message": {
    "role": "assistant",
    "content": "你好！有什么可以帮助你的吗？"
  },
  "done": true,
  "total_duration": 3000000000,
  "load_duration": 500000000,
  "prompt_eval_count": 5,
  "eval_count": 20
}
```

---

## Embeddings - 嵌入向量

生成文本的嵌入向量。

**端点**: `POST /api/embeddings`

### 请求参数

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `model` | string | ✅ | 模型名称 |
| `prompt` | string | ✅ | 输入文本 |
| `options` | object | ❌ | 模型参数 |
| `keep_alive` | string | ❌ | 模型保持加载时间 |

### 示例

```bash
curl http://localhost:11434/api/embeddings -d '{
  "model": "qwen2.5:7b",
  "prompt": "Hello world"
}'
```

### 响应

```json
{
  "embedding": [0.123, -0.456, 0.789, ...]
}
```

---

## List Models - 列出模型

列出本地已安装的模型。

**端点**: `GET /api/tags`

### 示例

```bash
curl http://localhost:11434/api/tags
```

### 响应

```json
{
  "models": [
    {
      "name": "qwen2.5:7b",
      "model": "qwen2.5:7b",
      "modified_at": "2024-12-24T10:00:00.000000Z",
      "size": 4683087332,
      "digest": "sha256:...",
      "details": {
        "parent_model": "",
        "format": "gguf",
        "family": "qwen2",
        "families": ["qwen2"],
        "parameter_size": "7.6B",
        "quantization_level": "Q4_K_M"
      }
    }
  ]
}
```

---

## Show Model - 模型详情

显示模型的详细信息。

**端点**: `POST /api/show`

### 请求参数

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `name` | string | ✅ | 模型名称 |

### 示例

```bash
curl http://localhost:11434/api/show -d '{
  "name": "qwen2.5:7b"
}'
```

### 响应

```json
{
  "modelfile": "FROM qwen2.5:7b\n...",
  "parameters": "temperature 0.8\n...",
  "template": "...",
  "details": {
    "parent_model": "",
    "format": "gguf",
    "family": "qwen2",
    "parameter_size": "7.6B",
    "quantization_level": "Q4_K_M"
  }
}
```

---

## Pull Model - 拉取模型

从远程仓库下载模型。

**端点**: `POST /api/pull`

### 请求参数

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `name` | string | ✅ | 模型名称 |
| `stream` | boolean | ❌ | 是否流式输出进度 |

### 示例

```bash
curl http://localhost:11434/api/pull -d '{
  "name": "qwen2.5:7b",
  "stream": false
}'
```

### 响应（流式）

```json
{"status": "pulling manifest"}
{"status": "downloading sha256:...", "completed": 1000000, "total": 5000000000}
{"status": "verifying sha256 digest"}
{"status": "writing manifest"}
{"status": "success"}
```

---

## Push Model - 推送模型

将模型推送到远程仓库（需要认证）。

**端点**: `POST /api/push`

### 请求参数

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `name` | string | ✅ | 模型名称 |
| `stream` | boolean | ❌ | 是否流式输出进度 |

### 示例

```bash
curl http://localhost:11434/api/push -d '{
  "name": "username/mymodel:latest",
  "stream": false
}'
```

---

## Create Model - 创建模型

从 Modelfile 创建模型。

**端点**: `POST /api/create`

### 请求参数

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `name` | string | ✅ | 新模型名称 |
| `modelfile` | string | ✅ | Modelfile 内容 |
| `stream` | boolean | ❌ | 是否流式输出 |

### 示例

```bash
curl http://localhost:11434/api/create -d '{
  "name": "my-custom-model",
  "modelfile": "FROM qwen2.5:7b\nSYSTEM You are a helpful assistant.\nPARAMETER temperature 0.7"
}'
```

---

## Copy Model - 复制模型

复制模型到新名称。

**端点**: `POST /api/copy`

### 请求参数

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `source` | string | ✅ | 源模型名称 |
| `destination` | string | ✅ | 目标模型名称 |

### 示例

```bash
curl http://localhost:11434/api/copy -d '{
  "source": "qwen2.5:7b",
  "destination": "my-qwen:latest"
}'
```

---

## Delete Model - 删除模型

删除本地模型。

**端点**: `DELETE /api/delete`

### 请求参数

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `name` | string | ✅ | 模型名称 |

### 示例

```bash
curl -X DELETE http://localhost:11434/api/delete -d '{
  "name": "my-qwen:latest"
}'
```

---

## List Running Models - 运行中的模型

列出当前加载在内存中的模型。

**端点**: `GET /api/ps`

### 示例

```bash
curl http://localhost:11434/api/ps
```

### 响应

```json
{
  "models": [
    {
      "name": "qwen2.5:7b",
      "model": "qwen2.5:7b",
      "size": 4683087332,
      "digest": "sha256:...",
      "details": {
        "parent_model": "",
        "format": "gguf",
        "family": "qwen2",
        "parameter_size": "7.6B",
        "quantization_level": "Q4_K_M"
      },
      "expires_at": "2024-12-24T10:05:00.000000Z",
      "size_vram": 4683087332
    }
  ]
}
```

---

## Health Check - 健康检查

检查 Ollama 服务是否运行。

**端点**: `GET /`

### 示例

```bash
curl http://localhost:11434/
```

### 响应

```
Ollama is running
```

---

## 错误响应

当请求失败时，返回错误信息：

```json
{
  "error": "model 'unknown' not found"
}
```

常见 HTTP 状态码：

| 状态码 | 描述 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 404 | 模型或端点不存在 |
| 500 | 服务器内部错误 |

---

## 参考

- 官方文档：https://github.com/ollama/ollama/blob/main/docs/api.md
- Ollama 项目：https://github.com/ollama/ollama




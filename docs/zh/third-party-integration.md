# 第三方应用集成指南

本文档详细说明第三方应用如何利用 Local AI Starter 项目集成本地 AI 能力。

## 概述

Local AI Starter 提供了多种集成方式，适用于不同的技术栈和部署场景：

1. **Python 库直接集成** - 适用于 Python 项目
2. **REST API 服务调用** - 适用于任何语言的项目
3. **Docker 容器化部署** - 适用于微服务架构
4. **直接 Ollama API 调用** - 适用于简单场景

## 方式一：Python 库直接集成 (推荐)

### 适用场景
- 您的应用是 Python 项目
- 需要高性能的本地调用
- 希望使用封装好的客户端库

### 安装依赖

#### 使用 pip
```bash
# 从 Git 仓库安装
pip install git+https://github.com/your-repo/local-ai-starter.git

# 本地开发安装
pip install -e /path/to/local-ai-starter
```

#### 使用 Poetry
```bash
# 添加依赖
poetry add git+https://github.com/your-repo/local-ai-starter.git

# 本地开发
poetry add --editable /path/to/local-ai-starter
```

### 基础使用示例

```python
# your_app.py
from ollama_client import create_client, create_async_client

class YourAIService:
    def __init__(self):
        self.ai_client = create_client()
    
    def get_ai_response(self, user_input: str) -> str:
        """获取AI响应"""
        try:
            response = self.ai_client.generate(user_input)
            return response.get('response', '')
        except Exception as e:
            return f"AI服务暂时不可用: {e}"
    
    def chat_with_ai(self, conversation_history: list) -> str:
        """聊天对话"""
        response = self.ai_client.chat(conversation_history)
        return response.get('message', {}).get('content', '')

# 使用示例
ai_service = YourAIService()
answer = ai_service.get_ai_response("什么是机器学习？")
print(answer)
```

### 高级使用：聊天机器人集成

```python
# chatbot_example.py
from ollama_client import create_client
import logging

class ChatBot:
    def __init__(self):
        self.ai_client = create_client()
        self.conversation_history = []
    
    def process_user_message(self, user_input: str) -> str:
        """处理用户消息并返回AI响应"""
        try:
            # 添加到对话历史
            self.conversation_history.append({
                "role": "user", 
                "content": user_input
            })
            
            # 获取AI响应
            response = self.ai_client.chat(self.conversation_history)
            ai_message = response.get('message', {}).get('content', '')
            
            # 添加AI响应到历史
            self.conversation_history.append({
                "role": "assistant",
                "content": ai_message
            })
            
            return ai_message
            
        except Exception as e:
            logging.error(f"AI service error: {e}")
            return "抱歉，AI服务暂时不可用。"
    
    def reset_conversation(self):
        """重置对话历史"""
        self.conversation_history = []

# 使用示例
if __name__ == "__main__":
    bot = ChatBot()
    
    while True:
        user_input = input("您: ")
        if user_input.lower() in ['quit', 'exit', '退出']:
            break
        
        response = bot.process_user_message(user_input)
        print(f"AI: {response}")
```

### 异步使用示例

```python
# async_example.py
import asyncio
from ollama_client import create_async_client

async def batch_process_questions(questions: list):
    """批量处理问题"""
    async with create_async_client() as client:
        tasks = [client.generate(q) for q in questions]
        results = await asyncio.gather(*tasks)
        
        for question, result in zip(questions, results):
            print(f"Q: {question}")
            print(f"A: {result.get('response', 'No response')}")
            print("-" * 50)

# 使用
questions = [
    "什么是人工智能？",
    "机器学习的原理是什么？",
    "深度学习有哪些应用？"
]
asyncio.run(batch_process_questions(questions))
```

## 方式二：REST API 服务调用

### 适用场景
- 您的应用不是 Python 项目
- 需要跨语言集成
- 希望服务化部署

### 启动 API 服务器

```bash
# 确保安装了 FastAPI 依赖
poetry install --extras "api"

# 启动服务器
python api_server.py

# 或使用 Makefile
make dev-server
```

服务将运行在 `http://localhost:8000`，API 文档可访问 `http://localhost:8000/docs`。

### API 端点说明

#### 健康检查
```bash
GET /health
```

#### 获取模型列表
```bash
GET /models
```

#### 文本生成
```bash
POST /generate
Content-Type: application/json

{
  "prompt": "您的问题",
  "temperature": 0.7,
  "max_tokens": 2048
}
```

#### 聊天对话
```bash
POST /chat
Content-Type: application/json

{
  "messages": [
    {"role": "user", "content": "您的消息"}
  ],
  "temperature": 0.7
}
```

#### 流式生成
```bash
POST /generate/stream
Content-Type: application/json

{
  "prompt": "您的问题",
  "temperature": 0.7
}
```

### 不同语言的调用示例

#### JavaScript/Node.js
```javascript
// ai-service.js
const axios = require('axios');

class AIService {
    constructor(baseURL = 'http://localhost:8000') {
        this.client = axios.create({ baseURL });
    }
    
    async generateText(prompt, options = {}) {
        const response = await this.client.post('/generate', {
            prompt,
            temperature: options.temperature || 0.7,
            max_tokens: options.maxTokens || 2048
        });
        return response.data.response;
    }
    
    async chat(messages, options = {}) {
        const response = await this.client.post('/chat', {
            messages,
            temperature: options.temperature || 0.7
        });
        return response.data.message.content;
    }
    
    async checkHealth() {
        const response = await this.client.get('/health');
        return response.data;
    }
}

// 使用示例
const ai = new AIService();

async function main() {
    try {
        // 健康检查
        const health = await ai.checkHealth();
        console.log('Service status:', health.status);
        
        // 文本生成
        const answer = await ai.generateText("解释量子计算");
        console.log('Answer:', answer);
        
        // 聊天对话
        const chatResponse = await ai.chat([
            {role: "user", content: "你好，我是开发者"}
        ]);
        console.log('Chat response:', chatResponse);
        
    } catch (error) {
        console.error('Error:', error.message);
    }
}

main();
```

#### Python (不使用客户端库)
```python
# python_api_client.py
import requests
import json

class AIAPIClient:
    def __init__(self, base_url="http://localhost:8000"):
        self.base_url = base_url
        self.session = requests.Session()
    
    def generate_text(self, prompt, temperature=0.7, max_tokens=2048):
        """文本生成"""
        response = self.session.post(
            f"{self.base_url}/generate",
            json={
                "prompt": prompt,
                "temperature": temperature,
                "max_tokens": max_tokens
            }
        )
        response.raise_for_status()
        return response.json()["response"]
    
    def chat(self, messages, temperature=0.7):
        """聊天对话"""
        response = self.session.post(
            f"{self.base_url}/chat",
            json={
                "messages": messages,
                "temperature": temperature
            }
        )
        response.raise_for_status()
        return response.json()["message"]["content"]
    
    def health_check(self):
        """健康检查"""
        response = self.session.get(f"{self.base_url}/health")
        response.raise_for_status()
        return response.json()

# 使用示例
client = AIAPIClient()

# 检查服务状态
health = client.health_check()
print(f"服务状态: {health['status']}")

# 文本生成
answer = client.generate_text("什么是区块链技术？")
print(f"回答: {answer}")

# 聊天
chat_response = client.chat([
    {"role": "user", "content": "你能帮我写一个Python函数吗？"}
])
print(f"聊天回复: {chat_response}")
```

#### Java
```java
// AIService.java
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.URI;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;

public class AIService {
    private final HttpClient client;
    private final String baseUrl;
    private final ObjectMapper mapper;
    
    public AIService(String baseUrl) {
        this.client = HttpClient.newHttpClient();
        this.baseUrl = baseUrl;
        this.mapper = new ObjectMapper();
    }
    
    public String generateText(String prompt) throws Exception {
        String requestBody = String.format(
            "{\"prompt\": \"%s\", \"temperature\": 0.7}", 
            prompt.replace("\"", "\\\"")
        );
        
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(baseUrl + "/generate"))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(requestBody))
            .build();
            
        HttpResponse<String> response = client.send(request, 
            HttpResponse.BodyHandlers.ofString());
            
        if (response.statusCode() != 200) {
            throw new RuntimeException("API call failed: " + response.statusCode());
        }
        
        JsonNode jsonResponse = mapper.readTree(response.body());
        return jsonResponse.get("response").asText();
    }
    
    public boolean healthCheck() throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(baseUrl + "/health"))
            .GET()
            .build();
            
        HttpResponse<String> response = client.send(request, 
            HttpResponse.BodyHandlers.ofString());
            
        return response.statusCode() == 200;
    }
}

// 使用示例
public class Main {
    public static void main(String[] args) throws Exception {
        AIService ai = new AIService("http://localhost:8000");
        
        // 健康检查
        if (ai.healthCheck()) {
            System.out.println("AI service is healthy");
            
            // 生成文本
            String answer = ai.generateText("什么是机器学习？");
            System.out.println("Answer: " + answer);
        } else {
            System.out.println("AI service is not available");
        }
    }
}
```

#### cURL 命令行
```bash
# 健康检查
curl http://localhost:8000/health

# 文本生成
curl -X POST http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "什么是人工智能？",
    "temperature": 0.7,
    "max_tokens": 2048
  }'

# 聊天对话
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "你好，我是开发者"}
    ],
    "temperature": 0.7
  }'

# 流式生成
curl -X POST http://localhost:8000/generate/stream \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "讲一个关于AI的故事",
    "temperature": 0.7
  }'
```

## 方式三：Docker 容器化部署

### 适用场景
- 微服务架构
- 需要隔离的运行环境
- 云原生部署

### 使用 Docker Compose
```bash
# 构建和启动服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

### 使用单独的 Docker 容器
```bash
# 构建镜像
docker build -t local-ai-starter .

# 运行容器
docker run -d \
  --name local-ai \
  -p 8000:8000 \
  -p 11434:11434 \
  -e OLLAMA_MODEL=qwen:7b \
  local-ai-starter

# 检查容器状态
docker ps
docker logs local-ai
```

### Kubernetes 部署
```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: local-ai-service
  labels:
    app: local-ai
spec:
  replicas: 1
  selector:
    matchLabels:
      app: local-ai
  template:
    metadata:
      labels:
        app: local-ai
    spec:
      containers:
      - name: local-ai
        image: your-registry/local-ai-starter:latest
        ports:
        - containerPort: 8000
        env:
        - name: OLLAMA_MODEL
          value: "qwen:7b"
        - name: OLLAMA_TIMEOUT
          value: "60"
        resources:
          requests:
            memory: "4Gi"
            cpu: "1"
          limits:
            memory: "8Gi"
            cpu: "2"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: local-ai-service
spec:
  selector:
    app: local-ai
  ports:
  - name: api
    port: 8000
    targetPort: 8000
  - name: ollama
    port: 11434
    targetPort: 11434
  type: ClusterIP
```

## 方式四：直接 Ollama API 调用

### 适用场景
- 简单的集成需求
- 不需要额外的封装层
- 直接控制 API 调用

### 基本用法
```bash
# 直接调用 Ollama API
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen:7b",
    "prompt": "什么是人工智能？",
    "stream": false
  }'
```

详细的 Ollama API 使用方法请参考 `api_examples.py` 文件。

## 性能和优化建议

### 并发处理
- 合理设置并发限制（建议 2-5 个并发请求）
- 使用连接池减少连接开销
- 实现请求队列避免资源竞争

### 错误处理
```python
# 错误处理示例
import time
import logging
from typing import Optional

class RobustAIClient:
    def __init__(self, max_retries=3, retry_delay=1):
        self.client = create_client()
        self.max_retries = max_retries
        self.retry_delay = retry_delay
    
    def generate_with_retry(self, prompt: str) -> Optional[str]:
        """带重试的生成方法"""
        for attempt in range(self.max_retries):
            try:
                response = self.client.generate(prompt)
                return response.get('response')
            except Exception as e:
                logging.warning(f"Attempt {attempt + 1} failed: {e}")
                if attempt < self.max_retries - 1:
                    time.sleep(self.retry_delay * (attempt + 1))
                else:
                    logging.error(f"All {self.max_retries} attempts failed")
                    return None
```

### 缓存策略
```python
# 简单的缓存实现
import hashlib
import json
from functools import lru_cache

class CachedAIClient:
    def __init__(self):
        self.client = create_client()
        self._cache = {}
    
    def _get_cache_key(self, prompt: str, **kwargs) -> str:
        """生成缓存键"""
        content = {"prompt": prompt, **kwargs}
        return hashlib.md5(json.dumps(content, sort_keys=True).encode()).hexdigest()
    
    def generate_cached(self, prompt: str, **kwargs) -> str:
        """带缓存的生成方法"""
        cache_key = self._get_cache_key(prompt, **kwargs)
        
        if cache_key in self._cache:
            return self._cache[cache_key]
        
        response = self.client.generate(prompt, **kwargs)
        result = response.get('response', '')
        
        self._cache[cache_key] = result
        return result
```

### 监控和日志
```python
# 监控装饰器
import time
import logging
from functools import wraps

def monitor_ai_calls(func):
    """监控AI调用的装饰器"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            duration = time.time() - start_time
            logging.info(f"AI call succeeded in {duration:.2f}s")
            return result
        except Exception as e:
            duration = time.time() - start_time
            logging.error(f"AI call failed after {duration:.2f}s: {e}")
            raise
    return wrapper

class MonitoredAIClient:
    def __init__(self):
        self.client = create_client()
    
    @monitor_ai_calls
    def generate(self, prompt: str) -> str:
        response = self.client.generate(prompt)
        return response.get('response', '')
```

## 安全考虑

### API 安全
- 配置适当的 CORS 策略
- 实现 API 认证（JWT、API Key 等）
- 限制请求频率和大小
- 使用 HTTPS 传输

### 数据隐私
- 不在日志中记录敏感信息
- 实现数据脱敏处理
- 确保模型不会泄露训练数据

### 资源保护
- 设置合理的超时时间
- 限制并发请求数量
- 监控系统资源使用

## 常见问题

### Q: 如何选择合适的集成方式？
A: 
- **Python 项目**: 直接使用 `ollama_client` 库
- **其他语言项目**: 使用 REST API 服务
- **微服务架构**: 使用 Docker 容器化部署
- **简单测试**: 直接调用 Ollama API

### Q: 如何处理大量并发请求？
A: 
- 使用异步客户端 (`AsyncOllamaClient`)
- 实现请求队列和负载均衡
- 考虑部署多个实例

### Q: 如何优化响应时间？
A: 
- 使用缓存减少重复计算
- 优化提示词长度
- 考虑使用更小的模型
- 确保足够的硬件资源

### Q: 如何处理服务不可用的情况？
A: 
- 实现健康检查和自动重试
- 提供降级服务或默认响应
- 使用熔断器模式

### Q: 如何监控系统性能？
A: 
- 记录请求响应时间
- 监控错误率和成功率
- 跟踪资源使用情况
- 设置告警机制

## 总结

Local AI Starter 提供了灵活的集成选项，您可以根据自己的技术栈和需求选择最合适的方式：

1. **Python 库集成** - 最佳性能和易用性
2. **REST API 服务** - 跨语言支持
3. **Docker 部署** - 云原生和微服务架构
4. **直接 API 调用** - 简单直接的访问方式

无论选择哪种方式，都能快速为您的应用添加强大的本地 AI 能力。

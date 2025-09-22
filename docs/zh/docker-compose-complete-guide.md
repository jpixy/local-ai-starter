# Docker Compose 完整部署指南

本文档记录了 Ollama + Qwen 72B + Nginx 反向代理的完整 Docker Compose 部署过程。

## 目录
1. [方案概述](#方案概述)
2. [配置文件详解](#配置文件详解)
3. [部署步骤](#部署步骤)
4. [性能优化](#性能优化)
5. [故障排除](#故障排除)
6. [最佳实践](#最佳实践)

---

## 方案概述

### 架构设计
```
外部访问 → Nginx (80端口) → Ollama容器 (11434端口) → GPU推理
          ↓
    host模型目录挂载 (/usr/share/ollama/.ollama)
```

### 核心优势
- ✅ **模型复用**: 挂载host上已有模型，避免重复下载63GB数据
- ✅ **标准端口**: 通过80端口和域名访问 (10.176.202.207.nip.io)
- ✅ **GPU加速**: 容器内GPU支持，性能优异
- ✅ **高可用**: 容器自动重启，服务稳定
- ✅ **易管理**: 统一Docker Compose管理

---

## 配置文件详解

### 1. docker-compose-complete.yml

```yaml
# 完整的 Ollama + Qwen 72B + Nginx 反向代理 Docker Compose 配置
services:
  # Ollama 服务 - 使用官方镜像，支持GPU加速
  ollama:
    image: ollama/ollama:latest
    container_name: ollama-service
    ports:
      - "11434:11434"  # Ollama API端口（内部使用）
    environment:
      - OLLAMA_HOST=0.0.0.0
      - OLLAMA_PORT=11434
      # 性能优化配置
      - OLLAMA_MAX_LOADED_MODELS=1
      - OLLAMA_FLASH_ATTENTION=1
      - OLLAMA_NUM_PARALLEL=1
    volumes:
      # 关键：挂载host上已有的模型目录（避免重复下载63GB模型）
      - /usr/share/ollama/.ollama:/root/.ollama
      - ./scripts:/scripts
    restart: unless-stopped
    shm_size: '8gb'  # 增加共享内存支持大模型
    # GPU支持配置
    deploy:
      resources:
        limits:
          memory: 80G  # 为72B模型预留充足内存
        reservations:
          memory: 40G
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    # 简化启动命令（模型已存在）
    entrypoint: ["/bin/bash", "-c"]
    command: |
      "
      echo '🚀 启动 Ollama 服务（使用host上已有模型）...'
      ollama serve &
      sleep 10
      echo '📋 检查可用模型...'
      ollama list
      echo '✅ 服务就绪！使用host上的模型数据 (63GB)'
      wait
      "
    healthcheck:
      test: ["CMD", "ollama", "list"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s   # 模型已存在，快速启动

  # Nginx 反向代理服务
  nginx:
    image: nginx:alpine
    container_name: nginx-proxy
    ports:
      - "80:80"   # HTTP端口
      - "443:443" # HTTPS端口（预留）
    volumes:
      - ./nginx/ollama-docker.conf:/etc/nginx/conf.d/default.conf:ro
      - nginx_logs:/var/log/nginx
    depends_on:
      ollama:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s

volumes:
  nginx_logs:
    driver: local

networks:
  default:
    name: ollama-network
    driver: bridge
```

### 2. nginx/ollama-docker.conf

关键配置点：
- **upstream**: `server ollama:11434` (Docker容器间通信)
- **超时配置**: 适应72B模型的长推理时间
- **流式支持**: SSE和WebSocket支持
- **错误处理**: 优雅的错误页面

---

## 部署步骤

### 前置条件检查

```bash
# 1. 确认host上模型存在
sudo du -sh /usr/share/ollama/.ollama/
# 预期：63G	/usr/share/ollama/.ollama/

# 2. 检查GPU支持
nvidia-smi

# 3. 确认Docker运行
sudo docker info
```

### 一键部署

```bash
# 1. 停止可能冲突的host服务
sudo systemctl stop ollama nginx

# 2. 进入项目目录
cd /localhome/admink8s/Development/local-ai-starter

# 3. 启动完整服务栈
sudo docker compose -f docker-compose-complete.yml up -d

# 4. 检查服务状态
sudo docker compose -f docker-compose-complete.yml ps

# 5. 查看启动日志
sudo docker compose -f docker-compose-complete.yml logs -f
```

### 验证部署

```bash
# 使用测试脚本
./test-complete.sh

# 或手动测试
SERVER_IP=$(hostname -I | awk '{print $1}')
curl http://$SERVER_IP.nip.io/health
curl http://$SERVER_IP.nip.io/api/tags
```

---

## 性能优化

### 关键配置参数

1. **内存配置**
   ```yaml
   shm_size: '8gb'           # 共享内存
   memory: 80G               # 内存限制
   ```

2. **Ollama环境变量**
   ```yaml
   OLLAMA_MAX_LOADED_MODELS=1    # 限制同时加载模型数
   OLLAMA_FLASH_ATTENTION=1      # 启用Flash Attention
   OLLAMA_NUM_PARALLEL=1         # 并行推理数量
   ```

3. **Nginx超时配置**
   ```nginx
   proxy_send_timeout 600s;      # 10分钟发送超时
   proxy_read_timeout 600s;      # 10分钟读取超时
   ```

### 性能问题分析

#### 文本生成vs聊天API性能差异原因

从测试结果看：
- **文本生成API**: 190秒
- **聊天对话API**: 10秒

**可能原因分析**：

1. **模型冷启动**
   - 首次调用需要加载模型到GPU
   - 72B模型加载需要大量时间
   - 后续调用会利用缓存，速度更快

2. **prompt长度差异**
   - 不同的prompt复杂度影响推理时间
   - 生成长度设置不同

3. **内存管理**
   - 第一次推理时进行内存预分配
   - GPU显存分配和优化

#### 性能优化建议

```bash
# 1. 预热模型（减少冷启动时间）
curl -X POST http://10.176.202.207.nip.io/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "qwen2.5:72b", "prompt": "Hello", "stream": false}'

# 2. 使用流式响应（更好的用户体验）
curl -X POST http://10.176.202.207.nip.io/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "qwen2.5:72b", "prompt": "Hello", "stream": true}'

# 3. 限制生成长度
curl -X POST http://10.176.202.207.nip.io/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:72b", 
    "prompt": "Hello", 
    "options": {"num_predict": 100},
    "stream": false
  }'
```

---

## 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 检查端口占用
   sudo netstat -tlnp | grep :80
   sudo netstat -tlnp | grep :11434
   
   # 停止冲突服务
   sudo systemctl stop ollama nginx
   ```

2. **模型挂载失败**
   ```bash
   # 检查权限
   sudo ls -la /usr/share/ollama/.ollama/
   
   # 修复权限（如需要）
   sudo chown -R 1000:1000 /usr/share/ollama/.ollama/
   ```

3. **GPU不可用**
   ```bash
   # 检查NVIDIA Container Toolkit
   sudo docker run --rm --gpus all nvidia/cuda:12.1-base-ubuntu22.04 nvidia-smi
   ```

4. **Nginx配置错误**
   ```bash
   # 测试配置
   sudo docker exec nginx-proxy nginx -t
   
   # 重启nginx
   sudo docker compose -f docker-compose-complete.yml restart nginx
   ```

### 日志查看

```bash
# Ollama日志
sudo docker compose -f docker-compose-complete.yml logs ollama

# Nginx日志
sudo docker compose -f docker-compose-complete.yml logs nginx

# 实时日志
sudo docker compose -f docker-compose-complete.yml logs -f
```

---

## 最佳实践

### 1. 资源管理

```yaml
# 生产环境建议配置
deploy:
  resources:
    limits:
      memory: 64G      # 根据实际内存调整
      cpus: '24'       # 限制CPU使用
    reservations:
      memory: 32G
      devices:
        - driver: nvidia
          count: 1       # 指定GPU数量
          capabilities: [gpu]
```

### 2. 数据持久化

```yaml
volumes:
  # 模型数据持久化
  - /usr/share/ollama/.ollama:/root/.ollama:ro  # 只读挂载
  
  # 日志持久化
  - ./logs:/var/log/nginx
```

### 3. 安全配置

```nginx
# 限制访问
location /api/ {
    # IP白名单
    allow 192.168.0.0/16;
    allow 10.0.0.0/8;
    deny all;
    
    # 请求限制
    limit_req zone=api burst=10;
}
```

### 4. 监控和告警

```yaml
# 健康检查
healthcheck:
  test: ["CMD", "ollama", "list"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

---

## 性能基准

### 硬件配置
- **CPU**: 48核心
- **内存**: 251GB
- **GPU**: NVIDIA A100 (示例)
- **存储**: SSD

### 性能指标

| 指标 | Qwen 32B | Qwen 72B |
|------|----------|----------|
| 模型加载时间 | ~30秒 | ~60秒 |
| 首次推理 | ~30秒 | ~190秒 |
| 后续推理 | ~5-15秒 | ~10-30秒 |
| 内存使用 | ~20GB | ~45GB |
| GPU显存 | ~16GB | ~40GB |

### 优化建议

1. **首次访问优化**: 实现模型预热机制
2. **并发处理**: 根据硬件资源调整并发数
3. **缓存策略**: 实现智能缓存减少重复计算
4. **负载均衡**: 多GPU环境下的负载分配

---

## 部署清单

- ✅ Docker Compose配置文件
- ✅ Nginx反向代理配置  
- ✅ 启动脚本 (start-complete.sh)
- ✅ 测试脚本 (test-complete.sh)
- ✅ 性能监控和日志
- ✅ 健康检查和错误处理
- ✅ 文档和最佳实践

**总部署时间**: 5-10分钟（模型已存在）
**总存储需求**: ~63GB（模型）+ ~2GB（容器）
**访问地址**: http://10.176.202.207.nip.io

---

**文档版本**: v1.0  
**最后更新**: 2025-09-22  
**适用环境**: RHEL 9.6, Docker Compose v2.39+

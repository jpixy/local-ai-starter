#!/bin/bash

# 完整服务栈测试脚本
# 测试 Ollama + Qwen 72B + Nginx 反向代理

echo "🧪 测试 Ollama + Qwen 72B + Nginx 完整服务栈"
echo "============================================"

SERVER_IP=$(hostname -I | awk '{print $1}')
BASE_URL="http://$SERVER_IP.nip.io"

echo "📍 测试地址: $BASE_URL"
echo ""

# 测试1: 健康检查
echo "1️⃣ 测试 Nginx 代理健康检查..."
if curl -f -s "$BASE_URL/health" > /dev/null; then
    echo "✅ Nginx 代理正常"
    curl -s "$BASE_URL/health"
else
    echo "❌ Nginx 代理异常"
    exit 1
fi

echo ""

# 测试2: API文档页面
echo "2️⃣ 测试 API 文档页面..."
if curl -f -s "$BASE_URL/docs" > /dev/null; then
    echo "✅ API 文档页面可访问"
else
    echo "❌ API 文档页面异常"
fi

echo ""

# 测试3: 获取模型列表
echo "3️⃣ 测试模型列表 API..."
MODELS_RESPONSE=$(curl -s "$BASE_URL/api/tags")
if echo "$MODELS_RESPONSE" | jq . > /dev/null 2>&1; then
    echo "✅ 模型列表 API 正常"
    echo "📋 可用模型:"
    echo "$MODELS_RESPONSE" | jq -r '.models[].name' | while read model; do
        echo "   - $model"
    done
else
    echo "❌ 模型列表 API 异常"
    echo "响应: $MODELS_RESPONSE"
    exit 1
fi

echo ""

# 检查是否有72B模型
if echo "$MODELS_RESPONSE" | jq -r '.models[].name' | grep -q "qwen2.5:72b"; then
    echo "✅ Qwen 2.5 72B 模型已加载"
    TEST_MODEL="qwen2.5:72b"
elif echo "$MODELS_RESPONSE" | jq -r '.models[].name' | grep -q "qwen2.5:32b"; then
    echo "✅ Qwen 2.5 32B 模型已加载"
    TEST_MODEL="qwen2.5:32b"
else
    echo "❌ 未找到 Qwen 模型"
    exit 1
fi

echo ""

# 测试4: 文本生成
echo "4️⃣ 测试文本生成 API ($TEST_MODEL)..."
echo "📤 发送请求: '简单介绍一下Docker'"

GENERATE_START=$(date +%s)
GENERATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/generate" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"$TEST_MODEL\",
        \"prompt\": \"简单介绍一下Docker\",
        \"stream\": false
    }")

GENERATE_END=$(date +%s)
GENERATE_TIME=$((GENERATE_END - GENERATE_START))

if echo "$GENERATE_RESPONSE" | jq . > /dev/null 2>&1; then
    RESPONSE_TEXT=$(echo "$GENERATE_RESPONSE" | jq -r '.response' | head -c 200)
    echo "✅ 文本生成成功 (用时: ${GENERATE_TIME}秒)"
    echo "📝 响应内容: $RESPONSE_TEXT..."
else
    echo "❌ 文本生成失败"
    echo "响应: $GENERATE_RESPONSE"
fi

echo ""

# 测试5: 聊天对话
echo "5️⃣ 测试聊天对话 API ($TEST_MODEL)..."
echo "📤 发送聊天: '你好！'"

CHAT_START=$(date +%s)
CHAT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/chat" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"$TEST_MODEL\",
        \"messages\": [
            {\"role\": \"user\", \"content\": \"你好！请用一句话介绍你自己。\"}
        ],
        \"stream\": false
    }")

CHAT_END=$(date +%s)
CHAT_TIME=$((CHAT_END - CHAT_START))

if echo "$CHAT_RESPONSE" | jq . > /dev/null 2>&1; then
    CHAT_TEXT=$(echo "$CHAT_RESPONSE" | jq -r '.message.content' | head -c 200)
    echo "✅ 聊天对话成功 (用时: ${CHAT_TIME}秒)"
    echo "💬 AI回复: $CHAT_TEXT..."
else
    echo "❌ 聊天对话失败"
    echo "响应: $CHAT_RESPONSE"
fi

echo ""

# 性能总结
echo "📊 性能总结:"
echo "   文本生成耗时: ${GENERATE_TIME}秒"
echo "   聊天对话耗时: ${CHAT_TIME}秒"
echo "   使用模型: $TEST_MODEL"

echo ""

# 服务状态
echo "🐳 Docker 服务状态:"
docker compose -f docker-compose-complete.yml ps

echo ""
echo "✅ 所有测试完成！"
echo ""
echo "🔗 访问地址:"
echo "   主页: $BASE_URL"
echo "   API文档: $BASE_URL/docs"
echo "   健康检查: $BASE_URL/health"
echo ""
echo "📝 查看详细日志:"
echo "   docker compose -f docker-compose-complete.yml logs -f"

package com.bianjie.ai.api.modules.ai;

import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@ConditionalOnExpression("'${bianjie.ai.gateway.provider:}' == 'mock' || ('${bianjie.ai.gateway.provider:}' == '' && '${GLM_API_KEY:}' == '')")
public class MockAiGateway implements AiGateway {

    @Override
    public AiGatewayResponse complete(AiGatewayRequest request) {
        AiGatewayMessage latestUserMessage = request.messages()
                .stream()
                .filter(message -> "USER".equalsIgnoreCase(message.role()))
                .reduce((previous, current) -> current)
                .orElse(new AiGatewayMessage("USER", ""));
        String attachmentHint = request.attachments().isEmpty()
                ? "本轮没有附件。"
                : "检测到 " + request.attachments().size() + " 个附件，文件解析流程已预留。";
        String summaryHint = request.summary() == null || request.summary().isBlank()
                ? "当前会话暂未生成压缩摘要。"
                : "当前会话已有摘要，将在真实模型接入时参与上下文。";
        String content = "已收到你的问题：「" + latestUserMessage.content() + "」。当前使用 "
                + request.modelName() + " 通过 AI Gateway mock 生成回复。"
                + attachmentHint
                + summaryHint;
        return new AiGatewayResponse(
                content,
                Math.max(80, content.length() / 2),
                "MOCK_STOP",
                Map.of(
                        "provider", "mock",
                        "contextPolicy", request.contextPolicy(),
                        "messageCount", request.messages().size()
                )
        );
    }
}

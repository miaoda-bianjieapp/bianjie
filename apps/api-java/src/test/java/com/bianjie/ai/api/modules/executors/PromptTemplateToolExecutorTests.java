package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.ai.AiGateway;
import com.bianjie.ai.api.modules.ai.AiGatewayRequest;
import com.bianjie.ai.api.modules.ai.AiGatewayResponse;
import com.bianjie.ai.api.modules.tools.ToolDto;
import com.bianjie.ai.api.modules.tools.ToolExecutionType;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class PromptTemplateToolExecutorTests {

    @Test
    void rendersToolSpecificPromptAndFieldLabelsFromConfig() {
        CapturingGateway gateway = new CapturingGateway();
        PromptTemplateToolExecutor executor = new PromptTemplateToolExecutor(gateway);
        ToolDto tool = tool(Map.of(
                "executor", "llm-template",
                "systemPrompt", "你是小说创作助手",
                "taskPrompt", "创作一篇完整故事",
                "outputInstruction", "输出标题和正文",
                "fields", List.of(
                        Map.of("name", "genre", "label", "小说题材"),
                        Map.of("name", "relationship", "label", "人物关系")
                )
        ));

        ToolExecutionResult result = executor.run(new ToolExecutionContext(
                tool,
                "user-1",
                "大学校园里发现一封旧信",
                Map.of(
                        "genre", "悬疑",
                        "relationship", "两人是多年未见的同学",
                        "modelId", "glm-5v-turbo",
                        "modelName", "GLM-5V Turbo"
                ),
                List.of()
        ));

        assertThat(executor.supports(tool)).isTrue();
        assertThat(result.status()).isEqualTo("COMPLETED");
        assertThat(gateway.request.messages()).hasSize(2);
        assertThat(gateway.request.messages().get(0).role()).isEqualTo("SYSTEM");
        assertThat(gateway.request.messages().get(0).content()).isEqualTo("你是小说创作助手");
        assertThat(gateway.request.messages().get(1).content())
                .contains("创作一篇完整故事")
                .contains("大学校园里发现一封旧信")
                .contains("小说题材：悬疑")
                .contains("人物关系：两人是多年未见的同学")
                .contains("输出标题和正文")
                .doesNotContain("modelId");
    }

    private ToolDto tool(Map<String, Object> config) {
        return new ToolDto(
                "story-novel",
                "写故事小说",
                "根据参数创作故事",
                "writing",
                "writing",
                "document",
                List.of("小说"),
                "/tool/story-novel",
                true,
                1,
                false,
                false,
                ToolExecutionType.FORM,
                config
        );
    }

    private static class CapturingGateway implements AiGateway {
        private AiGatewayRequest request;

        @Override
        public AiGatewayResponse complete(AiGatewayRequest request) {
            this.request = request;
            return new AiGatewayResponse("生成结果", 120, "STOP", Map.of());
        }
    }
}

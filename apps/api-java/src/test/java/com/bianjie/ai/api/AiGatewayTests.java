package com.bianjie.ai.api;

import com.bianjie.ai.api.modules.ai.AiGatewayMessage;
import com.bianjie.ai.api.modules.ai.AiGatewayRequest;
import com.bianjie.ai.api.modules.ai.AiGatewayResponse;
import com.bianjie.ai.api.modules.ai.AiGatewayProperties;
import com.bianjie.ai.api.modules.ai.OpenAiCompatibleGateway;
import org.junit.jupiter.api.Test;
import org.springframework.web.client.RestClient;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class AiGatewayTests {

    @Test
    void openAiCompatibleGatewayReturnsSafeErrorWhenNotConfigured() {
        AiGatewayProperties properties = new AiGatewayProperties();
        properties.setProvider("openai-compatible");
        OpenAiCompatibleGateway gateway = new OpenAiCompatibleGateway(
                properties,
                RestClient.builder()
        );

        AiGatewayResponse response = gateway.complete(new AiGatewayRequest(
                "chat-test",
                "u-demo-001",
                "deepseek-r1",
                "DeepSeek-R1 联网满血版",
                "",
                "summary_plus_recent_messages",
                List.of(new AiGatewayMessage("USER", "你好")),
                List.of()
        ));

        assertThat(response.finishReason()).isEqualTo("GATEWAY_ERROR");
        assertThat(response.content()).contains("AI Gateway 暂不可用");
        assertThat(response.metadata()).containsEntry("provider", "openai-compatible");
    }

    @Test
    void propertiesTreatGlmConfigAsGlmProvider() {
        AiGatewayProperties properties = new AiGatewayProperties();
        properties.setApiKey("test-key");
        properties.setDefaultModel("glm-5v-turbo");

        assertThat(properties.effectiveProvider()).isEqualTo("glm");
        assertThat(properties.effectiveBaseUrl()).isEqualTo("https://open.bigmodel.cn/api/paas/v4");
        assertThat(properties.effectiveDefaultModel()).isEqualTo("glm-5v-turbo");
    }

    @Test
    void propertiesSelectConfiguredModelByRequestModelId() {
        AiGatewayProperties.ModelConfig glm = new AiGatewayProperties.ModelConfig();
        glm.setId("glm-5v-turbo");
        glm.setName("GLM-5V Turbo");
        glm.setProvider("glm");
        glm.setApiKey("glm-key");
        glm.setModel("glm-5v-turbo");
        glm.setDefaultModel(true);
        glm.setSortOrder(1);

        AiGatewayProperties.ModelConfig deepseek = new AiGatewayProperties.ModelConfig();
        deepseek.setId("deepseek-chat");
        deepseek.setName("DeepSeek Chat");
        deepseek.setProvider("openai-compatible");
        deepseek.setBaseUrl("https://api.deepseek.com/v1");
        deepseek.setApiKey("deepseek-key");
        deepseek.setModel("deepseek-chat");
        deepseek.setSortOrder(2);

        AiGatewayProperties properties = new AiGatewayProperties();
        properties.setDefaultModelId("glm-5v-turbo");
        properties.setModels(List.of(glm, deepseek));

        AiGatewayProperties.ModelConfig selected = properties.selectModel("deepseek-chat");
        AiGatewayProperties.ModelConfig fallback = properties.selectModel("unknown-model");

        assertThat(selected.getProvider()).isEqualTo("openai-compatible");
        assertThat(selected.getBaseUrl()).isEqualTo("https://api.deepseek.com/v1");
        assertThat(selected.getApiKey()).isEqualTo("deepseek-key");
        assertThat(selected.getModel()).isEqualTo("deepseek-chat");
        assertThat(fallback.getId()).isEqualTo("glm-5v-turbo");
        assertThat(fallback.getBaseUrl()).isEqualTo("https://open.bigmodel.cn/api/paas/v4");
    }
}

package com.bianjie.ai.api;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = {
                "bianjie.ai.gateway.provider=mock",
                "bianjie.catalog.admin-enabled=true"
        }
)
class ApiSmokeTests {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void healthEndpointReturnsOk() {
        ResponseEntity<Map> response = restTemplate.getForEntity(url("/api/v1/health"), Map.class);

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).containsEntry("success", true);
    }

    @Test
    @SuppressWarnings("unchecked")
    void aiGatewayStatusEndpointReturnsSafeConfigView() {
        ResponseEntity<Map> response = restTemplate.getForEntity(url("/api/v1/ai-gateway/status"), Map.class);

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).containsEntry("success", true);

        Map<String, Object> data = (Map<String, Object>) response.getBody().get("data");
        assertThat(data).containsEntry("provider", "mock");
        assertThat(data).containsEntry("ready", true);
        assertThat(data).containsEntry("apiKeyConfigured", false);
        assertThat(data).doesNotContainKey("apiKey");
    }

    @Test
    void toolsEndpointReturnsCatalog() {
        ResponseEntity<Map> response = restTemplate.getForEntity(url("/api/v1/tools"), Map.class);

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).containsEntry("success", true);
        assertThat(response.getBody()).containsKey("data");
    }

    @Test
    @SuppressWarnings("unchecked")
    void toolEndpointReturnsStructuredConfig() {
        ResponseEntity<Map> response = restTemplate.getForEntity(url("/api/v1/tools/pdf-convert"), Map.class);

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).containsEntry("success", true);

        Map<String, Object> data = (Map<String, Object>) response.getBody().get("data");
        Map<String, Object> config = (Map<String, Object>) data.get("config");

        assertThat(data).containsEntry("id", "pdf-convert");
        assertThat(config).containsKey("fields");
        assertThat(config.get("outputFormats")).asList().contains("docx", "png", "txt");
    }

    @Test
    @SuppressWarnings("unchecked")
    void toolRunEndpointCreatesAndReadsRun() {
        Map<String, Object> request = Map.of(
                "input", "帮我写一段产品介绍",
                "parameters", Map.of("tone", "clear")
        );

        ResponseEntity<Map> response = restTemplate.postForEntity(
                url("/api/v1/tools/write-article/runs"),
                request,
                Map.class
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).containsEntry("success", true);

        Map<String, Object> data = (Map<String, Object>) response.getBody().get("data");
        assertThat(data).containsEntry("toolId", "write-article");
        assertThat(data).containsKey("id");
        assertThat((Map<String, Object>) data.get("parameters")).containsEntry("tone", "clear");

        ResponseEntity<Map> getResponse = restTemplate.getForEntity(
                url("/api/v1/tool-runs/" + data.get("id")),
                Map.class
        );

        assertThat(getResponse.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(getResponse.getBody()).containsEntry("success", true);

        Map<String, Object> getData = (Map<String, Object>) getResponse.getBody().get("data");
        assertThat((Map<String, Object>) getData.get("parameters")).containsEntry("tone", "clear");
    }

    @Test
    @SuppressWarnings("unchecked")
    void pdfConvertRunReturnsToolSpecificQueuedResult() {
        Map<String, Object> request = Map.of(
                "input", "把这份 PDF 转成 Word",
                "parameters", Map.of(
                        "outputFormat", "docx",
                        "ocrEnabled", true
                ),
                "attachments", List.of(fileAttachment("source.pdf", "application/pdf"))
        );

        ResponseEntity<Map> response = restTemplate.postForEntity(
                url("/api/v1/tools/pdf-convert/runs"),
                request,
                Map.class
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).containsEntry("success", true);

        Map<String, Object> data = (Map<String, Object>) response.getBody().get("data");
        Map<String, Object> parameters = (Map<String, Object>) data.get("parameters");
        Map<String, Object> output = (Map<String, Object>) data.get("output");

        assertThat(data).containsEntry("status", "QUEUED");
        assertThat(parameters).containsEntry("outputFormat", "docx");
        assertThat(parameters).containsEntry("ocrEnabled", true);
        assertThat(output).containsEntry("targetFormat", "docx");
        assertThat(output).containsEntry("ocrEnabled", true);
        assertThat(output).containsEntry("sourceFileCount", 1);
    }

    @Test
    @SuppressWarnings("unchecked")
    void documentToPptRunReturnsToolSpecificQueuedResult() {
        Map<String, Object> request = Map.of(
                "input", "把文档整理成路演 PPT",
                "parameters", Map.of(
                        "slideCount", 12,
                        "style", "商务简洁",
                        "audience", "企业客户"
                ),
                "attachments", List.of(fileAttachment("brief.pdf", "application/pdf"))
        );

        ResponseEntity<Map> response = restTemplate.postForEntity(
                url("/api/v1/tools/document-to-ppt/runs"),
                request,
                Map.class
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).containsEntry("success", true);

        Map<String, Object> data = (Map<String, Object>) response.getBody().get("data");
        Map<String, Object> output = (Map<String, Object>) data.get("output");

        assertThat(data).containsEntry("status", "QUEUED");
        assertThat(output).containsEntry("slideCount", 12);
        assertThat(output).containsEntry("style", "商务简洁");
        assertThat(output).containsEntry("audience", "企业客户");
        assertThat(output).containsEntry("sourceFileCount", 1);
    }

    @Test
    @SuppressWarnings("unchecked")
    void localAdminEndpointPersistsDatabaseOwnedToolConfig() {
        Map<String, Object> request = new LinkedHashMap<>();
        request.put("name", "Logo 灵感");
        request.put("description", "由数据库维护的品牌标识方向工具。");
        request.put("categoryId", "design");
        request.put("tab", "tools");
        request.put("icon", "diamond");
        request.put("tags", List.of("设计"));
        request.put("route", "/tool/brand-logo");
        request.put("enabled", true);
        request.put("sortOrder", 7);
        request.put("requiresLogin", false);
        request.put("requiresVip", false);
        request.put("executionType", "PLACEHOLDER");
        request.put("config", Map.of("version", "tool-protocol-v2"));

        ResponseEntity<Map> response = restTemplate.exchange(
                url("/api/v1/admin/tools/brand-logo"),
                HttpMethod.PUT,
                new HttpEntity<>(request),
                Map.class
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).containsEntry("success", true);
        Map<String, Object> data = (Map<String, Object>) response.getBody().get("data");
        assertThat(data).containsEntry("description", "由数据库维护的品牌标识方向工具。");
        assertThat((Map<String, Object>) data.get("config")).containsEntry("version", "tool-protocol-v2");

        ResponseEntity<Map> getResponse = restTemplate.getForEntity(
                url("/api/v1/tools/brand-logo"),
                Map.class
        );
        Map<String, Object> stored = (Map<String, Object>) getResponse.getBody().get("data");
        assertThat(stored).containsEntry("description", "由数据库维护的品牌标识方向工具。");
    }

    @Test
    @SuppressWarnings("unchecked")
    void taskEndpointCreatesAndReadsQueuedTask() {
        Map<String, Object> request = Map.of(
                "type", "demo",
                "title", "生成 PPT 占位任务",
                "payload", Map.of("source", "smoke-test")
        );

        ResponseEntity<Map> response = restTemplate.postForEntity(
                url("/api/v1/tasks"),
                request,
                Map.class
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(response.getBody()).containsEntry("success", true);

        Map<String, Object> data = (Map<String, Object>) response.getBody().get("data");
        assertThat(data).containsEntry("status", "QUEUED");
        assertThat(data).containsKey("id");

        ResponseEntity<Map> getResponse = restTemplate.getForEntity(
                url("/api/v1/tasks/" + data.get("id")),
                Map.class
        );

        assertThat(getResponse.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(getResponse.getBody()).containsEntry("success", true);
    }

    @Test
    @SuppressWarnings("unchecked")
    void chatSessionCreatesImageMessageAndKeepsAttachmentShape() {
        ResponseEntity<Map> sessionResponse = restTemplate.postForEntity(
                url("/api/v1/chat/sessions"),
                Map.of(
                        "modelId", "deepseek-r1",
                        "modelName", "DeepSeek-R1 联网满血版",
                        "source", "smoke-test"
                ),
                Map.class
        );

        assertThat(sessionResponse.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(sessionResponse.getBody()).containsEntry("success", true);

        Map<String, Object> session = (Map<String, Object>) sessionResponse.getBody().get("data");
        String sessionId = session.get("id").toString();

        Map<String, Object> messageRequest = Map.of(
                "content", "请分析这张图片",
                "modelId", "deepseek-r1",
                "modelName", "DeepSeek-R1 联网满血版",
                "attachments", List.of(Map.of(
                        "id", "local-image",
                        "name", "demo.jpg",
                        "kind", "IMAGE",
                        "type", "image/jpeg",
                        "mimeType", "image/jpeg",
                        "size", 1024,
                        "status", "READY",
                        "base64Data", "dGVzdA=="
                )),
                "source", "smoke-test"
        );

        ResponseEntity<Map> turnResponse = restTemplate.postForEntity(
                url("/api/v1/chat/sessions/" + sessionId + "/messages"),
                messageRequest,
                Map.class
        );

        assertThat(turnResponse.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(turnResponse.getBody()).containsEntry("success", true);

        Map<String, Object> turn = (Map<String, Object>) turnResponse.getBody().get("data");
        Map<String, Object> userMessage = (Map<String, Object>) turn.get("userMessage");
        Map<String, Object> assistantMessage = (Map<String, Object>) turn.get("assistantMessage");

        assertThat(userMessage).containsEntry("role", "USER");
        assertThat(userMessage).containsEntry("messageType", "IMAGE_QUESTION");
        assertThat(assistantMessage).containsEntry("role", "ASSISTANT");
        assertThat(assistantMessage.get("content").toString()).contains("AI Gateway mock");
        List<Object> attachments = (List<Object>) userMessage.get("attachments");
        assertThat(attachments).hasSize(1);
        Map<String, Object> attachment = (Map<String, Object>) attachments.get(0);
        assertThat(attachment).containsEntry("kind", "IMAGE");
        assertThat(attachment).containsEntry("mimeType", "image/jpeg");
        assertThat(attachment).containsEntry("size", 1024);
        assertThat(attachment).containsEntry("base64Data", null);

        ResponseEntity<Map> messagesResponse = restTemplate.getForEntity(
                url("/api/v1/chat/sessions/" + sessionId + "/messages"),
                Map.class
        );
        assertThat(messagesResponse.getStatusCode().is2xxSuccessful()).isTrue();
        List<Object> storedMessages = (List<Object>) messagesResponse.getBody().get("data");
        assertThat(storedMessages).hasSize(2);
        Map<String, Object> storedUserMessage = (Map<String, Object>) storedMessages.get(0);
        Map<String, Object> storedAttachment =
                (Map<String, Object>) ((List<Object>) storedUserMessage.get("attachments")).get(0);
        assertThat(storedAttachment).containsEntry("base64Data", null);
    }

    private String url(String path) {
        return "http://localhost:" + port + path;
    }

    private Map<String, Object> fileAttachment(String name, String mimeType) {
        return Map.of(
                "id", "test-" + name,
                "name", name,
                "kind", "FILE",
                "type", mimeType,
                "mimeType", mimeType,
                "size", 1024,
                "status", "READY"
        );
    }
}

package com.bianjie.ai.api.modules.ai;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Component
@ConditionalOnExpression("'${bianjie.ai.gateway.provider:}' == 'openai-compatible' || '${bianjie.ai.gateway.provider:}' == 'glm' || ('${bianjie.ai.gateway.provider:}' == '' && '${GLM_API_KEY:}' != '')")
public class OpenAiCompatibleGateway implements AiGateway {

    private final AiGatewayProperties properties;
    private final RestClient restClient;

    public OpenAiCompatibleGateway(AiGatewayProperties properties, RestClient.Builder restClientBuilder) {
        this.properties = properties;
        this.restClient = restClientBuilder
                .requestFactory(requestFactory(properties.getTimeoutSeconds()))
                .build();
    }

    @Override
    public AiGatewayResponse complete(AiGatewayRequest request) {
        AiGatewayProperties.ModelConfig modelConfig = properties.selectModel(request.modelId());
        if (modelConfig.getBaseUrl() == null || modelConfig.getBaseUrl().isBlank()) {
            return errorResponse("AI Gateway base-url 未配置。", modelConfig);
        }
        if (modelConfig.getApiKey() == null || modelConfig.getApiKey().isBlank()) {
            return errorResponse("AI Gateway api-key 未配置。", modelConfig);
        }

        try {
            Map<String, Object> response = restClient.post()
                    .uri(chatCompletionsUrl(modelConfig))
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + modelConfig.getApiKey())
                    .contentType(MediaType.APPLICATION_JSON)
                    .accept(MediaType.APPLICATION_JSON)
                    .body(requestBody(request, modelConfig))
                    .retrieve()
                    .body(new ParameterizedTypeReference<>() {
                    });
            return parseResponse(response, modelConfig);
        } catch (RestClientException exception) {
            return errorResponse("AI Gateway 调用失败：" + exception.getMessage(), modelConfig);
        }
    }

    private Map<String, Object> requestBody(
            AiGatewayRequest request,
            AiGatewayProperties.ModelConfig modelConfig
    ) {
        Map<String, Object> body = new HashMap<>();
        body.put("model", modelName(request, modelConfig));
        body.put("messages", messages(request));
        body.put("temperature", 0.7);
        body.put("stream", false);
        return body;
    }

    private List<Map<String, Object>> messages(AiGatewayRequest request) {
        List<Map<String, Object>> messages = new ArrayList<>();
        messages.add(Map.of(
                "role", "system",
                "content", systemPrompt(request)
        ));
        List<AiGatewayMessage> requestMessages = request.messages();
        for (int index = 0; index < requestMessages.size(); index++) {
            AiGatewayMessage message = requestMessages.get(index);
            boolean latestUserMessage = index == requestMessages.size() - 1
                    && "USER".equalsIgnoreCase(message.role());
            messages.add(Map.of(
                    "role", normalizeRole(message.role()),
                    "content", latestUserMessage ? messageContent(message.content(), request.attachments()) : message.content()
            ));
        }
        return messages;
    }

    private Object messageContent(String content, List<AiGatewayAttachment> attachments) {
        List<AiGatewayAttachment> imageAttachments = attachments == null
                ? List.of()
                : attachments.stream()
                .filter(this::imageAttachment)
                .filter(attachment -> attachment.base64Data() != null && !attachment.base64Data().isBlank())
                .toList();
        if (imageAttachments.isEmpty()) {
            return content;
        }

        List<Map<String, Object>> parts = new ArrayList<>();
        parts.add(Map.of(
                "type", "text",
                "text", content
        ));
        for (AiGatewayAttachment attachment : imageAttachments) {
            String mimeType = attachment.mimeType() == null || attachment.mimeType().isBlank()
                    ? "image/jpeg"
                    : attachment.mimeType();
            parts.add(Map.of(
                    "type", "image_url",
                    "image_url", Map.of(
                            "url", "data:" + mimeType + ";base64," + attachment.base64Data()
                    )
            ));
        }
        return parts;
    }

    private boolean imageAttachment(AiGatewayAttachment attachment) {
        String kind = attachment.kind() == null ? "" : attachment.kind();
        String type = attachment.mimeType() == null || attachment.mimeType().isBlank()
                ? attachment.type()
                : attachment.mimeType();
        return "IMAGE".equalsIgnoreCase(kind) || (type != null && type.toLowerCase().startsWith("image/"));
    }

    private String systemPrompt(AiGatewayRequest request) {
        String summary = request.summary() == null || request.summary().isBlank()
                ? "暂无会话摘要。"
                : request.summary();
        String attachmentHint = request.attachments().isEmpty()
                ? "本轮没有附件。"
                : "本轮包含 " + request.attachments().size() + " 个附件占位，文件内容需要文件解析服务补充。";
        return "你是边界 AI App 的助手。上下文策略：" + request.contextPolicy()
                + "。会话摘要：" + summary
                + attachmentHint
                + "请用中文、简洁、可执行的方式回复。";
    }

    private AiGatewayResponse parseResponse(
            Map<String, Object> response,
            AiGatewayProperties.ModelConfig modelConfig
    ) {
        if (response == null) {
            return errorResponse("AI Gateway 返回为空。", modelConfig);
        }
        Object choicesValue = response.get("choices");
        if (!(choicesValue instanceof List<?> choices) || choices.isEmpty()) {
            return errorResponse("AI Gateway 返回缺少 choices。", modelConfig);
        }
        Object firstChoice = choices.get(0);
        if (!(firstChoice instanceof Map<?, ?> choice)) {
            return errorResponse("AI Gateway choice 格式异常。", modelConfig);
        }
        Object messageValue = choice.get("message");
        if (!(messageValue instanceof Map<?, ?> message)) {
            return errorResponse("AI Gateway message 格式异常。", modelConfig);
        }
        Object content = message.get("content");
        Object finishReason = choice.get("finish_reason");
        ParsedContent parsedContent = parseContent(content, message);
        return new AiGatewayResponse(
                parsedContent.text(),
                tokenEstimate(parsedContent.text()),
                finishReason == null ? "UNKNOWN" : finishReason.toString(),
                Map.of(
                        "provider", modelConfig.getProvider(),
                        "modelId", modelConfig.getId(),
                        "model", modelConfig.getModel(),
                        "artifactCount", parsedContent.artifacts().size()
                ),
                parsedContent.artifacts()
        );
    }

    private ParsedContent parseContent(Object content, Map<?, ?> message) {
        List<AiGatewayArtifact> artifacts = new ArrayList<>();
        StringBuilder text = new StringBuilder();
        if (content instanceof List<?> parts) {
            for (Object item : parts) {
                if (!(item instanceof Map<?, ?> part)) {
                    appendLine(text, item == null ? "" : item.toString());
                    continue;
                }
                String type = stringValue(part.get("type"));
                if ("text".equalsIgnoreCase(type)) {
                    appendLine(text, stringValue(part.get("text")));
                    continue;
                }
                AiGatewayArtifact artifact = artifactFromPart(type, part);
                if (artifact != null) {
                    artifacts.add(artifact);
                }
            }
        } else if (content != null) {
            text.append(content);
        }

        Object audio = message.get("audio");
        if (audio instanceof Map<?, ?> audioMap) {
            AiGatewayArtifact artifact = artifactFromPart("audio", audioMap);
            if (artifact != null) {
                artifacts.add(artifact);
            }
        }

        return new ParsedContent(text.toString().trim(), artifacts);
    }

    private AiGatewayArtifact artifactFromPart(String type, Map<?, ?> part) {
        String normalizedType = type == null ? "" : type.toLowerCase();
        if ("image_url".equals(normalizedType)) {
            Object imageUrlValue = part.get("image_url");
            String url = imageUrlValue instanceof Map<?, ?> imageUrl
                    ? stringValue(imageUrl.get("url"))
                    : stringValue(imageUrlValue);
            return artifact("IMAGE", "image", mimeTypeFromUrl(url, "image/png"), url, null);
        }
        if ("image".equals(normalizedType)) {
            String url = firstNonBlank(stringValue(part.get("url")), stringValue(part.get("image_url")));
            String data = firstNonBlank(stringValue(part.get("base64Data")), stringValue(part.get("data")));
            return artifact("IMAGE", "image", mimeTypeFromUrl(url, "image/png"), url, data);
        }
        if ("file".equals(normalizedType)) {
            Object fileValue = part.get("file");
            Map<?, ?> file = fileValue instanceof Map<?, ?> fileMap ? fileMap : part;
            String url = stringValue(file.get("url"));
            String name = firstNonBlank(stringValue(file.get("filename")), stringValue(file.get("name")), "模型输出文件");
            String mimeType = firstNonBlank(stringValue(file.get("mime_type")), stringValue(file.get("mimeType")), "application/octet-stream");
            String data = firstNonBlank(stringValue(file.get("base64Data")), stringValue(file.get("data")));
            return new AiGatewayArtifact(
                    "artifact-" + UUID.randomUUID(),
                    name,
                    "FILE",
                    mimeType,
                    mimeType,
                    data == null ? 0 : data.length(),
                    "GENERATED",
                    url,
                    data
            );
        }
        if ("audio".equals(normalizedType) || "video_url".equals(normalizedType) || "video".equals(normalizedType)) {
            String url = firstNonBlank(stringValue(part.get("url")), stringValue(part.get(normalizedType)));
            String data = firstNonBlank(stringValue(part.get("base64Data")), stringValue(part.get("data")));
            String kind = normalizedType.startsWith("video") ? "VIDEO" : "AUDIO";
            String mimeType = normalizedType.startsWith("video")
                    ? mimeTypeFromUrl(url, "video/mp4")
                    : mimeTypeFromUrl(url, "audio/mpeg");
            return artifact(kind, kind.toLowerCase(), mimeType, url, data);
        }
        return null;
    }

    private AiGatewayArtifact artifact(String kind, String namePrefix, String mimeType, String url, String base64Data) {
        if ((url == null || url.isBlank()) && (base64Data == null || base64Data.isBlank())) {
            return null;
        }
        String extension = extensionFromMimeType(mimeType);
        return new AiGatewayArtifact(
                "artifact-" + UUID.randomUUID(),
                namePrefix + "-" + System.currentTimeMillis() + extension,
                kind,
                mimeType,
                mimeType,
                base64Data == null ? 0 : base64Data.length(),
                "GENERATED",
                url,
                base64Data
        );
    }

    private void appendLine(StringBuilder text, String value) {
        if (value == null || value.isBlank()) {
            return;
        }
        if (!text.isEmpty()) {
            text.append("\n");
        }
        text.append(value);
    }

    private String stringValue(Object value) {
        return value == null ? null : value.toString();
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }

    private String mimeTypeFromUrl(String url, String fallback) {
        if (url == null) {
            return fallback;
        }
        String lower = url.toLowerCase();
        if (lower.startsWith("data:")) {
            int separator = lower.indexOf(';');
            return separator > 5 ? lower.substring(5, separator) : fallback;
        }
        if (lower.contains(".jpg") || lower.contains(".jpeg")) {
            return "image/jpeg";
        }
        if (lower.contains(".webp")) {
            return "image/webp";
        }
        if (lower.contains(".gif")) {
            return "image/gif";
        }
        if (lower.contains(".pdf")) {
            return "application/pdf";
        }
        return fallback;
    }

    private String extensionFromMimeType(String mimeType) {
        if (mimeType == null) {
            return "";
        }
        return switch (mimeType) {
            case "image/jpeg" -> ".jpg";
            case "image/png" -> ".png";
            case "image/webp" -> ".webp";
            case "image/gif" -> ".gif";
            case "audio/mpeg" -> ".mp3";
            case "video/mp4" -> ".mp4";
            case "application/pdf" -> ".pdf";
            default -> "";
        };
    }

    private AiGatewayResponse errorResponse(String message, AiGatewayProperties.ModelConfig modelConfig) {
        return new AiGatewayResponse(
                "当前 AI Gateway 暂不可用：" + message + " 已保存你的提问，可稍后重试。",
                80,
                "GATEWAY_ERROR",
                Map.of(
                        "provider", modelConfig.getProvider(),
                        "modelId", modelConfig.getId(),
                        "model", modelConfig.getModel(),
                        "error", message
                )
        );
    }

    private String chatCompletionsUrl(AiGatewayProperties.ModelConfig modelConfig) {
        String baseUrl = modelConfig.getBaseUrl();
        if (baseUrl.endsWith("/")) {
            baseUrl = baseUrl.substring(0, baseUrl.length() - 1);
        }
        return baseUrl + "/chat/completions";
    }

    private String modelName(AiGatewayRequest request, AiGatewayProperties.ModelConfig modelConfig) {
        if (modelConfig.getModel() != null && !modelConfig.getModel().isBlank()) {
            return modelConfig.getModel();
        }
        return request.modelId();
    }

    private String normalizeRole(String role) {
        if ("USER".equalsIgnoreCase(role)) {
            return "user";
        }
        if ("ASSISTANT".equalsIgnoreCase(role)) {
            return "assistant";
        }
        if ("SYSTEM".equalsIgnoreCase(role)) {
            return "system";
        }
        return "user";
    }

    private int tokenEstimate(String content) {
        return content == null ? 0 : Math.max(1, content.length() / 2);
    }

    private SimpleClientHttpRequestFactory requestFactory(int timeoutSeconds) {
        int normalizedTimeoutSeconds = Math.max(1, timeoutSeconds);
        Duration timeout = Duration.ofSeconds(normalizedTimeoutSeconds);
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(timeout);
        requestFactory.setReadTimeout(timeout);
        return requestFactory;
    }

    private record ParsedContent(
            String text,
            List<AiGatewayArtifact> artifacts
    ) {
    }
}

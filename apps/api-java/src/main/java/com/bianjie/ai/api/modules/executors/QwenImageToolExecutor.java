package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.ai.AiGatewayArtifact;
import com.bianjie.ai.api.modules.ai.AiGatewayAttachment;
import com.bianjie.ai.api.modules.ai.AiGatewayProperties;
import com.bianjie.ai.api.modules.tools.ToolDto;
import org.springframework.core.Ordered;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class QwenImageToolExecutor implements ToolExecutor {

    private static final String EXECUTOR_ID = "image-generation";
    private static final String LEGACY_TOOL_ID = "design-image";
    private static final String MODEL_ID = "qwen-image-2.0";
    private static final String GENERATION_PATH = "/services/aigc/multimodal-generation/generation";
    private static final String NEGATIVE_PROMPT = "unchanged original, identical composition, no visible redesign, "
            + "minor filter-only edit, blurry image, distorted text, duplicated elements, low contrast";

    private final AiGatewayProperties properties;
    private final RestClient.Builder restClientBuilder;

    public QwenImageToolExecutor(AiGatewayProperties properties, RestClient.Builder restClientBuilder) {
        this.properties = properties;
        this.restClientBuilder = restClientBuilder;
    }

    @Override
    public boolean supports(ToolDto tool) {
        return EXECUTOR_ID.equals(config(tool, "executor")) || LEGACY_TOOL_ID.equals(tool.id());
    }

    @Override
    public ToolExecutionResult run(ToolExecutionContext context) {
        AiGatewayProperties.ModelConfig model = properties.selectModel(MODEL_ID);
        if (blank(model.getBaseUrl()) || blank(model.getApiKey())) {
            return failed(
                    "Image model is not configured",
                    "Qwen Image 2.0 needs DASHSCOPE_BASE_URL and DASHSCOPE_API_KEY."
            );
        }

        try {
            GenerationResult generation = generateWithQualityGuard(context, model);
            List<AiGatewayArtifact> artifacts = generation.artifacts();
            if (artifacts.isEmpty()) {
                return ToolExecutionResult.failed(
                        "Image model returned no image",
                        Map.of(
                                "result", "DashScope completed, but no image URL or base64 image was found in the response.",
                                "model", modelName(model),
                                "artifacts", List.of()
                        )
                );
            }
            if (generation.tooSimilar()) {
                return ToolExecutionResult.failed(
                        "Generated image is too similar to the reference",
                        Map.of(
                                "result", "模型连续两次返回与参考图高度相似的图片，请补充需要调整的版式、配色或文案后重试。",
                                "model", modelName(model),
                                "attempts", generation.attempts(),
                                "artifacts", List.of()
                        )
                );
            }
            return ToolExecutionResult.completed(
                    "Design image generated",
                    Map.of(
                            "result", "Generated " + artifacts.size() + " design image(s).",
                            "model", modelName(model),
                            "attempts", generation.attempts(),
                            "sourceImageCount", imageAttachments(context).size(),
                            "artifacts", artifacts(artifacts)
                    )
            );
        } catch (RestClientResponseException exception) {
            return ToolExecutionResult.failed(
                    "Image model call failed",
                    Map.of(
                            "result", "DashScope returned " + exception.getStatusCode() + ": " + responseBody(exception),
                            "model", modelName(model),
                            "artifacts", List.of()
                    )
            );
        } catch (RestClientException exception) {
            return ToolExecutionResult.failed(
                    "Image model call failed",
                    Map.of(
                            "result", "DashScope request failed: " + exception.getMessage(),
                            "model", modelName(model),
                            "artifacts", List.of()
                    )
            );
        }
    }

    private GenerationResult generateWithQualityGuard(
            ToolExecutionContext context,
            AiGatewayProperties.ModelConfig model
    ) {
        List<AiGatewayAttachment> references = imageAttachments(context);
        List<AiGatewayArtifact> firstAttempt = callDashScope(context, model, false);
        if (references.isEmpty() || firstAttempt.isEmpty() || !matchesReference(references, firstAttempt, model)) {
            return new GenerationResult(firstAttempt, 1, false);
        }

        List<AiGatewayArtifact> secondAttempt = callDashScope(context, model, true);
        boolean stillTooSimilar = !secondAttempt.isEmpty() && matchesReference(references, secondAttempt, model);
        return new GenerationResult(secondAttempt, 2, stillTooSimilar);
    }

    private List<AiGatewayArtifact> callDashScope(
            ToolExecutionContext context,
            AiGatewayProperties.ModelConfig model,
            boolean forceRedesign
    ) {
        Map<String, Object> response = client(model).post()
                .uri(apiUrl(model, GENERATION_PATH))
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + model.getApiKey())
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .body(requestBody(context, model, forceRedesign))
                .retrieve()
                .body(new ParameterizedTypeReference<>() {
                });
        return parseArtifacts(response);
    }

    private Map<String, Object> requestBody(
            ToolExecutionContext context,
            AiGatewayProperties.ModelConfig model,
            boolean forceRedesign
    ) {
        return Map.of(
                "model", modelName(model),
                "input", Map.of(
                        "messages", List.of(Map.of(
                                "role", "user",
                                "content", messageContent(context, forceRedesign)
                        ))
                ),
                "parameters", Map.of(
                        "watermark", true,
                        "negative_prompt", NEGATIVE_PROMPT,
                        "n", 1
                )
        );
    }

    private List<Map<String, Object>> messageContent(ToolExecutionContext context, boolean forceRedesign) {
        List<Map<String, Object>> content = new ArrayList<>();
        for (AiGatewayAttachment attachment : imageAttachments(context)) {
            String image = imageDataUri(attachment);
            if (!blank(image)) {
                content.add(Map.of("image", image));
            }
        }
        content.add(Map.of("text", prompt(context, forceRedesign)));
        return content;
    }

    private List<AiGatewayAttachment> imageAttachments(ToolExecutionContext context) {
        if (context.attachments() == null || context.attachments().isEmpty()) {
            return List.of();
        }
        return context.attachments()
                .stream()
                .filter(attachment -> "IMAGE".equalsIgnoreCase(attachment.kind()))
                .filter(attachment -> !blank(attachment.base64Data()))
                .toList();
    }

    private String imageDataUri(AiGatewayAttachment image) {
        if (blank(image.base64Data())) {
            return null;
        }
        String mimeType = blank(image.mimeType()) ? "image/png" : image.mimeType();
        return "data:" + mimeType + ";base64," + image.base64Data();
    }

    private String prompt(ToolExecutionContext context, boolean forceRedesign) {
        String retryInstruction = forceRedesign
                ? "The previous result was too similar to the reference. This time make a clearly visible redesign."
                : "";
        return """
                Create a polished, production-ready design image for mobile, social media, or campaign usage.
                User request: %s
                Design style: %s
                Canvas size or aspect ratio: %s
                Requirements: keep the core subject recognizable, but visibly redesign the composition, hierarchy, palette, typography, lighting, and supporting visual elements. Follow the user's requested changes precisely. Do not return the reference image unchanged and do not merely apply a subtle filter. The output must be recognizably different at first glance while remaining usable as a finished design draft.
                %s
                """.formatted(
                blank(context.input()) ? "Create a high-quality design image." : context.input(),
                parameter(context, "style", "clean technology style"),
                parameter(context, "size", "1024x1024"),
                retryInstruction
        );
    }

    private String config(ToolDto tool, String name) {
        Object value = tool.config().get(name);
        return value == null ? "" : value.toString().trim();
    }

    private boolean matchesReference(
            List<AiGatewayAttachment> references,
            List<AiGatewayArtifact> artifacts,
            AiGatewayProperties.ModelConfig model
    ) {
        List<byte[]> referenceImages = references.stream()
                .map(AiGatewayAttachment::base64Data)
                .map(this::decodeBase64)
                .filter(bytes -> bytes != null && bytes.length > 0)
                .toList();
        if (referenceImages.isEmpty()) {
            return false;
        }
        for (AiGatewayArtifact artifact : artifacts) {
            byte[] output = artifactBytes(artifact, model);
            if (output == null) {
                continue;
            }
            for (byte[] reference : referenceImages) {
                if (ImageSimilarity.isNearlyIdentical(reference, output)) {
                    return true;
                }
            }
        }
        return false;
    }

    private byte[] artifactBytes(AiGatewayArtifact artifact, AiGatewayProperties.ModelConfig model) {
        byte[] inline = decodeBase64(artifact.base64Data());
        if (inline != null) {
            return inline;
        }
        if (blank(artifact.url())) {
            return null;
        }
        try {
            return client(model).get()
                    .uri(artifact.url())
                    .accept(MediaType.IMAGE_PNG, MediaType.IMAGE_JPEG)
                    .retrieve()
                    .body(byte[].class);
        } catch (RestClientException exception) {
            return null;
        }
    }

    private byte[] decodeBase64(String value) {
        if (blank(value)) {
            return null;
        }
        String normalized = value.trim();
        int commaIndex = normalized.indexOf(',');
        if (normalized.startsWith("data:") && commaIndex >= 0) {
            normalized = normalized.substring(commaIndex + 1);
        }
        try {
            return Base64.getDecoder().decode(normalized);
        } catch (IllegalArgumentException exception) {
            return null;
        }
    }

    private List<AiGatewayArtifact> parseArtifacts(Map<String, Object> response) {
        if (response == null || response.isEmpty()) {
            return List.of();
        }
        Set<String> seen = new LinkedHashSet<>();
        List<AiGatewayArtifact> artifacts = new ArrayList<>();
        collectArtifacts(response.get("output"), seen, artifacts);
        return artifacts;
    }

    private void collectArtifacts(Object value, Set<String> seen, List<AiGatewayArtifact> artifacts) {
        if (value instanceof Map<?, ?> map) {
            collectImageFromMap(map, seen, artifacts);
            for (Object child : map.values()) {
                collectArtifacts(child, seen, artifacts);
            }
            return;
        }
        if (value instanceof List<?> list) {
            for (Object item : list) {
                collectArtifacts(item, seen, artifacts);
            }
            return;
        }
        if (value instanceof String text) {
            addImageArtifact(text, null, seen, artifacts);
        }
    }

    private void collectImageFromMap(Map<?, ?> map, Set<String> seen, List<AiGatewayArtifact> artifacts) {
        String url = firstNonBlank(
                string(map.get("image")),
                string(map.get("url")),
                string(map.get("image_url")),
                string(map.get("result_url"))
        );
        String base64 = firstNonBlank(
                string(map.get("b64_json")),
                string(map.get("base64Data")),
                string(map.get("base64_data"))
        );
        addImageArtifact(url, base64, seen, artifacts);
    }

    private void addImageArtifact(
            String rawUrl,
            String rawBase64,
            Set<String> seen,
            List<AiGatewayArtifact> artifacts
    ) {
        String url = normalizeImageUrl(rawUrl);
        String base64 = normalizeBase64(rawBase64);
        if (blank(url) && blank(base64)) {
            return;
        }
        String key = !blank(url) ? url : base64.substring(0, Math.min(64, base64.length()));
        if (!seen.add(key)) {
            return;
        }
        artifacts.add(new AiGatewayArtifact(
                "artifact-" + UUID.randomUUID(),
                "design-image-" + System.currentTimeMillis() + ".png",
                "IMAGE",
                "image/png",
                "image/png",
                blank(base64) ? 0 : base64.length(),
                "GENERATED",
                url,
                base64
        ));
    }

    private String normalizeImageUrl(String value) {
        if (blank(value)) {
            return null;
        }
        String trimmed = value.trim();
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            return trimmed;
        }
        return null;
    }

    private String normalizeBase64(String value) {
        if (blank(value)) {
            return null;
        }
        String trimmed = value.trim();
        int commaIndex = trimmed.indexOf(',');
        if (trimmed.startsWith("data:image/") && commaIndex > 0) {
            return trimmed.substring(commaIndex + 1);
        }
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            return null;
        }
        return trimmed;
    }

    private List<Map<String, Object>> artifacts(List<AiGatewayArtifact> artifacts) {
        return artifacts.stream()
                .map(artifact -> Map.<String, Object>of(
                        "id", artifact.id(),
                        "name", artifact.name(),
                        "kind", artifact.kind(),
                        "type", artifact.type(),
                        "mimeType", artifact.mimeType(),
                        "size", artifact.size(),
                        "status", artifact.status(),
                        "url", artifact.url() == null ? "" : artifact.url(),
                        "base64Data", artifact.base64Data() == null ? "" : artifact.base64Data()
                ))
                .toList();
    }

    private ToolExecutionResult failed(String message, String result) {
        return ToolExecutionResult.failed(
                message,
                Map.of(
                        "result", result,
                        "model", MODEL_ID,
                        "artifacts", List.of()
                )
        );
    }

    private RestClient client(AiGatewayProperties.ModelConfig model) {
        int timeoutSeconds = model.getTimeoutSeconds() > 0
                ? model.getTimeoutSeconds()
                : properties.getTimeoutSeconds();
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        Duration timeout = Duration.ofSeconds(Math.max(1, timeoutSeconds));
        requestFactory.setConnectTimeout(timeout);
        requestFactory.setReadTimeout(timeout);
        return restClientBuilder.requestFactory(requestFactory).build();
    }

    private String apiUrl(AiGatewayProperties.ModelConfig model, String path) {
        String baseUrl = model.getBaseUrl();
        if (baseUrl.endsWith("/")) {
            baseUrl = baseUrl.substring(0, baseUrl.length() - 1);
        }
        return baseUrl + path;
    }

    private String modelName(AiGatewayProperties.ModelConfig model) {
        return blank(model.getModel()) ? MODEL_ID : model.getModel();
    }

    private String parameter(ToolExecutionContext context, String name, String fallback) {
        Object value = context.parameters() == null ? null : context.parameters().get(name);
        return value == null || value.toString().isBlank() ? fallback : value.toString();
    }

    private String responseBody(RestClientResponseException exception) {
        String body = exception.getResponseBodyAsString();
        return blank(body) ? exception.getMessage() : body;
    }

    private String string(Object value) {
        return value == null ? null : value.toString();
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (!blank(value)) {
                return value;
            }
        }
        return null;
    }

    private boolean blank(String value) {
        return value == null || value.isBlank();
    }

    private record GenerationResult(
            List<AiGatewayArtifact> artifacts,
            int attempts,
            boolean tooSimilar
    ) {
    }
}

package com.bianjie.ai.api.modules.ai;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

@Component
@ConfigurationProperties(prefix = "bianjie.ai.gateway")
public class AiGatewayProperties {

    private static final String GLM_BASE_URL = "https://open.bigmodel.cn/api/paas/v4";
    private static final String GLM_DEFAULT_MODEL = "glm-5v-turbo";

    private final Environment environment;

    private String provider = "mock";

    private String baseUrl = "";

    private String apiKey = "";

    private String defaultModel = "";

    private String defaultModelId = "";

    private int timeoutSeconds = 60;

    private List<ModelConfig> models = new ArrayList<>();

    public AiGatewayProperties() {
        this.environment = null;
    }

    public AiGatewayProperties(Environment environment) {
        this.environment = environment;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public void setBaseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public String getApiKey() {
        return apiKey;
    }

    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }

    public String getDefaultModel() {
        return defaultModel;
    }

    public void setDefaultModel(String defaultModel) {
        this.defaultModel = defaultModel;
    }

    public String getDefaultModelId() {
        return defaultModelId;
    }

    public void setDefaultModelId(String defaultModelId) {
        this.defaultModelId = defaultModelId;
    }

    public int getTimeoutSeconds() {
        return timeoutSeconds;
    }

    public void setTimeoutSeconds(int timeoutSeconds) {
        this.timeoutSeconds = timeoutSeconds;
    }

    public List<ModelConfig> getModels() {
        return models;
    }

    public void setModels(List<ModelConfig> models) {
        this.models = models == null ? new ArrayList<>() : models;
    }

    public boolean hasConfiguredModels() {
        return models != null && !models.isEmpty();
    }

    public List<ModelConfig> effectiveModels() {
        if (models != null && !models.isEmpty()) {
            return models.stream()
                    .map(this::normalizeModel)
                    .sorted(Comparator.comparingInt(ModelConfig::getSortOrder))
                    .toList();
        }
        return List.of(legacyModelConfig());
    }

    public ModelConfig selectModel(String requestedModelId) {
        List<ModelConfig> effectiveModels = effectiveModels();
        if (hasText(requestedModelId)) {
            Optional<ModelConfig> selected = effectiveModels.stream()
                    .filter(model -> requestedModelId.trim().equals(model.getId()))
                    .findFirst();
            if (selected.isPresent()) {
                return selected.get();
            }
        }
        if (hasText(defaultModelId)) {
            Optional<ModelConfig> selected = effectiveModels.stream()
                    .filter(model -> defaultModelId.trim().equals(model.getId()))
                    .findFirst();
            if (selected.isPresent()) {
                return selected.get();
            }
        }
        return effectiveModels.stream()
                .filter(ModelConfig::isDefaultModel)
                .findFirst()
                .orElse(effectiveModels.get(0));
    }

    public String effectiveProvider() {
        return selectModel(defaultModelId).getProvider();
    }

    public String effectiveBaseUrl() {
        return selectModel(defaultModelId).getBaseUrl();
    }

    public String effectiveApiKey() {
        return selectModel(defaultModelId).getApiKey();
    }

    public String effectiveDefaultModel() {
        return selectModel(defaultModelId).getModel();
    }

    public int effectiveTimeoutSeconds(String requestedModelId) {
        int modelTimeoutSeconds = selectModel(requestedModelId).getTimeoutSeconds();
        return modelTimeoutSeconds > 0 ? modelTimeoutSeconds : Math.max(1, timeoutSeconds);
    }

    private ModelConfig normalizeModel(ModelConfig source) {
        ModelConfig model = new ModelConfig();
        model.setId(normalize(source.getId(), source.getModel()));
        model.setName(normalize(source.getName(), model.getId()));
        model.setDescription(normalize(source.getDescription(), ""));
        model.setProvider(normalizeProvider(source.getProvider(), provider));
        model.setBaseUrl(resolveBaseUrl(model.getProvider(), source.getBaseUrl()));
        model.setApiKey(resolveApiKey(model.getProvider(), source.getApiKey(), false));
        model.setModel(resolveModelName(model.getProvider(), source.getModel(), false));
        model.setDefaultModel(source.isDefaultModel() || model.getId().equals(defaultModelId));
        model.setSortOrder(source.getSortOrder());
        model.setTimeoutSeconds(source.getTimeoutSeconds());
        return model;
    }

    private ModelConfig legacyModelConfig() {
        String legacyProvider = normalizeProvider(provider, "mock");
        if ("mock".equals(legacyProvider) && hasText(resolveApiKey(legacyProvider, apiKey, true)) && looksLikeGlm()) {
            legacyProvider = "glm";
        }
        String legacyModel = resolveModelName(legacyProvider, defaultModel, true);

        ModelConfig model = new ModelConfig();
        model.setId(hasText(legacyModel) ? legacyModel : legacyProvider);
        model.setName(hasText(legacyModel) ? legacyModel : legacyProvider);
        model.setDescription("");
        model.setProvider(legacyProvider);
        model.setBaseUrl(resolveBaseUrl(legacyProvider, baseUrl));
        model.setApiKey(resolveApiKey(legacyProvider, apiKey, true));
        model.setModel(legacyModel);
        model.setDefaultModel(true);
        model.setSortOrder(1);
        model.setTimeoutSeconds(timeoutSeconds);
        return model;
    }

    private String normalizeProvider(String value, String fallback) {
        String normalizedProvider = normalize(value, fallback);
        if ("glm".equals(normalizedProvider)) {
            return "glm";
        }
        return normalizedProvider;
    }

    private String resolveBaseUrl(String modelProvider, String value) {
        if (hasText(value)) {
            return value.trim();
        }
        if ("glm".equals(modelProvider)) {
            return env("GLM_BASE_URL", GLM_BASE_URL);
        }
        return "";
    }

    private String resolveApiKey(String modelProvider, String value, boolean allowLegacyEnv) {
        if (hasText(value)) {
            return value.trim();
        }
        if ("glm".equals(modelProvider) || allowLegacyEnv) {
            return env("GLM_API_KEY", "");
        }
        return "";
    }

    private String resolveModelName(String modelProvider, String value, boolean allowLegacyEnv) {
        if (hasText(value)) {
            return value.trim();
        }
        if ("glm".equals(modelProvider) || (allowLegacyEnv && hasText(env("GLM_API_KEY", "")))) {
            return env("GLM_MODEL", GLM_DEFAULT_MODEL);
        }
        return "";
    }

    private boolean looksLikeGlm() {
        String model = normalize(env("GLM_MODEL", defaultModel), "");
        String configuredBaseUrl = normalize(env("GLM_BASE_URL", baseUrl), "");
        return model.startsWith("glm") || configuredBaseUrl.contains("bigmodel.cn");
    }

    private String env(String key, String fallback) {
        if (environment == null) {
            return fallback;
        }
        return normalize(environment.getProperty(key), fallback);
    }

    private String normalize(String value, String fallback) {
        if (value == null || value.isBlank()) {
            return fallback;
        }
        return value.trim();
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }

    public static class ModelConfig {

        private String id = "";

        private String name = "";

        private String description = "";

        private String provider = "";

        private String baseUrl = "";

        private String apiKey = "";

        private String model = "";

        private boolean defaultModel;

        private int sortOrder = 100;

        private int timeoutSeconds;

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public String getProvider() {
            return provider;
        }

        public void setProvider(String provider) {
            this.provider = provider;
        }

        public String getBaseUrl() {
            return baseUrl;
        }

        public void setBaseUrl(String baseUrl) {
            this.baseUrl = baseUrl;
        }

        public String getApiKey() {
            return apiKey;
        }

        public void setApiKey(String apiKey) {
            this.apiKey = apiKey;
        }

        public String getModel() {
            return model;
        }

        public void setModel(String model) {
            this.model = model;
        }

        public boolean isDefaultModel() {
            return defaultModel;
        }

        public void setDefaultModel(boolean defaultModel) {
            this.defaultModel = defaultModel;
        }

        public int getSortOrder() {
            return sortOrder;
        }

        public void setSortOrder(int sortOrder) {
            this.sortOrder = sortOrder;
        }

        public int getTimeoutSeconds() {
            return timeoutSeconds;
        }

        public void setTimeoutSeconds(int timeoutSeconds) {
            this.timeoutSeconds = timeoutSeconds;
        }
    }
}

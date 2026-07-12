package com.bianjie.ai.api.modules.catalog;

import com.bianjie.ai.api.common.exception.ResourceNotFoundException;
import com.bianjie.ai.api.modules.ai.AiGatewayProperties;
import com.bianjie.ai.api.modules.agents.AgentTemplateDto;
import com.bianjie.ai.api.modules.agents.AgentTemplateRepository;
import com.bianjie.ai.api.modules.categories.ToolCategoryDto;
import com.bianjie.ai.api.modules.categories.ToolCategoryRepository;
import com.bianjie.ai.api.modules.membership.MembershipDto;
import com.bianjie.ai.api.modules.membership.MembershipRepository;
import com.bianjie.ai.api.modules.models.AiModelDto;
import com.bianjie.ai.api.modules.models.AiModelRepository;
import com.bianjie.ai.api.modules.prompts.PromptSuggestionDto;
import com.bianjie.ai.api.modules.prompts.PromptSuggestionRepository;
import com.bianjie.ai.api.modules.stock.StockCapabilityDto;
import com.bianjie.ai.api.modules.stock.StockCapabilityRepository;
import com.bianjie.ai.api.modules.stock.StockStatDto;
import com.bianjie.ai.api.modules.stock.StockStatRepository;
import com.bianjie.ai.api.modules.tools.ToolDto;
import com.bianjie.ai.api.modules.tools.ToolEntity;
import com.bianjie.ai.api.modules.tools.ToolRepository;
import com.bianjie.ai.api.modules.users.UserProfileDto;
import com.bianjie.ai.api.modules.users.UserProfileEntity;
import com.bianjie.ai.api.modules.users.UserProfileRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class CatalogService {

    private static final String DEMO_USER_ID = "u-demo-001";
    private static final String DEFAULT_MEMBERSHIP_ID = "default";

    private final ToolRepository toolRepository;
    private final ToolCategoryRepository categoryRepository;
    private final PromptSuggestionRepository promptRepository;
    private final AiModelRepository modelRepository;
    private final AgentTemplateRepository agentTemplateRepository;
    private final StockStatRepository stockStatRepository;
    private final StockCapabilityRepository stockCapabilityRepository;
    private final UserProfileRepository userProfileRepository;
    private final MembershipRepository membershipRepository;
    private final ObjectMapper objectMapper;
    private final AiGatewayProperties aiGatewayProperties;

    public CatalogService(
            ToolRepository toolRepository,
            ToolCategoryRepository categoryRepository,
            PromptSuggestionRepository promptRepository,
            AiModelRepository modelRepository,
            AgentTemplateRepository agentTemplateRepository,
            StockStatRepository stockStatRepository,
            StockCapabilityRepository stockCapabilityRepository,
            UserProfileRepository userProfileRepository,
            MembershipRepository membershipRepository,
            ObjectMapper objectMapper,
            AiGatewayProperties aiGatewayProperties
    ) {
        this.toolRepository = toolRepository;
        this.categoryRepository = categoryRepository;
        this.promptRepository = promptRepository;
        this.modelRepository = modelRepository;
        this.agentTemplateRepository = agentTemplateRepository;
        this.stockStatRepository = stockStatRepository;
        this.stockCapabilityRepository = stockCapabilityRepository;
        this.userProfileRepository = userProfileRepository;
        this.membershipRepository = membershipRepository;
        this.objectMapper = objectMapper;
        this.aiGatewayProperties = aiGatewayProperties;
    }

    public List<ToolDto> getTools() {
        return toolRepository.findAllByOrderBySortOrderAsc()
                .stream()
                .map(this::toToolDto)
                .toList();
    }

    public ToolDto getTool(String toolId) {
        return toolRepository.findById(toolId)
                .map(this::toToolDto)
                .orElseThrow(() -> new ResourceNotFoundException("Tool not found: " + toolId));
    }

    private ToolDto toToolDto(ToolEntity entity) {
        return entity.toDto(readJsonObject(entity.getConfigJson()));
    }

    private Map<String, Object> readJsonObject(String value) {
        try {
            if (value == null || value.isBlank()) {
                return Map.of();
            }
            return objectMapper.readValue(value, new TypeReference<>() {
            });
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Invalid tool config JSON", exception);
        }
    }

    public List<ToolCategoryDto> getCategories() {
        return categoryRepository.findAllByOrderBySortOrderAsc()
                .stream()
                .map(entity -> entity.toDto())
                .toList();
    }

    public List<PromptSuggestionDto> getPrompts(String scenario) {
        if (scenario == null || scenario.isBlank()) {
            return promptRepository.findAllByOrderBySortOrderAsc()
                    .stream()
                    .map(entity -> entity.toDto())
                    .toList();
        }

        return promptRepository.findByScenarioIgnoreCaseOrderBySortOrderAsc(scenario)
                .stream()
                .map(entity -> entity.toDto())
                .toList();
    }

    public List<AiModelDto> getModels() {
        if (aiGatewayProperties.hasConfiguredModels()) {
            return aiGatewayProperties.effectiveModels()
                    .stream()
                    .filter(model -> !"openai-compatible-image".equals(model.getProvider()))
                    .map(model -> new AiModelDto(
                            model.getId(),
                            model.getName(),
                            model.getDescription(),
                            model.isDefaultModel()
                    ))
                    .toList();
        }
        return modelRepository.findAllByOrderBySortOrderAsc()
                .stream()
                .map(entity -> entity.toDto())
                .toList();
    }

    public AiModelDto getDefaultModel() {
        if (aiGatewayProperties.hasConfiguredModels()) {
            AiGatewayProperties.ModelConfig model = aiGatewayProperties.selectModel(aiGatewayProperties.getDefaultModelId());
            return new AiModelDto(
                    model.getId(),
                    model.getName(),
                    model.getDescription(),
                    true
            );
        }
        return modelRepository.findFirstByDefaultModelTrueOrderBySortOrderAsc()
                .or(() -> modelRepository.findAllByOrderBySortOrderAsc().stream().findFirst())
                .map(entity -> entity.toDto())
                .orElseThrow(() -> new ResourceNotFoundException("Default model not configured"));
    }

    public List<AgentTemplateDto> getAgentTemplates() {
        return agentTemplateRepository.findAllByOrderBySortOrderAsc()
                .stream()
                .map(entity -> entity.toDto())
                .toList();
    }

    public AgentTemplateDto getAgentTemplate(String templateId) {
        return agentTemplateRepository.findById(templateId)
                .map(entity -> entity.toDto())
                .orElseThrow(() -> new ResourceNotFoundException("Agent template not found: " + templateId));
    }

    public List<StockStatDto> getStockStats() {
        return stockStatRepository.findAllByOrderBySortOrderAsc()
                .stream()
                .map(entity -> entity.toDto())
                .toList();
    }

    public List<StockCapabilityDto> getStockCapabilities() {
        return stockCapabilityRepository.findAllByOrderBySortOrderAsc()
                .stream()
                .map(entity -> entity.toDto())
                .toList();
    }

    public UserProfileDto getUser() {
        return userProfileRepository.findById(DEMO_USER_ID)
                .map(UserProfileEntity::toDto)
                .orElseThrow(() -> new ResourceNotFoundException("User profile not found: " + DEMO_USER_ID));
    }

    @Transactional
    public UserProfileDto checkIn() {
        UserProfileEntity user = userProfileRepository.findById(DEMO_USER_ID)
                .orElseThrow(() -> new ResourceNotFoundException("User profile not found: " + DEMO_USER_ID));
        user.checkIn();
        return userProfileRepository.save(user).toDto();
    }

    public MembershipDto getMembership() {
        return membershipRepository.findById(DEFAULT_MEMBERSHIP_ID)
                .map(entity -> entity.toDto())
                .orElseThrow(() -> new ResourceNotFoundException("Membership not found: " + DEFAULT_MEMBERSHIP_ID));
    }
}


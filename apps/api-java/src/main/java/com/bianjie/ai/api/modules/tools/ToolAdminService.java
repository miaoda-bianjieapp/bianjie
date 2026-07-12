package com.bianjie.ai.api.modules.tools;

import com.bianjie.ai.api.common.exception.ResourceNotFoundException;
import com.bianjie.ai.api.modules.catalog.CatalogService;
import com.bianjie.ai.api.modules.categories.ToolCategoryRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

@Service
public class ToolAdminService {

    private static final Pattern TOOL_ID_PATTERN = Pattern.compile("[a-z0-9][a-z0-9-]{1,63}");

    private final ToolRepository toolRepository;
    private final ToolCategoryRepository categoryRepository;
    private final ToolDefinitionValidator definitionValidator;
    private final CatalogService catalogService;
    private final ObjectMapper objectMapper;

    public ToolAdminService(
            ToolRepository toolRepository,
            ToolCategoryRepository categoryRepository,
            ToolDefinitionValidator definitionValidator,
            CatalogService catalogService,
            ObjectMapper objectMapper
    ) {
        this.toolRepository = toolRepository;
        this.categoryRepository = categoryRepository;
        this.definitionValidator = definitionValidator;
        this.catalogService = catalogService;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public ToolDto upsert(String toolId, UpsertToolRequest request) {
        validateToolId(toolId);
        if (!categoryRepository.existsById(request.categoryId())) {
            throw new IllegalArgumentException("工具分类不存在: " + request.categoryId());
        }
        Map<String, Object> config = Map.copyOf(request.config());
        List<String> tags = request.tags().stream()
                .map(String::trim)
                .filter(tag -> !tag.isBlank())
                .distinct()
                .toList();
        ToolDto candidate = new ToolDto(
                toolId,
                request.name().trim(),
                request.description().trim(),
                request.categoryId().trim(),
                request.tab().trim(),
                request.icon().trim(),
                tags,
                request.route().trim(),
                request.enabled(),
                request.sortOrder(),
                request.requiresLogin(),
                request.requiresVip(),
                request.executionType(),
                config
        );
        definitionValidator.validate(candidate);
        toolRepository.save(new ToolEntity(
                candidate.id(),
                candidate.name(),
                candidate.description(),
                candidate.categoryId(),
                candidate.tab(),
                candidate.icon(),
                candidate.tags(),
                candidate.route(),
                candidate.enabled(),
                candidate.sortOrder(),
                candidate.requiresLogin(),
                candidate.requiresVip(),
                candidate.executionType(),
                writeConfig(config)
        ));
        return catalogService.getTool(toolId);
    }

    @Transactional
    public ToolDto updateStatus(String toolId, boolean enabled) {
        ToolEntity tool = toolRepository.findById(toolId)
                .orElseThrow(() -> new ResourceNotFoundException("Tool not found: " + toolId));
        if (enabled) {
            ToolDto current = catalogService.getTool(toolId);
            definitionValidator.validate(new ToolDto(
                    current.id(), current.name(), current.description(), current.categoryId(), current.tab(),
                    current.icon(), current.tags(), current.route(), true, current.sortOrder(),
                    current.requiresLogin(), current.requiresVip(), current.executionType(), current.config()
            ));
        }
        tool.setEnabled(enabled);
        toolRepository.save(tool);
        return catalogService.getTool(toolId);
    }

    private void validateToolId(String toolId) {
        if (toolId == null || !TOOL_ID_PATTERN.matcher(toolId).matches()) {
            throw new IllegalArgumentException("toolId 只能包含小写字母、数字和连字符，长度为2到64位");
        }
    }

    private String writeConfig(Map<String, Object> config) {
        try {
            return objectMapper.writeValueAsString(config);
        } catch (JsonProcessingException exception) {
            throw new IllegalArgumentException("工具 config 不是有效 JSON", exception);
        }
    }
}

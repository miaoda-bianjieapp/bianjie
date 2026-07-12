package com.bianjie.ai.api.modules.toolruns;

import com.bianjie.ai.api.common.exception.ResourceNotFoundException;
import com.bianjie.ai.api.modules.ai.AiGatewayAttachment;
import com.bianjie.ai.api.modules.catalog.CatalogService;
import com.bianjie.ai.api.modules.chat.ChatAttachmentDto;
import com.bianjie.ai.api.modules.executors.ToolExecutionContext;
import com.bianjie.ai.api.modules.executors.ToolExecutionResult;
import com.bianjie.ai.api.modules.executors.ToolExecutor;
import com.bianjie.ai.api.modules.executors.ToolExecutorRegistry;
import com.bianjie.ai.api.modules.tools.ToolDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class ToolRunService {

    private final CatalogService catalogService;
    private final ToolExecutorRegistry executorRegistry;
    private final ToolRunRepository toolRunRepository;
    private final ToolProtocolValidator protocolValidator;
    private final ObjectMapper objectMapper;

    public ToolRunService(
            CatalogService catalogService,
            ToolExecutorRegistry executorRegistry,
            ToolRunRepository toolRunRepository,
            ToolProtocolValidator protocolValidator,
            ObjectMapper objectMapper
    ) {
        this.catalogService = catalogService;
        this.executorRegistry = executorRegistry;
        this.toolRunRepository = toolRunRepository;
        this.protocolValidator = protocolValidator;
        this.objectMapper = objectMapper;
    }

    public ToolRunDto createRun(String toolId, CreateToolRunRequest request) {
        ToolDto tool = catalogService.getTool(toolId);
        ToolExecutor executor = executorRegistry.resolve(tool);
        String input = request.input() == null ? "" : request.input().trim();
        Map<String, Object> parameters = request.parameters() == null ? Map.of() : request.parameters();
        List<ChatAttachmentDto> requestAttachments = request.attachments() == null ? List.of() : request.attachments();
        protocolValidator.validate(tool, input, parameters, requestAttachments);
        List<AiGatewayAttachment> attachments = request.attachments() == null
                ? List.of()
                : requestAttachments.stream().map(this::toGatewayAttachment).toList();
        ToolExecutionResult result = executor.run(new ToolExecutionContext(
                tool,
                "u-demo-001",
                input,
                parameters,
                attachments
        ));
        Instant now = Instant.now();
        ToolRunEntity run = new ToolRunEntity(
                "run-" + UUID.randomUUID(),
                toolId,
                result.status(),
                input,
                writeJson(parameters),
                writeJson(result.output()),
                now,
                now
        );
        return toDto(toolRunRepository.save(run));
    }

    public List<ToolRunDto> listRuns() {
        return toolRunRepository.findAllByOrderByUpdatedAtDesc()
                .stream()
                .map(this::toDto)
                .toList();
    }

    public ToolRunDto getRun(String runId) {
        return toolRunRepository.findById(runId)
                .map(this::toDto)
                .orElseThrow(() -> new ResourceNotFoundException("Tool run not found: " + runId));
    }

    private ToolRunDto toDto(ToolRunEntity entity) {
        return new ToolRunDto(
                entity.getId(),
                entity.getToolId(),
                entity.getStatus(),
                entity.getInput(),
                readJson(entity.getParametersJson()),
                readJson(entity.getOutputJson()),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }

    private String writeJson(Map<String, Object> value) {
        try {
            return objectMapper.writeValueAsString(value == null ? Map.of() : value);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Failed to serialize tool run JSON payload", exception);
        }
    }

    private Map<String, Object> readJson(String value) {
        try {
            if (value == null || value.isBlank()) {
                return Map.of();
            }
            return objectMapper.readValue(value, new TypeReference<>() {
            });
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Failed to deserialize tool run output", exception);
        }
    }

    private AiGatewayAttachment toGatewayAttachment(ChatAttachmentDto attachment) {
        return new AiGatewayAttachment(
                attachment.id(),
                attachment.name(),
                fallback(attachment.kind(), "FILE"),
                attachment.type(),
                fallback(attachment.mimeType(), attachment.type()),
                attachment.size(),
                attachment.status(),
                attachment.base64Data()
        );
    }

    private String fallback(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
    }
}


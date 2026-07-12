package com.bianjie.ai.api.modules.tasks;

import com.bianjie.ai.api.common.exception.ResourceNotFoundException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Service
public class TaskService {

    private final TaskRepository taskRepository;
    private final ObjectMapper objectMapper;

    public TaskService(TaskRepository taskRepository, ObjectMapper objectMapper) {
        this.taskRepository = taskRepository;
        this.objectMapper = objectMapper;
    }

    public TaskDto createTask(CreateTaskRequest request) {
        Instant now = Instant.now();
        TaskEntity task = new TaskEntity(
                "task-" + UUID.randomUUID(),
                request.type(),
                request.title(),
                "QUEUED",
                writeJson(request.payload()),
                now,
                now
        );
        return toDto(taskRepository.save(task));
    }

    public TaskDto getTask(String taskId) {
        return taskRepository.findById(taskId)
                .map(this::toDto)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found: " + taskId));
    }

    private TaskDto toDto(TaskEntity entity) {
        return new TaskDto(
                entity.getId(),
                entity.getType(),
                entity.getTitle(),
                entity.getStatus(),
                readJson(entity.getPayloadJson()),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }

    private String writeJson(Map<String, Object> value) {
        try {
            return objectMapper.writeValueAsString(value == null ? Map.of() : value);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Failed to serialize task payload", exception);
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
            throw new IllegalStateException("Failed to deserialize task payload", exception);
        }
    }
}


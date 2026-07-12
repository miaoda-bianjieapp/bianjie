package com.bianjie.ai.api.modules.tasks;

import com.bianjie.ai.api.common.response.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/tasks")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @PostMapping
    public ApiResponse<TaskDto> createTask(@Valid @RequestBody CreateTaskRequest request) {
        return ApiResponse.ok(taskService.createTask(request));
    }

    @GetMapping("/{taskId}")
    public ApiResponse<TaskDto> getTask(@PathVariable String taskId) {
        return ApiResponse.ok(taskService.getTask(taskId));
    }
}


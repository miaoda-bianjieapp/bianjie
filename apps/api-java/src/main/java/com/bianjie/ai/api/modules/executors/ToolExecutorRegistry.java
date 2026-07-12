package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.tools.ToolDto;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ToolExecutorRegistry {

    private final List<ToolExecutor> executors;

    public ToolExecutorRegistry(List<ToolExecutor> executors) {
        this.executors = executors;
    }

    public ToolExecutor resolve(ToolDto tool) {
        return executors.stream()
                .filter(executor -> executor.supports(tool))
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("No executor for tool: " + tool.id()));
    }
}


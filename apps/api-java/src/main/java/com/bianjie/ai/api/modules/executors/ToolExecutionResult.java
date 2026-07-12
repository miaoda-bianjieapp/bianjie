package com.bianjie.ai.api.modules.executors;

import java.util.Map;

public record ToolExecutionResult(
        String status,
        String message,
        Map<String, Object> output
) {
    public static ToolExecutionResult completed(String message, Map<String, Object> output) {
        return new ToolExecutionResult("COMPLETED", message, output);
    }

    public static ToolExecutionResult queued(String message, Map<String, Object> output) {
        return new ToolExecutionResult("QUEUED", message, output);
    }

    public static ToolExecutionResult running(String message, Map<String, Object> output) {
        return new ToolExecutionResult("RUNNING", message, output);
    }

    public static ToolExecutionResult failed(String message, Map<String, Object> output) {
        return new ToolExecutionResult("FAILED", message, output);
    }

    public static ToolExecutionResult cancelled(String message, Map<String, Object> output) {
        return new ToolExecutionResult("CANCELLED", message, output);
    }
}


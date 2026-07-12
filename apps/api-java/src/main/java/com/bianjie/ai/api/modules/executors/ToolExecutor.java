package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.tools.ToolDto;

public interface ToolExecutor {

    boolean supports(ToolDto tool);

    ToolExecutionResult run(ToolExecutionContext context);
}


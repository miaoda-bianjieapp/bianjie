package com.bianjie.ai.api.modules.toolruns;

import com.bianjie.ai.api.modules.chat.ChatAttachmentDto;
import com.bianjie.ai.api.modules.tools.ToolDto;
import com.bianjie.ai.api.modules.tools.ToolExecutionType;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ToolProtocolValidatorTests {

    private final ToolProtocolValidator validator = new ToolProtocolValidator();

    @Test
    void validatesRequiredFileTypeAndSizeFromToolConfig() {
        ToolDto tool = tool(Map.of(
                "inputModes", List.of("file"),
                "acceptedFileTypes", List.of("pdf"),
                "minFiles", 1,
                "maxFiles", 1,
                "maxFileSizeMb", 30
        ));

        assertThatThrownBy(() -> validator.validate(tool, "", Map.of(), List.of()))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("请至少上传1个文件");

        assertThatThrownBy(() -> validator.validate(tool, "", Map.of(), List.of(attachment("notes.txt", 10))))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("文件格式不受支持");
    }

    @Test
    void validatesDynamicFieldOptionsAndRange() {
        ToolDto tool = tool(Map.of(
                "inputRequired", false,
                "fields", List.of(
                        Map.of(
                                "name", "language",
                                "label", "输出语言",
                                "type", "segmented",
                                "options", List.of("中文", "English")
                        ),
                        Map.of(
                                "name", "slideCount",
                                "label", "页数",
                                "type", "slider",
                                "min", 10,
                                "max", 50
                        )
                )
        ));

        assertThatThrownBy(() -> validator.validate(
                tool,
                "",
                Map.of("language", "德语", "slideCount", 60),
                List.of()
        )).isInstanceOf(IllegalArgumentException.class).hasMessage("输出语言包含不支持的选项");

        assertThatThrownBy(() -> validator.validate(
                tool,
                "",
                Map.of("language", "中文", "slideCount", 60),
                List.of()
        )).isInstanceOf(IllegalArgumentException.class).hasMessage("页数不能大于50");
    }

    private ChatAttachmentDto attachment(String name, long size) {
        return new ChatAttachmentDto(
                "file-1", name, "FILE", "application/octet-stream", "application/octet-stream",
                size, "READY", null, null
        );
    }

    private ToolDto tool(Map<String, Object> config) {
        return new ToolDto(
                "test-tool", "测试工具", "", "test", "tools", "file", List.of(), "/tool/test-tool",
                true, 1, false, false, ToolExecutionType.TASK, config
        );
    }
}

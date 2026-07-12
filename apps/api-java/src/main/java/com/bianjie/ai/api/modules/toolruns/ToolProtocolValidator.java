package com.bianjie.ai.api.modules.toolruns;

import com.bianjie.ai.api.modules.chat.ChatAttachmentDto;
import com.bianjie.ai.api.modules.tools.ToolDto;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Component
public class ToolProtocolValidator {

    public void validate(
            ToolDto tool,
            String input,
            Map<String, Object> parameters,
            List<ChatAttachmentDto> attachments
    ) {
        Map<String, Object> config = tool.config() == null ? Map.of() : tool.config();
        validateInput(config, input);
        validateFields(config, parameters == null ? Map.of() : parameters);
        validateAttachments(config, attachments == null ? List.of() : attachments);
    }

    private void validateInput(Map<String, Object> config, String input) {
        Map<String, Object> primaryInput = map(config.get("primaryInput"));
        boolean required = booleanValue(
                config.get("inputRequired"),
                booleanValue(primaryInput.get("required"), defaultTextRequired(config))
        );
        String value = input == null ? "" : input.trim();
        String label = stringValue(primaryInput.get("label"), "需求或素材");
        if (required && value.isBlank()) {
            throw new IllegalArgumentException("请填写" + label);
        }
        Integer maxLength = integerValue(primaryInput.get("maxLength"));
        if (maxLength != null && value.length() > maxLength) {
            throw new IllegalArgumentException(label + "不能超过" + maxLength + "字");
        }
    }

    private boolean defaultTextRequired(Map<String, Object> config) {
        List<String> modes = normalizedStringList(config.get("inputModes"));
        return modes.contains("text") && !modes.contains("file") && !modes.contains("image");
    }

    private void validateFields(Map<String, Object> config, Map<String, Object> parameters) {
        for (Object item : list(config.get("fields"))) {
            Map<String, Object> field = map(item);
            String name = stringValue(field.get("name"), "");
            if (name.isBlank()) {
                continue;
            }
            String label = stringValue(field.get("label"), name);
            String type = stringValue(field.get("type"), "text").toLowerCase(Locale.ROOT);
            Object value = parameters.get(name);
            if (booleanValue(field.get("required"), false) && isBlank(value)) {
                throw new IllegalArgumentException("请填写" + label);
            }
            if (isBlank(value)) {
                continue;
            }
            validateFieldValue(field, type, label, value);
        }
    }

    private void validateFieldValue(Map<String, Object> field, String type, String label, Object value) {
        if ("number".equals(type) || "slider".equals(type)) {
            double number;
            try {
                number = value instanceof Number numeric ? numeric.doubleValue() : Double.parseDouble(value.toString());
            } catch (NumberFormatException exception) {
                throw new IllegalArgumentException(label + "必须是数字");
            }
            Double min = doubleValue(field.get("min"));
            Double max = doubleValue(field.get("max"));
            if (min != null && number < min) {
                throw new IllegalArgumentException(label + "不能小于" + formatNumber(min));
            }
            if (max != null && number > max) {
                throw new IllegalArgumentException(label + "不能大于" + formatNumber(max));
            }
        }

        List<String> options = stringList(field.get("options"));
        if (!options.isEmpty() && ("select".equals(type) || "chips".equals(type) || "segmented".equals(type))) {
            Collection<?> values = value instanceof Collection<?> collection ? collection : List.of(value);
            boolean invalid = values.stream().map(Object::toString).anyMatch(item -> !options.contains(item));
            if (invalid) {
                throw new IllegalArgumentException(label + "包含不支持的选项");
            }
        }

        Integer maxLength = integerValue(field.get("maxLength"));
        if (maxLength != null && value.toString().length() > maxLength) {
            throw new IllegalArgumentException(label + "不能超过" + maxLength + "字");
        }
    }

    private void validateAttachments(Map<String, Object> config, List<ChatAttachmentDto> attachments) {
        int minFiles = integerValue(config.get("minFiles"), 0);
        int maxFiles = integerValue(config.get("maxFiles"), Integer.MAX_VALUE);
        if (attachments.size() < minFiles) {
            throw new IllegalArgumentException("请至少上传" + minFiles + "个文件");
        }
        if (attachments.size() > maxFiles) {
            throw new IllegalArgumentException("最多只能上传" + maxFiles + "个文件");
        }

        List<String> acceptedTypes = normalizedStringList(config.get("acceptedFileTypes"));
        long maxBytes = (long) (doubleValue(config.get("maxFileSizeMb"), Double.MAX_VALUE) * 1024 * 1024);
        for (ChatAttachmentDto attachment : attachments) {
            if (attachment == null) {
                throw new IllegalArgumentException("附件数据不能为空");
            }
            if (attachment.size() < 0 || attachment.size() > maxBytes) {
                throw new IllegalArgumentException(attachment.name() + "超过文件大小限制");
            }
            if (!acceptedTypes.isEmpty() && !acceptedTypes.contains(extension(attachment.name()))) {
                throw new IllegalArgumentException(attachment.name() + "的文件格式不受支持");
            }
        }
    }

    private String extension(String name) {
        if (name == null) {
            return "";
        }
        int index = name.lastIndexOf('.');
        return index < 0 ? "" : name.substring(index + 1).toLowerCase(Locale.ROOT);
    }

    private boolean isBlank(Object value) {
        if (value == null) {
            return true;
        }
        if (value instanceof String text) {
            return text.isBlank();
        }
        return value instanceof Collection<?> collection && collection.isEmpty();
    }

    private Map<String, Object> map(Object value) {
        if (!(value instanceof Map<?, ?> source)) {
            return Map.of();
        }
        return source.entrySet().stream().collect(java.util.stream.Collectors.toMap(
                entry -> entry.getKey().toString(),
                Map.Entry::getValue,
                (left, right) -> right,
                java.util.LinkedHashMap::new
        ));
    }

    private List<?> list(Object value) {
        return value instanceof List<?> values ? values : List.of();
    }

    private List<String> stringList(Object value) {
        return list(value).stream()
                .map(Object::toString)
                .map(String::trim)
                .toList();
    }

    private List<String> normalizedStringList(Object value) {
        return stringList(value).stream().map(item -> item.toLowerCase(Locale.ROOT)).toList();
    }

    private String stringValue(Object value, String fallback) {
        return value == null || value.toString().isBlank() ? fallback : value.toString().trim();
    }

    private boolean booleanValue(Object value, boolean fallback) {
        return value == null ? fallback : value instanceof Boolean bool ? bool : Boolean.parseBoolean(value.toString());
    }

    private Integer integerValue(Object value) {
        return value == null ? null : value instanceof Number number
                ? number.intValue()
                : Integer.parseInt(value.toString());
    }

    private int integerValue(Object value, int fallback) {
        Integer result = integerValue(value);
        return result == null ? fallback : result;
    }

    private Double doubleValue(Object value) {
        return value == null ? null : value instanceof Number number
                ? number.doubleValue()
                : Double.parseDouble(value.toString());
    }

    private double doubleValue(Object value, double fallback) {
        Double result = doubleValue(value);
        return result == null ? fallback : result;
    }

    private String formatNumber(double value) {
        return value == Math.rint(value) ? Long.toString((long) value) : Double.toString(value);
    }
}

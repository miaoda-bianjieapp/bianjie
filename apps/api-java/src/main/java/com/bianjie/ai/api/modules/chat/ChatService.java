package com.bianjie.ai.api.modules.chat;

import com.bianjie.ai.api.common.exception.ResourceNotFoundException;
import com.bianjie.ai.api.modules.ai.AiGateway;
import com.bianjie.ai.api.modules.ai.AiGatewayArtifact;
import com.bianjie.ai.api.modules.ai.AiGatewayAttachment;
import com.bianjie.ai.api.modules.ai.AiGatewayMessage;
import com.bianjie.ai.api.modules.ai.AiGatewayRequest;
import com.bianjie.ai.api.modules.ai.AiGatewayResponse;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class ChatService {

    private static final String DEMO_USER_ID = "u-demo-001";
    private static final String DEFAULT_MODEL_ID = "glm-5v-turbo";
    private static final String DEFAULT_MODEL_NAME = "GLM-5V Turbo";
    private static final String CONTEXT_POLICY = "summary_plus_recent_messages";
    private static final int COMPRESSION_MESSAGE_THRESHOLD = 20;
    private static final int COMPRESSION_TOKEN_THRESHOLD = 6000;

    private final ChatSessionRepository sessionRepository;
    private final ChatMessageRepository messageRepository;
    private final ObjectMapper objectMapper;
    private final AiGateway aiGateway;

    public ChatService(
            ChatSessionRepository sessionRepository,
            ChatMessageRepository messageRepository,
            ObjectMapper objectMapper,
            AiGateway aiGateway
    ) {
        this.sessionRepository = sessionRepository;
        this.messageRepository = messageRepository;
        this.objectMapper = objectMapper;
        this.aiGateway = aiGateway;
    }

    public List<ChatSessionDto> listSessions() {
        return sessionRepository.findAllByOrderByUpdatedAtDesc()
                .stream()
                .map(ChatSessionEntity::toDto)
                .toList();
    }

    @Transactional
    public ChatSessionDto createSession(CreateChatSessionRequest request) {
        Instant now = Instant.now();
        ChatSessionEntity session = new ChatSessionEntity(
                "chat-" + UUID.randomUUID(),
                DEMO_USER_ID,
                "新的对话",
                fallback(request.modelId(), DEFAULT_MODEL_ID),
                fallback(request.modelName(), DEFAULT_MODEL_NAME),
                "",
                CONTEXT_POLICY,
                0,
                false,
                now,
                now
        );
        return sessionRepository.save(session).toDto();
    }

    public List<ChatMessageDto> getMessages(String sessionId) {
        if (!sessionRepository.existsById(sessionId)) {
            throw new ResourceNotFoundException("Chat session not found: " + sessionId);
        }
        return messageRepository.findBySessionIdOrderByCreatedAtAsc(sessionId)
                .stream()
                .map(this::toDto)
                .toList();
    }

    @Transactional
    public ChatTurnDto sendMessage(String sessionId, SendChatMessageRequest request) {
        ChatSessionEntity session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Chat session not found: " + sessionId));
        Instant now = Instant.now();
        List<ChatAttachmentDto> attachments = request.attachments() == null ? List.of() : request.attachments();
        String modelId = fallback(request.modelId(), session.getModelId());
        String modelName = fallback(request.modelName(), session.getModelName());
        String messageType = messageType(request.messageType(), attachments);

        session.updateModel(modelId, modelName);
        if (session.getMessageCount() == 0) {
            session.updateTitle(titleFrom(request.content()));
        }

        ChatMessageEntity userMessage = new ChatMessageEntity(
                "msg-" + UUID.randomUUID(),
                sessionId,
                "USER",
                messageType,
                request.content(),
                modelId,
                modelName,
                writeAttachmentsForStorage(attachments),
                estimateTokens(request.content(), attachments),
                now
        );
        messageRepository.save(userMessage);

        AiGatewayResponse gatewayResponse = aiGateway.complete(new AiGatewayRequest(
                sessionId,
                DEMO_USER_ID,
                modelId,
                modelName,
                session.getSummary(),
                session.getContextPolicy(),
                gatewayMessages(sessionId),
                attachments.stream()
                        .map(this::toGatewayAttachment)
                        .toList()
        ));

        ChatMessageEntity assistantMessage = new ChatMessageEntity(
                "msg-" + UUID.randomUUID(),
                sessionId,
                "ASSISTANT",
                "TEXT",
                gatewayResponse.content(),
                modelId,
                modelName,
                writeAttachmentsForStorage(gatewayArtifactsToAttachments(gatewayResponse.artifacts())),
                gatewayResponse.tokenEstimate(),
                now.plusMillis(1)
        );

        messageRepository.save(assistantMessage);
        session.incrementMessageCount(2);
        maybeMarkNeedsCompression(session);
        session.touch(now);
        ChatSessionEntity savedSession = sessionRepository.save(session);

        return new ChatTurnDto(
                savedSession.toDto(),
                toDto(userMessage),
                toDto(assistantMessage)
        );
    }

    private void maybeMarkNeedsCompression(ChatSessionEntity session) {
        if (session.isNeedsCompression()) {
            return;
        }
        List<ChatMessageEntity> messages = messageRepository.findBySessionIdOrderByCreatedAtAsc(session.getId());
        int tokenTotal = messages.stream().mapToInt(ChatMessageEntity::getTokenEstimate).sum();
        if (messages.size() >= COMPRESSION_MESSAGE_THRESHOLD || tokenTotal >= COMPRESSION_TOKEN_THRESHOLD) {
            session.markNeedsCompression("当前会话已达到上下文整理阈值，后续真实模型接入后会生成摘要并保留最近消息。");
        }
    }

    private List<AiGatewayMessage> gatewayMessages(String sessionId) {
        return messageRepository.findBySessionIdOrderByCreatedAtAsc(sessionId)
                .stream()
                .map(message -> new AiGatewayMessage(message.getRole(), message.getContent()))
                .toList();
    }

    private AiGatewayAttachment toGatewayAttachment(ChatAttachmentDto attachment) {
        return new AiGatewayAttachment(
                attachment.id(),
                attachment.name(),
                fallback(attachment.kind(), imageAttachment(attachment) ? "IMAGE" : "FILE"),
                attachment.type(),
                fallback(attachment.mimeType(), attachment.type()),
                attachment.size(),
                attachment.status(),
                attachment.base64Data()
        );
    }

    private ChatMessageDto toDto(ChatMessageEntity entity) {
        return new ChatMessageDto(
                entity.getId(),
                entity.getSessionId(),
                entity.getRole(),
                entity.getMessageType(),
                entity.getContent(),
                entity.getModelId(),
                entity.getModelName(),
                readAttachments(entity.getAttachmentsJson()),
                entity.getTokenEstimate(),
                entity.getCreatedAt()
        );
    }

    private String writeAttachmentsForStorage(List<ChatAttachmentDto> attachments) {
        try {
            return objectMapper.writeValueAsString(storageAttachments(attachments));
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Failed to serialize chat attachments", exception);
        }
    }

    private List<ChatAttachmentDto> storageAttachments(List<ChatAttachmentDto> attachments) {
        if (attachments == null || attachments.isEmpty()) {
            return List.of();
        }
        return attachments.stream()
                .map(attachment -> new ChatAttachmentDto(
                        attachment.id(),
                        attachment.name(),
                        attachment.kind(),
                        attachment.type(),
                attachment.mimeType(),
                attachment.size(),
                attachment.status(),
                attachment.url(),
                null
        ))
                .toList();
    }

    private List<ChatAttachmentDto> gatewayArtifactsToAttachments(List<AiGatewayArtifact> artifacts) {
        if (artifacts == null || artifacts.isEmpty()) {
            return List.of();
        }
        return artifacts.stream()
                .map(artifact -> new ChatAttachmentDto(
                        artifact.id(),
                        artifact.name(),
                        artifact.kind(),
                        artifact.type(),
                        artifact.mimeType(),
                        artifact.size(),
                        artifact.status(),
                        artifact.url(),
                        artifact.base64Data()
                ))
                .toList();
    }

    private List<ChatAttachmentDto> readAttachments(String value) {
        try {
            if (value == null || value.isBlank()) {
                return List.of();
            }
            return objectMapper.readValue(value, new TypeReference<>() {
            });
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Failed to deserialize chat attachments", exception);
        }
    }

    private int estimateTokens(String content, List<ChatAttachmentDto> attachments) {
        int contentTokens = content == null ? 0 : Math.max(1, content.length() / 2);
        int attachmentTokens = attachments == null ? 0 : attachments.size() * 80;
        return contentTokens + attachmentTokens;
    }

    private String messageType(String requestedMessageType, List<ChatAttachmentDto> attachments) {
        if (requestedMessageType != null && !requestedMessageType.isBlank()) {
            return requestedMessageType;
        }
        boolean hasImage = attachments != null && attachments.stream().anyMatch(this::imageAttachment);
        return hasImage ? "IMAGE_QUESTION" : "TEXT";
    }

    private boolean imageAttachment(ChatAttachmentDto attachment) {
        String kind = attachment.kind();
        String type = fallback(attachment.mimeType(), attachment.type());
        return "IMAGE".equalsIgnoreCase(kind) || (type != null && type.toLowerCase().startsWith("image/"));
    }

    private String titleFrom(String content) {
        if (content == null || content.isBlank()) {
            return "新的对话";
        }
        String normalized = content.trim().replaceAll("\\s+", " ");
        return normalized.length() <= 24 ? normalized : normalized.substring(0, 24) + "...";
    }

    private String fallback(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
    }
}

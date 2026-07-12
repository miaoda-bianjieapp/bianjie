package com.bianjie.ai.api.modules.chat;

import com.bianjie.ai.api.common.response.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/chat")
public class ChatController {

    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @GetMapping("/sessions")
    public ApiResponse<List<ChatSessionDto>> listSessions() {
        return ApiResponse.ok(chatService.listSessions());
    }

    @PostMapping("/sessions")
    public ApiResponse<ChatSessionDto> createSession(@RequestBody CreateChatSessionRequest request) {
        return ApiResponse.ok(chatService.createSession(request));
    }

    @GetMapping("/sessions/{sessionId}/messages")
    public ApiResponse<List<ChatMessageDto>> getMessages(@PathVariable String sessionId) {
        return ApiResponse.ok(chatService.getMessages(sessionId));
    }

    @PostMapping("/sessions/{sessionId}/messages")
    public ApiResponse<ChatTurnDto> sendMessage(
            @PathVariable String sessionId,
            @Valid @RequestBody SendChatMessageRequest request
    ) {
        return ApiResponse.ok(chatService.sendMessage(sessionId, request));
    }
}

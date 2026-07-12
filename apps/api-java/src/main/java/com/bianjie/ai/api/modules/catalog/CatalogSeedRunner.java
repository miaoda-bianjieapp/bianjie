package com.bianjie.ai.api.modules.catalog;

import com.bianjie.ai.api.modules.agents.AgentTemplateEntity;
import com.bianjie.ai.api.modules.agents.AgentTemplateRepository;
import com.bianjie.ai.api.modules.categories.ToolCategoryEntity;
import com.bianjie.ai.api.modules.categories.ToolCategoryRepository;
import com.bianjie.ai.api.modules.membership.MembershipEntity;
import com.bianjie.ai.api.modules.membership.MembershipRepository;
import com.bianjie.ai.api.modules.models.AiModelEntity;
import com.bianjie.ai.api.modules.models.AiModelRepository;
import com.bianjie.ai.api.modules.prompts.PromptSuggestionEntity;
import com.bianjie.ai.api.modules.prompts.PromptSuggestionRepository;
import com.bianjie.ai.api.modules.stock.StockCapabilityEntity;
import com.bianjie.ai.api.modules.stock.StockCapabilityRepository;
import com.bianjie.ai.api.modules.stock.StockStatEntity;
import com.bianjie.ai.api.modules.stock.StockStatRepository;
import com.bianjie.ai.api.modules.tools.ToolEntity;
import com.bianjie.ai.api.modules.tools.ToolExecutionType;
import com.bianjie.ai.api.modules.tools.ToolRepository;
import com.bianjie.ai.api.modules.users.UserProfileEntity;
import com.bianjie.ai.api.modules.users.UserProfileRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Component
public class CatalogSeedRunner implements CommandLineRunner {

    private final ToolRepository toolRepository;
    private final ToolCategoryRepository categoryRepository;
    private final PromptSuggestionRepository promptRepository;
    private final AiModelRepository modelRepository;
    private final AgentTemplateRepository agentTemplateRepository;
    private final StockStatRepository stockStatRepository;
    private final StockCapabilityRepository stockCapabilityRepository;
    private final UserProfileRepository userProfileRepository;
    private final MembershipRepository membershipRepository;

    public CatalogSeedRunner(
            ToolRepository toolRepository,
            ToolCategoryRepository categoryRepository,
            PromptSuggestionRepository promptRepository,
            AiModelRepository modelRepository,
            AgentTemplateRepository agentTemplateRepository,
            StockStatRepository stockStatRepository,
            StockCapabilityRepository stockCapabilityRepository,
            UserProfileRepository userProfileRepository,
            MembershipRepository membershipRepository
    ) {
        this.toolRepository = toolRepository;
        this.categoryRepository = categoryRepository;
        this.promptRepository = promptRepository;
        this.modelRepository = modelRepository;
        this.agentTemplateRepository = agentTemplateRepository;
        this.stockStatRepository = stockStatRepository;
        this.stockCapabilityRepository = stockCapabilityRepository;
        this.userProfileRepository = userProfileRepository;
        this.membershipRepository = membershipRepository;
    }

    @Override
    @Transactional
    public void run(String... args) {
        if (toolRepository.count() > 0) {
            seedModels();
            return;
        }

        seedCategories();
        seedTools();
        seedPrompts();
        seedModels();
        seedAgentTemplates();
        seedStock();
        seedUserAndMembership();
    }

    private void seedCategories() {
        categoryRepository.saveAll(List.of(
                new ToolCategoryEntity("recent", "最近更新", 4, null, false, 1),
                new ToolCategoryEntity("hot", "热门推荐", 5, null, false, 2),
                new ToolCategoryEntity("image", "图像生成", 4, null, true, 3),
                new ToolCategoryEntity("ppt", "AI PPT", 3, null, true, 4),
                new ToolCategoryEntity("pdf", "PDF 操作", 3, null, true, 5),
                new ToolCategoryEntity("design", "AI 设计", 3, null, true, 6),
                new ToolCategoryEntity("writing", "文章创作", 10, null, false, 7),
                new ToolCategoryEntity("copywriting", "文案策划", 5, null, false, 8),
                new ToolCategoryEntity("paper", "论文辅助", 4, null, false, 9),
                new ToolCategoryEntity("life", "生活助手", 6, null, false, 10)
        ));
    }

    private void seedTools() {
        toolRepository.saveAll(List.of(
                tool("design-image", "一秒生成设计图", "输入主题后生成活动海报和社媒配图。", "image", "home",
                        "image", List.of("热门"), "/tool/design-image", false, false, ToolExecutionType.FORM, 1,
                        designImageConfig()),
                tool("video-script", "爆款短视频脚本", "生成口播脚本、镜头拆解和标题。", "hot", "home",
                        "movie", List.of("新增"), "/tool/video-script", false, false, ToolExecutionType.CHAT, 2,
                        videoScriptConfig()),
                tool("teaching-ppt", "教学 PPT", "根据课程主题生成教学大纲和 PPT 结构。", "ppt", "home",
                        "ppt", List.of("办公"), "/tool/teaching-ppt", false, false, ToolExecutionType.TASK, 3),
                tool("image-model", "生图模型", "多风格图片生成入口。", "image", "tools",
                        "brush", List.of("图像"), "/tool/image-model", false, true, ToolExecutionType.FORM, 4),
                tool("photo-retouch", "P 图模型", "替换背景、局部修图和商品图优化。", "image", "tools",
                        "magic", List.of("图像"), "/tool/photo-retouch", false, false, ToolExecutionType.FORM, 5),
                tool("pdf-summary", "PDF 总结", "上传文档后提炼摘要、目录和问答。", "pdf", "tools",
                        "pdf", List.of("PDF"), "/tool/pdf-summary", true, false, ToolExecutionType.TASK, 6),
                tool("pdf-convert", "PDF 转换", "上传 PDF 后转换为 Word、图片或纯文本。", "pdf", "tools",
                        "pdf", List.of("PDF", "文件"), "/tool/pdf-convert", true, false, ToolExecutionType.TASK, 17,
                        pdfConvertConfig()),
                tool("document-to-ppt", "文档生成 PPT", "上传文档后生成 PPT 大纲和演示稿。", "ppt", "tools",
                        "ppt", List.of("办公", "PPT"), "/tool/document-to-ppt", true, true, ToolExecutionType.TASK, 18,
                        documentToPptConfig()),
                tool("brand-logo", "Logo 灵感", "生成品牌标识方向和视觉关键词。", "design", "tools",
                        "diamond", List.of("设计"), "/tool/brand-logo", false, false, ToolExecutionType.PLACEHOLDER, 7),
                tool("old-image-model", "AI 生图（旧版）", "旧版生图入口，占位展示。", "image", "tools",
                        "image", List.of("图像"), "/tool/old-image-model", false, false, ToolExecutionType.PLACEHOLDER, 19),
                tool("id-photo", "AI 证件照", "证件照生成与换底色，占位展示。", "image", "tools",
                        "badge", List.of("图像"), "/tool/id-photo", false, false, ToolExecutionType.PLACEHOLDER, 20),
                tool("ai-portrait", "AI 写真", "个人写真生成，占位展示。", "image", "tools",
                        "image", List.of("图像"), "/tool/ai-portrait", false, false, ToolExecutionType.PLACEHOLDER, 21),
                tool("outfit-swap", "AI 换装", "服装替换与搭配预览，占位展示。", "image", "tools",
                        "shirt", List.of("图像"), "/tool/outfit-swap", false, false, ToolExecutionType.PLACEHOLDER, 22),
                tool("face-swap", "AI 换脸", "人脸替换能力，占位展示。", "image", "tools",
                        "face", List.of("图像"), "/tool/face-swap", false, false, ToolExecutionType.PLACEHOLDER, 23),
                tool("write-article", "写一篇文章", "给出主题后生成结构完整的文章初稿。", "writing", "writing",
                        "article", List.of("写作"), "/tool/write-article", false, false, ToolExecutionType.FORM, 8,
                        writeArticleConfig()),
                tool("style-article", "按风格写文章", "按指定作者、平台或语气生成文章。", "writing", "writing",
                        "palette", List.of("写作"), "/tool/style-article", false, false, ToolExecutionType.CHAT, 9),
                tool("rewrite-article", "文章改写", "保留核心意思，重组表达和结构。", "writing", "writing",
                        "rewrite", List.of("写作"), "/tool/rewrite-article", false, false, ToolExecutionType.FORM, 10),
                tool("polish-copy", "文案润色", "提升文案质感、节奏和转化表达。", "copywriting", "writing",
                        "sparkle", List.of("热门"), "/tool/polish-copy", false, false, ToolExecutionType.CHAT, 11,
                        polishCopyConfig()),
                tool("long-outline", "万字文章大纲", "生成长文目录、章节和写作要点。", "writing", "writing",
                        "outline", List.of("长文"), "/tool/long-outline", false, false, ToolExecutionType.FORM, 12),
                tool("duplicate-check", "文章查重复率", "Demo 阶段展示查重任务占位流程。", "paper", "writing",
                        "check", List.of("论文"), "/tool/duplicate-check", true, true, ToolExecutionType.TASK, 13),
                tool("xiaohongshu-style", "小红书风格改写", "将普通文案改写成小红书笔记风格。", "copywriting", "writing",
                        "heart", List.of("平台"), "/tool/xiaohongshu-style", false, false, ToolExecutionType.CHAT, 14),
                tool("news-writer", "新闻专员", "根据事实要点撰写新闻通讯。", "copywriting", "writing",
                        "news", List.of("办公"), "/tool/news-writer", false, false, ToolExecutionType.CHAT, 15),
                tool("review-letter", "写检讨书", "生成不同语气和场景的检讨书草稿。", "life", "writing",
                        "document", List.of("生活"), "/tool/review-letter", false, false, ToolExecutionType.PLACEHOLDER, 16),
                tool("story-novel", "写故事小说", "根据题材、背景和人物关系创作故事。", "writing", "writing",
                        "document", List.of("小说"), "/tool/story-novel", false, false, ToolExecutionType.FORM, 17,
                        storyNovelConfig()),
                tool("paper-topic", "论文选题", "根据专业和研究方向生成论文选题。", "paper", "writing",
                        "research", List.of("论文"), "/tool/paper-topic", false, false, ToolExecutionType.FORM, 18,
                        paperTopicConfig())
        ));
    }

    private void seedPrompts() {
        promptRepository.saveAll(List.of(
                new PromptSuggestionEntity("prompt-design", "一秒生成设计图", "/tool/design-image", "image", "home", 1),
                new PromptSuggestionEntity("prompt-video", "零基础制作爆款短视频", "/tool/video-script", "movie", "home", 2),
                new PromptSuggestionEntity("prompt-ppt", "帮我生成一份教学 PPT", "/tool/teaching-ppt", "ppt", "home", 3),
                new PromptSuggestionEntity("prompt-stock", "分析某股票最新财报与估值", "/stock/analyze-stock", "stock", "stock", 4)
        ));
    }

    private void seedModels() {
        modelRepository.saveAll(List.of(
                new AiModelEntity("glm-5v-turbo", "GLM-5V Turbo", "当前真实接入的 GLM 多模态模型。", true, 1),
                new AiModelEntity("qwen-image-2.0", "Qwen Image 2.0", "用于设计图生成与参考图改写的图像模型。", false, 20),
                new AiModelEntity("deepseek-r1", "DeepSeek-R1 联网满血版", "适合写作、推理和复杂任务拆解。", false, 2),
                new AiModelEntity("stock-pro-flash", "股票 1.6 Pro Flash", "面向股票频道的快速分析模型。", false, 3),
                new AiModelEntity("agent-worker", "AI-Agent 助手", "适合模板化任务和多步骤执行。", false, 4)
        ));
    }

    private void seedAgentTemplates() {
        agentTemplateRepository.saveAll(List.of(
                new AgentTemplateEntity("resume-demo", "简历优化助手", "badge", "简历制作",
                        "帮我优化一份面向产品经理岗位的简历。", "整理经历亮点，改写项目表述，生成投递建议。", 1),
                new AgentTemplateEntity("training-plan", "新员工培训方案", "school", "做报告",
                        "为 20 人团队设计一周新员工培训方案。", "输出培训目标、日程安排、材料清单和验收方式。", 2),
                new AgentTemplateEntity("market-research", "养老服务市场调研", "research", "市场调研",
                        "帮我做一份养老服务市场调研框架。", "覆盖行业规模、用户画像、竞品维度和访谈问题。", 3),
                new AgentTemplateEntity("web-brief", "网页需求梳理", "web", "写文档",
                        "把我的想法整理成网页产品需求文档。", "产出页面结构、模块说明、交互流程和验收标准。", 4)
        ));
    }

    private void seedStock() {
        stockStatRepository.saveAll(List.of(
                new StockStatEntity("reports", "分析报告已生成", "12.8", "万份", 1),
                new StockStatEntity("active-users", "活跃用户", "6.4", "万人", 2),
                new StockStatEntity("watched-stocks", "为用户监控股票", "32.1", "万只", 3)
        ));
        stockCapabilityRepository.saveAll(List.of(
                new StockCapabilityEntity("analyze-stock", "分析个股", "分析个股的最新财报、估值和风险点", "query-stats", false, 1),
                new StockCapabilityEntity("backtest", "策略回测", "创建一个策略回测任务", "timeline", true, 2),
                new StockCapabilityEntity("market-overview", "市场概览", "总结今日市场结构和板块热度", "public", true, 3),
                new StockCapabilityEntity("stock-screener", "选股筛选", "按行业、估值和增长筛选股票", "filter", true, 4),
                new StockCapabilityEntity("more", "更多", "查看更多股票能力", "more", true, 5)
        ));
    }

    private void seedUserAndMembership() {
        userProfileRepository.save(new UserProfileEntity(
                "u-demo-001",
                "边界体验官",
                "138****2026",
                "BJ",
                2680,
                "体验会员",
                false
        ));
        membershipRepository.save(new MembershipEntity(
                "default",
                "trial",
                "边界 AI 体验会员",
                120,
                List.of("工具目录优先体验", "任务执行占位额度", "会员限制状态预览")
        ));
    }

    private static ToolEntity tool(
            String id,
            String name,
            String description,
            String categoryId,
            String tab,
            String icon,
            List<String> tags,
            String route,
            boolean requiresLogin,
            boolean requiresVip,
            ToolExecutionType executionType,
            int sortOrder
    ) {
        return tool(
                id,
                name,
                description,
                categoryId,
                tab,
                icon,
                tags,
                route,
                requiresLogin,
                requiresVip,
                executionType,
                sortOrder,
                "{}"
        );
    }

    private static ToolEntity tool(
            String id,
            String name,
            String description,
            String categoryId,
            String tab,
            String icon,
            List<String> tags,
            String route,
            boolean requiresLogin,
            boolean requiresVip,
            ToolExecutionType executionType,
            int sortOrder,
            String configJson
    ) {
        return new ToolEntity(
                id,
                name,
                description,
                categoryId,
                tab,
                icon,
                tags,
                route,
                true,
                sortOrder,
                requiresLogin,
                requiresVip,
                executionType,
                configJson
        );
    }

    private static String videoScriptConfig() {
        return """
                {
                  "version": "llm-text-v1",
                  "executor": "llm-template",
                  "systemPrompt": "你是资深短视频编导，擅长把普通主题转化为节奏清晰、可直接拍摄的短视频脚本。",
                  "taskPrompt": "根据用户主题生成一份完整的爆款短视频脚本，内容必须具体、可执行，避免空泛建议。",
                  "outputInstruction": "使用中文输出，包含3个标题、开头3秒钩子、分镜脚本表、素材清单、发布文案和5个话题标签。",
                  "inputModes": ["text"],
                  "outputFormats": ["markdown"],
                  "fields": [
                    {"name": "platform", "label": "发布平台", "type": "select", "required": false, "options": ["抖音", "小红书", "视频号", "B站"]},
                    {"name": "duration", "label": "视频时长", "type": "select", "required": false, "options": ["30 秒", "60 秒", "90 秒", "3 分钟"]},
                    {"name": "audience", "label": "目标受众", "type": "text", "required": false},
                    {"name": "tone", "label": "语气风格", "type": "select", "required": false, "options": ["强吸引力、节奏快", "专业可信", "轻松幽默", "情绪共鸣"]}
                  ]
                }
                """;
    }

    private static String designImageConfig() {
        return """
                {
                  "version": "tool-protocol-v2",
                  "executor": "image-generation",
                  "operation": "design-image",
                  "inputRequired": true,
                  "inputModes": ["text", "image"],
                  "acceptedFileTypes": ["jpg", "jpeg", "png", "webp"],
                  "maxFiles": 3,
                  "maxFileSizeMb": 12,
                  "outputFormats": ["png"],
                  "primaryInput": {"label": "设计需求", "placeholder": "描述需要生成的画面、文案、配色和使用场景", "required": true, "minLines": 5, "maxLines": 8, "maxLength": 1000},
                  "fields": [
                    {"name": "style", "label": "设计风格", "type": "select", "required": false, "options": ["清爽科技感", "电商促销", "小红书封面", "教育课件", "商务海报"]},
                    {"name": "size", "label": "图片尺寸", "type": "segmented", "required": false, "defaultValue": "1024x1024", "options": ["1024x1024", "1024x1536", "1536x1024"]}
                  ]
                }
                """;
    }

    private static String pdfConvertConfig() {
        return """
                {
                  "version": "tool-protocol-v2",
                  "executor": "document-processing",
                  "operation": "pdf-convert",
                  "inputRequired": false,
                  "inputModes": ["file"],
                  "acceptedFileTypes": ["pdf"],
                  "minFiles": 1,
                  "maxFiles": 1,
                  "maxFileSizeMb": 30,
                  "outputFormats": ["docx", "png", "txt"],
                  "fields": [
                    {"name": "outputFormat", "label": "输出格式", "type": "segmented", "required": true, "defaultValue": "docx", "options": ["docx", "png", "txt"]},
                    {"name": "ocrEnabled", "label": "扫描件 OCR", "type": "boolean", "required": false}
                  ]
                }
                """;
    }

    private static String documentToPptConfig() {
        return """
                {
                  "version": "tool-protocol-v2",
                  "executor": "ppt-generation",
                  "operation": "document-to-ppt",
                  "inputRequired": false,
                  "inputModes": ["file", "text"],
                  "acceptedFileTypes": ["docx", "pdf", "txt", "md"],
                  "minFiles": 1,
                  "maxFiles": 1,
                  "maxFileSizeMb": 30,
                  "outputFormats": ["pptx"],
                  "primaryInput": {"label": "补充要求", "placeholder": "可选：描述演示目标、重点内容和希望强调的结论", "required": false, "minLines": 3, "maxLines": 5, "maxLength": 500},
                  "fields": [
                    {"name": "language", "label": "输出语言", "type": "segmented", "required": false, "defaultValue": "中文", "options": ["中文", "English", "日本語", "한국어"]},
                    {"name": "slideCount", "label": "页数", "type": "slider", "required": false, "defaultValue": 20, "min": 10, "max": 50, "divisions": 4},
                    {"name": "detail", "label": "内容详细度", "type": "select", "required": false, "defaultValue": "严格按照参考内容", "options": ["精炼概括", "严格按照参考内容", "适当扩展内容"]},
                    {"name": "style", "label": "场景", "type": "select", "required": false, "defaultValue": "商务简洁", "options": ["商务简洁", "分析报告", "教学课件", "商业计划", "演讲报告", "竞品分析"]}
                  ]
                }
                """;
    }

    private static String polishCopyConfig() {
        return """
                {
                  "version": "llm-text-v1",
                  "executor": "llm-template",
                  "systemPrompt": "你是专业中文商业文案编辑，擅长在不改变事实的前提下提升表达质感和转化力。",
                  "taskPrompt": "润色用户提供的原文，保持原意，不编造数据。",
                  "outputInstruction": "输出润色后文案、3个可选标题或开头，并简要列出关键优化点。",
                  "inputModes": ["text"],
                  "outputFormats": ["markdown"],
                  "fields": [
                    {"name": "scenario", "label": "使用场景", "type": "select", "required": false, "options": ["通用宣传", "朋友圈/社群", "小红书笔记", "产品介绍", "商务邮件"]},
                    {"name": "style", "label": "润色风格", "type": "select", "required": false, "options": ["清爽、有质感", "更有销售力", "更正式专业", "更口语自然", "更适合小红书"]},
                    {"name": "keepLength", "label": "尽量保持原长度", "type": "boolean", "required": false}
                  ]
                }
                """;
    }

    private static String writeArticleConfig() {
        return """
                {
                  "version": "writing-v1",
                  "executor": "llm-template",
                  "systemPrompt": "你是专业中文写作助手，擅长围绕主题组织结构完整、逻辑清晰且表达自然的文章。",
                  "taskPrompt": "根据用户描述的主题和补充参数，完成一篇可直接修改使用的文章初稿。",
                  "outputInstruction": "输出标题、正文和3条可继续优化的建议。不要编造未经提供的数据。",
                  "inputModes": ["text"],
                  "outputFormats": ["markdown"],
                  "primaryInput": {"label": "主题", "placeholder": "描述文章主题、核心观点和必须包含的内容", "required": true, "minLines": 6, "maxLines": 10, "maxLength": 1000, "example": "围绕人工智能如何提升大学生学习效率，写一篇观点清晰的文章"},
                  "fields": [
                    {"name": "style", "label": "写作风格", "type": "select", "required": false, "options": ["专业严谨", "通俗易懂", "轻松自然", "有感染力"]},
                    {"name": "audience", "label": "目标读者", "type": "text", "required": false, "placeholder": "例如：大学生、企业客户"},
                    {"name": "length", "label": "文章篇幅", "type": "select", "required": false, "options": ["约800字", "约1500字", "约3000字"]}
                  ]
                }
                """;
    }

    private static String storyNovelConfig() {
        return """
                {
                  "version": "writing-v1",
                  "executor": "llm-template",
                  "systemPrompt": "你是中文故事与小说创作助手，擅长人物塑造、冲突设计、情节推进和氛围营造。",
                  "taskPrompt": "根据题材、故事背景和人物关系创作一篇情节完整、有冲突和转折的短篇故事。",
                  "outputInstruction": "输出故事标题和完整正文，人物行为要符合设定，结尾应有明确收束。",
                  "inputModes": ["text"],
                  "outputFormats": ["markdown"],
                  "primaryInput": {"label": "故事背景", "placeholder": "描述时间、地点、事件起因和想表达的主题", "required": true, "minLines": 5, "maxLines": 8, "maxLength": 1000, "example": "2008年的上海大学校园，两位久别重逢的同学发现了一封未寄出的信"},
                  "fields": [
                    {"name": "genre", "label": "小说题材", "type": "chips", "required": true, "options": ["爱情", "乡村", "玄幻", "魔幻", "武侠", "都市", "修真", "耽美", "同人", "科幻", "灵异", "推理", "恐怖", "悬疑", "历史", "盗墓"]},
                    {"name": "relationship", "label": "人物关系", "type": "textarea", "required": false, "placeholder": "例如：李雷和韩梅梅从初中便是同学", "minLines": 3, "maxLines": 5, "maxLength": 500},
                    {"name": "length", "label": "故事篇幅", "type": "select", "required": false, "options": ["约1000字", "约2000字", "约4000字"]}
                  ]
                }
                """;
    }

    private static String paperTopicConfig() {
        return """
                {
                  "version": "writing-v1",
                  "executor": "llm-template",
                  "systemPrompt": "你是高校论文选题顾问，擅长把专业背景和研究兴趣转化为边界清晰、可落地的研究选题。",
                  "taskPrompt": "根据用户的专业和研究方向生成论文选题，避免范围过大或缺乏研究对象。",
                  "outputInstruction": "输出10个候选题目；每个题目附研究对象、核心问题和可行的研究方法；最后推荐3个最可行选题。",
                  "inputModes": ["text"],
                  "outputFormats": ["markdown"],
                  "primaryInput": {"label": "研究方向", "placeholder": "例如：人工智能在教育场景中的应用", "required": true, "minLines": 4, "maxLines": 6, "maxLength": 500, "example": "生成式人工智能对大学生自主学习行为的影响"},
                  "fields": [
                    {"name": "major", "label": "专业", "type": "text", "required": true, "placeholder": "例如：计算机科学与技术"},
                    {"name": "degree", "label": "培养层次", "type": "chips", "required": false, "options": ["专科", "本科", "硕士", "博士"]},
                    {"name": "method", "label": "偏好研究方法", "type": "select", "required": false, "options": ["不限", "问卷调查", "案例研究", "实验研究", "数据分析"]}
                  ]
                }
                """;
    }
}

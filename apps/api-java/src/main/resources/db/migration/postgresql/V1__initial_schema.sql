CREATE TABLE agent_templates (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255),
    cover_icon VARCHAR(255),
    category VARCHAR(255),
    prompt VARCHAR(1000),
    description VARCHAR(1000),
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE tool_categories (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    count INTEGER NOT NULL DEFAULT 0,
    parent_id VARCHAR(255),
    collapsed BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE chat_sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255),
    title VARCHAR(255),
    model_id VARCHAR(255),
    model_name VARCHAR(255),
    summary TEXT,
    context_policy VARCHAR(255),
    message_count INTEGER NOT NULL DEFAULT 0,
    needs_compression BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE chat_messages (
    id VARCHAR(255) PRIMARY KEY,
    session_id VARCHAR(255),
    role VARCHAR(255),
    message_type VARCHAR(255),
    content TEXT,
    model_id VARCHAR(255),
    model_name VARCHAR(255),
    attachments_json TEXT,
    token_estimate INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_chat_messages_session
        FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
);

CREATE TABLE memberships (
    id VARCHAR(255) PRIMARY KEY,
    status VARCHAR(255),
    title VARCHAR(255),
    remaining_credits INTEGER NOT NULL DEFAULT 0,
    benefits VARCHAR(255)
);

CREATE TABLE ai_models (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    description VARCHAR(1000),
    default_model BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE prompt_suggestions (
    id VARCHAR(255) PRIMARY KEY,
    text VARCHAR(255),
    target VARCHAR(255),
    icon VARCHAR(255),
    scenario VARCHAR(255),
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE stock_capabilities (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255),
    prompt VARCHAR(1000),
    icon VARCHAR(255),
    opens_page BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE stock_stats (
    id VARCHAR(255) PRIMARY KEY,
    label VARCHAR(255),
    stat_value VARCHAR(255),
    unit VARCHAR(255),
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE tasks (
    id VARCHAR(255) PRIMARY KEY,
    type VARCHAR(255),
    title VARCHAR(255),
    status VARCHAR(255),
    payload_json TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE tool_runs (
    id VARCHAR(255) PRIMARY KEY,
    tool_id VARCHAR(255),
    status VARCHAR(255),
    input TEXT,
    parameters_json TEXT,
    output_json TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE tools (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    description VARCHAR(1000),
    category_id VARCHAR(255),
    tab_key VARCHAR(255),
    icon VARCHAR(255),
    tags VARCHAR(1000),
    route VARCHAR(255),
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    requires_login BOOLEAN NOT NULL DEFAULT FALSE,
    requires_vip BOOLEAN NOT NULL DEFAULT FALSE,
    execution_type VARCHAR(255),
    config_json TEXT
);

CREATE TABLE user_profiles (
    id VARCHAR(255) PRIMARY KEY,
    nickname VARCHAR(255),
    phone_masked VARCHAR(255),
    avatar VARCHAR(255),
    points INTEGER NOT NULL DEFAULT 0,
    vip_status VARCHAR(255),
    checked_in_today BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_chat_sessions_user_updated
    ON chat_sessions (user_id, updated_at DESC);
CREATE INDEX idx_chat_messages_session_created
    ON chat_messages (session_id, created_at);
CREATE INDEX idx_tool_runs_updated
    ON tool_runs (updated_at DESC);
CREATE INDEX idx_tools_tab_sort
    ON tools (tab_key, sort_order);
CREATE INDEX idx_prompt_suggestions_target_sort
    ON prompt_suggestions (target, sort_order);

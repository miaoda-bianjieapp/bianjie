const iconPaths = {
  home: '<path d="M3 11.5 12 4l9 7.5"/><path d="M5 10v10h14V10"/><path d="M9 20v-6h6v6"/>',
  tools: '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>',
  chart: '<path d="M3 18 9 12l4 4 8-10"/><path d="M17 6h4v4"/>',
  sparkles: '<path d="m12 3-1.4 3.6L7 8l3.6 1.4L12 13l1.4-3.6L17 8l-3.6-1.4Z"/><path d="m5 15-.8 2.2L2 18l2.2.8L5 21l.8-2.2L8 18l-2.2-.8Z"/><path d="m19 13-.7 1.8-1.8.7 1.8.7L19 18l.7-1.8 1.8-.7-1.8-.7Z"/>',
  writing: '<path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z"/>',
  user: '<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
  search: '<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>',
  paperclip: '<path d="m21.4 11.6-8.9 8.9a6 6 0 0 1-8.5-8.5l9.6-9.6a4 4 0 0 1 5.7 5.7l-9.6 9.6a2 2 0 0 1-2.8-2.8l8.9-8.9"/>',
  image: '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="m21 15-5-5L5 21"/>',
  file: '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z"/><path d="M14 2v6h6M8 13h8M8 17h6"/>',
  palette: '<circle cx="13.5" cy="6.5" r=".5"/><circle cx="17.5" cy="10.5" r=".5"/><circle cx="8.5" cy="7.5" r=".5"/><circle cx="6.5" cy="12.5" r=".5"/><path d="M12 2a10 10 0 0 0 0 20h1.5a2.5 2.5 0 0 0 0-5H12a2 2 0 0 1 0-4h4a6 6 0 0 0 0-12Z"/>',
  presentation: '<path d="M3 3h18v13H3zM8 21l4-5 4 5M12 16v5"/>',
  wand: '<path d="m15 4 5 5L7 22l-5-5Z"/><path d="m14 5 5 5M6 3v4M4 5h4M19 15v4M17 17h4"/>',
  settings: '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1-2.8 2.8-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.6v.2h-4V21a1.7 1.7 0 0 0-1-1.6 1.7 1.7 0 0 0-1.9.3l-.1.1L4.2 17l.1-.1a1.7 1.7 0 0 0 .3-1.9A1.7 1.7 0 0 0 3 14H2.8v-4H3a1.7 1.7 0 0 0 1.6-1 1.7 1.7 0 0 0-.3-1.9L4.2 7 7 4.2l.1.1a1.7 1.7 0 0 0 1.9.3A1.7 1.7 0 0 0 10 3V2.8h4V3a1.7 1.7 0 0 0 1 1.6 1.7 1.7 0 0 0 1.9-.3l.1-.1L19.8 7l-.1.1a1.7 1.7 0 0 0-.3 1.9 1.7 1.7 0 0 0 1.6 1h.2v4H21a1.7 1.7 0 0 0-1.6 1Z"/>',
  help: '<circle cx="12" cy="12" r="10"/><path d="M9.1 9a3 3 0 1 1 5.8 1c0 2-3 2-3 4M12 18h.01"/>',
  history: '<path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 3v5h5M12 7v5l3 2"/>',
};

const concepts = [
  {
    id: 'a',
    index: 'A',
    name: '潮汐工作台',
    subtitle: 'Tidal Workspace',
    tags: ['平衡', '品牌感', '低迁移风险'],
    badge: '推荐',
    summary: '深色任务舞台承担视觉重心，浅灰内容区保留熟悉感；适合现有 App 渐进升级。',
  },
  {
    id: 'b',
    index: 'B',
    name: '信号编辑部',
    subtitle: 'Signal Editorial',
    tags: ['高对比', '年轻', '高信息密度'],
    summary: '荧光黄绿配合硬朗边界，工具入口更像创作软件；辨识度高，气质更偏潮流。',
  },
  {
    id: 'c',
    index: 'C',
    name: '夜航工作室',
    subtitle: 'Night Studio',
    tags: ['深色', '沉浸', '夜间友好'],
    summary: '完整深色工作环境，用青绿与琥珀区分操作和状态；变化最大，也最彻底减少白色。',
  },
];

const navItems = [
  ['home', '首页', 'home'],
  ['tools', '功能', 'tools'],
  ['chart', '股票', null],
  ['sparkles', '智能体', null],
  ['writing', '写作', 'writing'],
  ['user', '我的', 'profile'],
];

function icon(name) {
  return `<svg viewBox="0 0 24 24" aria-hidden="true">${iconPaths[name]}</svg>`;
}

function appHeader(title, subtitle = 'AI 助手 · 工具市场 · 垂直工作台') {
  return `
    <div class="app-brand">
      <span class="app-logo">BJ</span>
      <div class="app-brand-text"><strong>${title}</strong><span>${subtitle}</span></div>
      <button class="icon-button" type="button" aria-label="历史记录">${icon('history')}</button>
    </div>`;
}

function homeScreen() {
  return `
    <section class="app-screen is-active" data-screen-panel="home">
      ${appHeader('边界 AI')}
      <div class="home-hero">
        <p class="hero-kicker">今天想完成什么？</p>
        <h3>把想法变成可以交付的成果。</h3>
        <p>写作、设计与文件处理，都从一个任务开始。</p>
        <div class="model-row"><span class="model-chip">✦ GLM-5V Turbo</span><span class="hero-arrow">↑</span></div>
      </div>
      <div class="composer">
        <textarea aria-label="AI 输入框" placeholder="描述任务，或添加一个文件…"></textarea>
        <div class="mini-actions">
          <button class="mini-action" type="button">${icon('paperclip')}附件</button>
          <button class="mini-action" type="button">${icon('image')}图片</button>
          <button class="mini-action" type="button">${icon('sparkles')}模板</button>
        </div>
      </div>
      <div class="section-label"><h4>继续处理</h4><button type="button">查看全部</button></div>
      <div class="recent-list">
        <div class="recent-item"><strong>新品发布短视频脚本</strong><span>12 分钟前 · 已生成 3 个版本</span></div>
        <div class="recent-item"><strong>季度复盘演示文稿</strong><span>昨天 · 18 页 PPT 已保存</span></div>
      </div>
    </section>`;
}

function toolRow(iconName, title, subtitle, tag, color) {
  return `
    <div class="tool-row" role="button" tabindex="0">
      <span class="tool-icon" style="--tool-color:${color};--tool-bg:${color}18">${icon(iconName)}</span>
      <span class="tool-copy"><strong>${title}</strong><span>${subtitle}</span></span>
      <span class="tool-meta">${tag ? `<b>${tag}</b>` : ''}<span>›</span></span>
    </div>`;
}

function toolsScreen() {
  return `
    <section class="app-screen" data-screen-panel="tools">
      <div class="page-title-row">
        <div><h3>发现工具</h3><p>按目标找到最短路径</p></div>
        <button class="icon-button" type="button" aria-label="搜索">${icon('search')}</button>
      </div>
      <div class="search-box">${icon('search')}<span>搜索功能或内容</span></div>
      <div class="feature-banner"><small>本周精选 · IMAGE</small><strong>一句话生成品牌视觉</strong><p>海报、封面和社交媒体配图。</p></div>
      <div class="category-strip">
        <button class="category-chip is-active" type="button">推荐</button>
        <button class="category-chip" type="button">图像</button>
        <button class="category-chip" type="button">文档</button>
        <button class="category-chip" type="button">演示</button>
      </div>
      <div class="section-label"><h4>热门能力</h4><span>8 个工具</span></div>
      <div class="tool-list">
        ${toolRow('image', '一秒生成设计图', '一句话生成多尺寸视觉方案', '热门', '#7c5cff')}
        ${toolRow('presentation', '教学 PPT', '从主题到结构完整生成', '', '#397be8')}
        ${toolRow('wand', '文案润色', '调整语气、结构与表达', 'NEW', '#e95d42')}
        ${toolRow('file', 'PDF 工作台', '转换、合并与内容提取', '', '#18a36f')}
      </div>
    </section>`;
}

function writingScreen() {
  return `
    <section class="app-screen" data-screen-panel="writing">
      <div class="page-title-row">
        <div><h3>写作空间</h3><p>从空白页到可发布内容</p></div>
        <button class="icon-button" type="button" aria-label="搜索">${icon('search')}</button>
      </div>
      <div class="writing-tabs">
        <button class="writing-tab is-active" type="button">内容创作</button>
        <button class="writing-tab" type="button">营销文案</button>
        <button class="writing-tab" type="button">学术辅助</button>
      </div>
      <div class="writing-prompt">
        <strong>今天从哪句话开始？</strong>
        <p>输入主题，AI 会先给出结构，再与你一起完成内容。</p>
        <button class="prompt-button" type="button">开始新文稿 →</button>
      </div>
      <div class="section-label"><h4>常用工具</h4><span>最近更新</span></div>
      <div class="tool-list">
        ${toolRow('writing', '写一篇文章', '从主题生成大纲与全文', '', '#397be8')}
        ${toolRow('palette', '按风格写文章', '复刻语气，不复制内容', '推荐', '#e95d42')}
        ${toolRow('wand', '文章改写', '压缩、扩写或切换风格', '', '#18a36f')}
        ${toolRow('file', '万字文章大纲', '管理长文结构与章节目标', '', '#7c5cff')}
      </div>
    </section>`;
}

function profileScreen() {
  return `
    <section class="app-screen" data-screen-panel="profile">
      <div class="page-title-row"><div><h3>我的</h3><p>偏好、记录与应用信息</p></div><button class="icon-button" type="button" aria-label="设置">${icon('settings')}</button></div>
      <div class="profile-head">
        <span class="avatar">BJ</span>
        <span class="profile-copy"><strong>边界体验官</strong><span>138****2026 · 体验会员</span></span>
        <button class="check-button" type="button">签到</button>
      </div>
      <div class="profile-progress">
        <span><strong>本周完成 12 个任务</strong><span>比上周多完成 4 个</span></span>
        <span class="progress-figure">+32%</span>
      </div>
      <div class="section-label"><h4>使用与支持</h4><span>版本 0.1</span></div>
      <div class="menu-list">
        <div class="menu-item">${icon('history')}<span>历史记录</span><b class="menu-arrow">›</b></div>
        <div class="menu-item">${icon('settings')}<span>偏好设置</span><b class="menu-arrow">›</b></div>
        <div class="menu-item">${icon('file')}<span>协议与隐私</span><b class="menu-arrow">›</b></div>
        <div class="menu-item">${icon('help')}<span>帮助与反馈</span><b class="menu-arrow">›</b></div>
      </div>
    </section>`;
}

function bottomNav() {
  return `
    <nav class="app-bottom-nav" aria-label="App 主导航">
      ${navItems.map(([iconName, label, target]) => `
        <button class="nav-button ${target === 'home' ? 'is-active' : ''}" type="button" ${target ? `data-nav-screen="${target}"` : 'aria-disabled="true"'}>
          ${icon(iconName)}<span>${label}</span>
        </button>`).join('')}
    </nav>`;
}

function conceptCard(concept) {
  return `
    <article class="concept-card" data-concept="${concept.id}">
      <div class="concept-heading">
        <span class="concept-index">${concept.index}</span>
        <div class="concept-title-group"><h2>${concept.name}</h2><p>${concept.subtitle}</p></div>
        ${concept.badge ? `<span class="recommend-badge">${concept.badge}</span>` : ''}
      </div>
      <div class="concept-tags">${concept.tags.map((tag) => `<span>${tag}</span>`).join('')}</div>
      <div class="phone concept-${concept.id}">
        <div class="phone-status"><span>9:41</span><span class="status-icons">▮▮ ◉ 86%</span></div>
        <div class="screen-viewport">
          ${homeScreen()}
          ${toolsScreen()}
          ${writingScreen()}
          ${profileScreen()}
        </div>
        ${bottomNav()}
      </div>
      <div class="concept-summary">
        <p>${concept.summary}</p>
        <button class="choose-button" type="button" data-choose="${concept.id}">选择 ${concept.index} 方向</button>
      </div>
    </article>`;
}

const grid = document.querySelector('#concept-grid');
grid.innerHTML = concepts.map(conceptCard).join('');

function setScreen(screen) {
  document.querySelectorAll('[data-screen-panel]').forEach((panel) => {
    panel.classList.toggle('is-active', panel.dataset.screenPanel === screen);
    if (panel.dataset.screenPanel === screen) panel.scrollTop = 0;
  });

  document.querySelectorAll('[data-nav-screen]').forEach((button) => {
    button.classList.toggle('is-active', button.dataset.navScreen === screen);
  });

  document.querySelectorAll('[data-screen]').forEach((button) => {
    button.classList.toggle('is-active', button.dataset.screen === screen);
  });
}

document.querySelectorAll('[data-screen], [data-nav-screen]').forEach((button) => {
  button.addEventListener('click', () => {
    setScreen(button.dataset.screen || button.dataset.navScreen);
  });
});

document.querySelectorAll('[data-choose]').forEach((button) => {
  button.addEventListener('click', () => {
    const selected = concepts.find((concept) => concept.id === button.dataset.choose);
    document.querySelectorAll('.concept-card').forEach((card) => {
      card.classList.toggle('is-selected', card.dataset.concept === selected.id);
    });
    document.querySelectorAll('[data-choose]').forEach((choice) => {
      const concept = concepts.find((item) => item.id === choice.dataset.choose);
      choice.textContent = concept.id === selected.id ? `已选择 ${concept.index} 方向` : `选择 ${concept.index} 方向`;
    });
    const note = document.querySelector('.selection-note');
    note.classList.add('has-selection');
    document.querySelector('#selection-text').textContent = `当前选择：${selected.index} · ${selected.name}。后续可按此方向落地 Flutter。`;
  });
});

document.querySelectorAll('.tool-row').forEach((row) => {
  const activate = () => {
    const list = row.closest('.tool-list');
    list.querySelectorAll('.tool-row').forEach((item) => item.classList.remove('is-selected'));
    row.classList.add('is-selected');
  };
  row.addEventListener('click', activate);
  row.addEventListener('keydown', (event) => {
    if (event.key === 'Enter' || event.key === ' ') activate();
  });
});

document.querySelectorAll('.category-chip').forEach((chip) => {
  chip.addEventListener('click', () => {
    const strip = chip.closest('.category-strip');
    strip.querySelectorAll('.category-chip').forEach((item) => item.classList.remove('is-active'));
    chip.classList.add('is-active');
  });
});

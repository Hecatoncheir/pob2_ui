const WORKSPACE_TABS = [
  ['tree', 'tree', 'Дерево'], ['items', 'sword', 'Предметы'], ['skills', 'gem', 'Умения'],
  ['config', 'settings', 'Условия'], ['calcs', 'chart', 'Расчёты']
];
const STAT_INDEX = Object.fromEntries(REPORT_GROUPS.flatMap(group => group.rows.map(row => [row[0], row])));
const treeHistory = new Map();

function selectOptions(options, selected) {
  return Object.entries(options).map(([value, label]) => `<option value="${escapeHtml(value)}" ${selected === value ? 'selected' : ''}>${escapeHtml(label)}</option>`).join('');
}

function renderWorkspace() {
  if (!currentBuild()) return emptyLibrary();
  return `${renderWorkspaceHeading()}${renderWorkspaceTabs()}
    <div class="editor-layout">
      <div class="workspace-pane" id="workspace-panel" role="tabpanel" aria-labelledby="tab-${state.tab}">${renderEditor()}</div>
      ${renderInspector()}
    </div>
    <button class="inspector-backdrop" data-action="close-stats" aria-label="Закрыть показатели" ${state.statsVisible ? '' : 'hidden'}></button>`;
}

function renderWorkspaceHeading() {
  const build = currentBuild();
  const character = [build.className, build.ascendancy, `Ур. ${build.level}`].filter(Boolean).join(' · ');
  return `<div class="workspace-heading"><div class="workspace-identity"><button class="build-title-button" data-action="rename" title="Переименовать сборку"><h1>${escapeHtml(build.name)}</h1></button><button class="character-chip" data-action="character">${escapeHtml(character)}${uiIcon('chevron')}</button></div>
    <div class="workspace-actions"><span class="save-label">${uiIcon('check')}${storageAvailable ? 'Сохранено' : 'В памяти'}</span><button class="icon-button" data-action="copy-build" aria-label="Сохранить копию" title="Сохранить копию">${uiIcon('copy')}</button><button class="button secondary transfer-button" data-action="transfer" aria-label="Импорт и экспорт">${uiIcon('upload')}<span>Импорт / экспорт</span></button></div></div>`;
}

function renderWorkspaceTabs() {
  return `<div class="workspace-navigation"><div class="tabbar" role="tablist" aria-label="Редактор сборки">${WORKSPACE_TABS.map(([id, icon, label]) => `<button role="tab" id="tab-${id}" aria-controls="workspace-panel" tabindex="${state.tab === id ? '0' : '-1'}" aria-selected="${state.tab === id}" data-tab="${id}">${uiIcon(icon)}${label}</button>`).join('')}</div><button class="stats-toggle" data-action="toggle-stats" aria-expanded="${state.statsVisible}" aria-controls="build-inspector">${uiIcon('chart')}Показатели</button></div>`;
}

function renderEditor() {
  const renderers = { tree: renderFullTree, items: renderItems, skills: renderSkills, config: renderConfig, calcs: renderCalculations };
  return renderers[state.tab]();
}

function renderInspector() {
  const build = currentBuild();
  const values = selectedReportValues(build);
  const pins = build.pinnedStats || ['Life', 'EnergyShield', 'Mana', 'Spirit'];
  const source = build.fixture === 'ranger' ? 'Снимок PoB' : 'Демо';
  const changed = build.reportChanged ? 'Изменения ожидают расчёта Lua' : 'Lua не подключён';
  return `<aside class="build-inspector ${state.statsVisible ? 'is-open' : ''}" id="build-inspector" aria-label="Показатели сборки"><div class="inspector-heading"><h2>Показатели</h2><div><button class="icon-button" data-action="pin-stats" aria-label="Настроить важные показатели" title="Настроить показатели">${uiIcon('settings')}</button><button class="icon-button inspector-close" data-action="close-stats" aria-label="Закрыть показатели">${uiIcon('close')}</button></div></div>
    <div class="inspector-summary"><button class="skill-picker" data-action="skill-options"><span><small>Основное умение</small><strong>${escapeHtml(selectedSkillName())}</strong></span>${uiIcon('chevron')}</button>
      <button class="primary-stat" data-stat="TotalDPS"><span>Урон в секунду</span><strong>${displayValue(values.TotalDPS)}</strong><small>${build.skillPart === 'hit' ? 'Попадания' : 'Вторичный эффект'} · ${source}</small></button>
      <div class="pinned-stats">${pins.map(id => `<button data-stat="${id}"><span>${STAT_INDEX[id][1]}</span><strong>${displayValue(values[id])}<small>${values[id] ? STAT_INDEX[id][2] : ''}</small></strong></button>`).join('')}</div>
    </div><button class="inspector-warnings" data-action="warnings">${uiIcon('info')}<span>${changed}</span>${uiIcon('chevron')}</button><div class="inspector-scroll">${REPORT_GROUPS.map(group => renderStatGroup(group, values)).join('')}</div><div class="inspector-footnote">${build.fixture === 'ranger' ? 'Данные вашего скриншота' : 'Демонстрационные данные'} · без пересчёта</div></aside>`;
}

function displayValue(value) { return value === undefined ? '—' : escapeHtml(value); }

function selectedReportValues(build) {
  const values = { ...reportValues(build) };
  if (build.skillGroup !== 'main' || build.skillPart !== 'hit') REPORT_GROUPS[0].rows.forEach(([key]) => delete values[key]);
  return values;
}

function selectedSkillName() {
  return { main: currentDemo()?.skill || 'Не выбрано', movement: 'Передвижение', buff: 'Длительный эффект' }[currentBuild().skillGroup];
}

function renderStatGroup(group, values, expanded = false) {
  const open = expanded || state.openGroups.has(group.id);
  return `<details class="stat-group" data-stat-group="${group.id}" ${open ? 'open' : ''}><summary>${uiIcon(group.icon)}<span>${group.title}</span>${uiIcon('chevron')}</summary><div class="stat-rows">${group.rows.map(row => renderStatRow(row, values)).join('')}</div></details>`;
}

function renderStatRow([id, label, unit], values) {
  return `<button class="stat-row" data-stat="${id}"><span>${label}</span><strong>${displayValue(values[id])}<small>${values[id] ? unit : ''}</small></strong></button>`;
}

function renderFullTree() {
  return `<section class="tree-editor">${renderTreeCommands()}<div class="tree-card"><div class="tree-canvas">${renderTree()}</div><div class="tree-selection"><button data-action="node-details" id="node-label">Выберите узел, чтобы посмотреть детали</button><span class="tree-count">${currentNodes().length} выбрано</span></div></div>${renderPointCounters()}</section>`;
}

function renderTreeCommands() {
  const build = currentBuild();
  const history = currentHistory();
  return `<div class="tree-commands"><label class="tree-search">${uiIcon('search')}<input id="tree-search" type="search" aria-label="Поиск по дереву" placeholder="Найти в дереве" value="${escapeHtml(state.treeQuery)}"><span id="tree-search-count" aria-live="polite"></span></label>
    <select id="tree-set" aria-label="Вариант дерева">${selectOptions(TREE_SETS, build.treeSet)}</select>
    <div class="tree-tool-buttons"><button class="icon-button" data-action="undo-tree" aria-label="Отменить выбор узлов" title="Отменить" ${history.past.length ? '' : 'disabled'}>${uiIcon('back')}</button><button class="icon-button redo-button" data-action="redo-tree" aria-label="Повторить выбор узлов" title="Повторить" ${history.future.length ? '' : 'disabled'}>${uiIcon('back')}</button><button class="icon-button" data-action="zoom-out" aria-label="Уменьшить дерево">${uiIcon('minus')}</button><button class="icon-button" data-action="zoom-in" aria-label="Увеличить дерево">${uiIcon('plus')}</button><button class="icon-button" data-action="zoom-reset" aria-label="Поместить дерево целиком" title="Дерево целиком">${uiIcon('fit')}</button></div>
    <details class="tree-options"><summary aria-label="Настройки дерева" title="Настройки дерева">···</summary><div class="tree-options-menu"><h3>Настройки дерева</h3><label class="field">Набор оружия<select id="weapon-set">${selectOptions(WEAPON_SETS, build.weaponSet)}</select></label><label class="field">Версия дерева<select id="tree-version"><option>0.5 · пример со скриншота</option></select></label><label class="plain-check"><input type="checkbox" id="compare-tree" ${state.compareTree ? 'checked' : ''}>Сравнить с другим вариантом</label><label class="plain-check"><input type="checkbox" id="node-power" ${state.nodePower ? 'checked' : ''}>Показать силу узлов</label><p>Подсветка в прототипе иллюстративная.</p><button class="text-link danger-link" data-action="confirm-reset">Сбросить выбранный вариант</button></div></details></div>`;
}

function renderPointCounters() {
  const counts = currentBuild().fixture === 'ranger' ? ['123 / 123', '0 / 24', '0 / 24', '8 / 8'] : ['—', '—', '—', '—'];
  const labels = ['Дерево', 'Оружие I', 'Оружие II', 'Восхождение'];
  return `<div class="tree-bottom"><div class="point-counters">${labels.map((label, index) => `<span title="Показатель из снимка, в прототипе не пересчитывается"><small>${label}</small><b>${counts[index]}</b></span>`).join('')}</div><div class="tree-view-state" id="tree-view-state">${treeViewDescription()}</div></div>`;
}

function treeViewDescription() {
  if (state.compareTree) return 'Контуром — другой вариант';
  if (state.nodePower) return 'Сила узлов · пример подсветки';
  return 'Схема макета · не игровое дерево';
}

function treeGeometry() {
  const clusters = [[320, 186], [210, 128], [425, 104], [471, 255], [336, 315], [161, 274], [121, 81], [531, 133], [235, 365]];
  return clusters.flatMap(([cx, cy], cluster) => Array.from({ length: 10 }, (_, index) => {
    const angle = (index * 40 + cluster * 13) * Math.PI / 180;
    const radius = index === 0 ? 0 : 39;
    return { id: cluster * 10 + index, x: cx + Math.cos(angle) * radius, y: cy + Math.sin(angle) * radius, cluster, large: index === 0, name: NODE_LABELS[cluster] };
  }));
}

function renderTree() {
  const points = treeGeometry();
  const selected = new Set(currentNodes());
  const links = points.filter(point => !point.large).map(point => treeLine(points[point.cluster * 10], point, selected)).join('');
  const bridges = [[0, 10], [0, 20], [0, 30], [0, 40], [0, 50], [10, 60], [20, 70], [40, 80], [50, 80], [20, 30]].map(([a, b]) => treeLine(points[a], points[b], selected)).join('');
  return `<svg class="tree-svg" viewBox="0 0 640 420" aria-label="Демонстрационная схема дерева развития"><g class="tree-scene"><circle class="tree-orbit" cx="320" cy="200" r="155"/><ellipse class="tree-orbit" cx="320" cy="200" rx="270" ry="125" transform="rotate(-25 320 200)"/>${links}${bridges}${points.map(point => renderTreeNode(point, selected)).join('')}</g></svg>`;
}

function renderTreeNode(point, selected) {
  return `<g role="button" tabindex="0" aria-label="${point.name}, узел ${point.id + 1}" aria-pressed="${selected.has(point.id)}" class="tree-node ${point.large ? 'large' : ''} ${selected.has(point.id) ? 'selected' : ''}" data-node="${point.id}" data-node-name="${point.name}" transform="translate(${point.x.toFixed(2)} ${point.y.toFixed(2)})"><circle class="node-hit" r="13" fill="transparent"/><circle class="node-halo" r="15"/><circle class="comparison-ring" r="${point.large ? 17 : 9}"/><circle class="node-body" r="${point.large ? 11 : 4.5}"/>${point.large ? '<path class="node-dot" d="m0-5 2 3 3 2-3 2-2 3-2-3-3-2 3-2Z"/>' : '<circle class="node-dot" r="1.2"/>'}</g>`;
}

function treeLine(a, b, selected) {
  return `<line class="tree-link ${selected.has(a.id) && selected.has(b.id) ? 'lit' : ''}" data-edge="${a.id},${b.id}" x1="${a.x.toFixed(2)}" y1="${a.y.toFixed(2)}" x2="${b.x.toFixed(2)}" y2="${b.y.toFixed(2)}"/>`;
}

function currentHistory() {
  const key = `${currentBuild().id}:${currentBuild().treeSet}`;
  if (!treeHistory.has(key)) treeHistory.set(key, { past: [], future: [] });
  return treeHistory.get(key);
}

function rememberNodes() {
  const history = currentHistory();
  history.past.push([...currentNodes()]);
  history.past = history.past.slice(-50);
  history.future = [];
}

function selectNode(id) {
  rememberNodes();
  const nodes = currentNodes();
  setCurrentNodes(nodes.includes(id) ? nodes.filter(node => node !== id) : [...nodes, id]);
  state.selectedNode = id;
  refreshNodes();
  persist();
}

function restoreNodes(direction) {
  const history = currentHistory();
  const source = direction === 'undo' ? history.past : history.future;
  const destination = direction === 'undo' ? history.future : history.past;
  if (!source.length) return;
  destination.push([...currentNodes()]);
  setCurrentNodes(source.pop());
  state.selectedNode = null;
  refreshNodes();
  persist();
}

function refreshNodes() {
  const selected = new Set(currentNodes());
  const build = currentBuild();
  const comparison = new Set(build.treeSet === 'main' ? build.alternativeNodes : build.nodes);
  const query = state.treeQuery.trim().toLocaleLowerCase('ru');
  let matches = 0;
  page.querySelectorAll('[data-node]').forEach(node => {
    const id = Number(node.dataset.node);
    const match = query && node.dataset.nodeName.toLocaleLowerCase('ru').includes(query);
    if (match) matches++;
    node.classList.toggle('selected', selected.has(id));
    node.classList.toggle('compared', state.compareTree && comparison.has(id));
    node.classList.toggle('search-match', Boolean(match));
    node.classList.toggle('search-dim', Boolean(query && !match));
    node.classList.toggle('power-example', state.nodePower && [10, 21, 30, 42, 60, 71].includes(id));
    node.setAttribute('aria-pressed', String(selected.has(id)));
  });
  page.querySelectorAll('[data-edge]').forEach(edge => edge.classList.toggle('lit', edge.dataset.edge.split(',').every(id => selected.has(Number(id)))));
  const searchCount = page.querySelector('#tree-search-count');
  if (searchCount) searchCount.textContent = query ? matches : '';
  const count = page.querySelector('.tree-count');
  if (count) count.textContent = `${selected.size} выбрано`;
  const label = page.querySelector('#node-label');
  if (label) label.textContent = state.selectedNode === null ? 'Выберите узел, чтобы посмотреть детали' : `${NODE_LABELS[Math.floor(state.selectedNode / 10)]} · узел ${state.selectedNode + 1} · ${selected.has(state.selectedNode) ? 'выбран' : 'снят'}`;
  refreshHistoryButtons();
  refreshReportStatus();
}

function refreshHistoryButtons() {
  const history = currentHistory();
  const undo = page.querySelector('[data-action="undo-tree"]');
  const redo = page.querySelector('[data-action="redo-tree"]');
  if (undo) undo.disabled = !history.past.length;
  if (redo) redo.disabled = !history.future.length;
}

function zoomTree(delta) {
  state.zoom = delta === 0 ? 1 : Math.max(.65, Math.min(2.4, state.zoom + delta));
  if (delta === 0) state.pan = { x: 0, y: 0 };
  applyTreeTransform();
}

function applyTreeTransform() {
  const scene = page.querySelector('.tree-scene');
  if (scene) scene.style.transform = `translate(${state.pan.x}px, ${state.pan.y}px) scale(${state.zoom})`;
}

function renderSkills() {
  const skill = currentDemo()?.skill;
  if (!skill) return `<div class="editor-note">${uiIcon('gem')}<h2>Найдите свою комбинацию</h2><p>Выберите умение из каталога после подключения Lua.</p></div>`;
  return `<div class="editor-section-heading"><h2>Группы умений</h2><button class="button secondary" data-action="skill-options">Выбрать для расчёта</button></div><div class="skill-groups"><button class="skill-group-card ${currentBuild().skillGroup === 'main' ? 'active' : ''}" data-skill-group="main"><span class="gem-art">${uiIcon('gem')}</span><span><strong>${escapeHtml(skill)}</strong><small>Основное умение</small></span>${uiIcon('check')}</button><button class="skill-group-card" data-skill-group="movement"><span class="gem-art">${uiIcon('arrow')}</span><span><strong>Передвижение</strong><small>Пример дополнительной группы</small></span>${uiIcon('chevron')}</button></div><div class="subtle-panel"><h3>Камни поддержки</h3><p>${currentBuild().fixture === 'ranger' ? 'Камни поддержки не видны на исходном скриншоте. Их состав здесь не предполагается.' : 'Каталог камней и совместимость поддержек будут доступны через Lua.'}</p></div>`;
}

function renderCalculations() {
  const values = selectedReportValues(currentBuild());
  const source = currentBuild().fixture === 'ranger' ? 'Значения со скриншота PoB' : 'Демонстрационный отчёт';
  return `<div class="editor-section-heading"><div><h2>Расчёты</h2><p>${source}</p></div><button class="button secondary" data-action="compare-builds">${uiIcon('copy')}Сравнить</button></div><div class="report-notice">${uiIcon('info')}<span>Это сохранённый пример отчёта. Для пересчёта изменений нужен Lua.</span><button class="text-link" data-action="warnings">Предупреждения ${uiIcon('arrow')}</button></div><div class="report-cards">${REPORT_GROUPS.map(group => `<section class="report-card"><h3>${uiIcon(group.icon)}${group.title}</h3>${group.rows.map(row => renderStatRow(row, values)).join('')}</section>`).join('')}</div>`;
}

function refreshReportStatus() {
  const status = page.querySelector('.inspector-warnings span');
  if (status) status.textContent = currentBuild().reportChanged ? 'Изменения ожидают расчёта Lua' : 'Lua не подключён';
}

function refreshWorkspace() {
  const inspector = page.querySelector('.inspector-scroll');
  if (inspector) state.inspectorScroll = inspector.scrollTop;
  render();
}

function afterWorkspaceRender() {
  if (state.page !== 'workspace') {
    state.statsVisible = false;
    syncInspectorAccess();
    return;
  }
  const inspector = page.querySelector('.inspector-scroll');
  if (inspector) inspector.scrollTop = state.inspectorScroll;
  refreshNodes();
  applyTreeTransform();
  syncInspectorAccess();
}

function syncInspectorAccess() {
  const inspector = page.querySelector('.build-inspector');
  const narrow = window.matchMedia('(max-width: 1100px)').matches;
  const modal = Boolean(inspector && narrow && state.statsVisible);
  if (inspector) {
    inspector.inert = narrow && !state.statsVisible;
    if (modal) { inspector.setAttribute('role', 'dialog'); inspector.setAttribute('aria-modal', 'true'); }
    else { inspector.removeAttribute('role'); inspector.removeAttribute('aria-modal'); }
  }
  document.querySelectorAll('.sidebar, .topbar, .workspace-heading, .workspace-navigation, .workspace-pane').forEach(element => { element.inert = modal; });
}

function toggleStats(show = !state.statsVisible) {
  state.statsVisible = show;
  page.querySelector('.build-inspector')?.classList.toggle('is-open', show);
  const backdrop = page.querySelector('.inspector-backdrop');
  if (backdrop) backdrop.hidden = !show;
  page.querySelector('.stats-toggle')?.setAttribute('aria-expanded', String(show));
  syncInspectorAccess();
  if (show) page.querySelector('.inspector-close')?.focus();
  else page.querySelector('.stats-toggle')?.focus();
}

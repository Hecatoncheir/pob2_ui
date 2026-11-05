function openWorkspaceDialog(title, content) {
  const dialog = document.getElementById('workspace-dialog');
  document.getElementById('workspace-dialog-title').textContent = title;
  document.getElementById('workspace-dialog-content').innerHTML = content;
  if (!dialog.open) dialog.showModal();
  dialog.querySelector('[autofocus]')?.focus();
}

function openCharacter() {
  const build = currentBuild();
  openWorkspaceDialog('Персонаж', `<form id="character-form"><label class="field">Класс<select id="character-class" name="className">${selectOptions(Object.fromEntries(CLASSES.map(name => [name, name])), build.className)}</select></label><div class="form-row"><label class="field">Восхождение<select name="ascendancy" id="character-ascendancy">${ascendancyOptions(build.className, build.ascendancy)}</select></label><label class="field">Уровень<input name="level" type="number" min="1" max="100" value="${build.level}" required></label></div><p class="form-note">Каталог в макете сокращён. Изменённому персонажу потребуется новый расчёт Lua.</p><div class="form-actions"><button class="button" type="submit">Применить</button></div></form>`);
}

function ascendancyOptions(className, selected) {
  const examples = ASCENDANCY_EXAMPLES[className] || [];
  return selectOptions({ '': 'Не выбрано', ...Object.fromEntries(examples.map(name => [name, name])) }, selected);
}

function openRename(copy = false) {
  const name = copy ? `${currentBuild().name} · копия`.slice(0, 60) : currentBuild().name;
  openWorkspaceDialog(copy ? 'Сохранить копию' : 'Название сборки', `<form id="rename-form" data-copy="${copy}"><label class="field">Название<input name="name" value="${escapeHtml(name)}" maxlength="60" required autofocus></label><div class="form-actions"><button class="button" type="submit">${copy ? 'Создать копию' : 'Сохранить'}</button></div></form>`);
}

function openSkillOptions() {
  const build = currentBuild();
  const groups = { main: currentDemo()?.skill || 'Основное умение', movement: 'Передвижение', buff: 'Длительный эффект' };
  openWorkspaceDialog('Умение для расчёта', `<form id="skill-options-form"><label class="field">Группа умений<select name="group">${selectOptions(groups, build.skillGroup)}</select></label><label class="field">Часть умения<select name="part">${selectOptions(PART_OPTIONS, build.skillPart)}</select></label><p class="form-note">Для групп и частей, которых нет в снимке, урон показывается прочерком.</p><div class="form-actions"><button class="button" type="submit">Выбрать</button></div></form>`);
}

function openStatDetails(id) {
  const row = STAT_INDEX[id];
  if (!row) return;
  const values = selectedReportValues(currentBuild());
  const source = currentBuild().fixture === 'ranger' ? 'Число перенесено с присланного скриншота PoB.' : 'Демонстрационные данные макета.';
  openWorkspaceDialog(row[1], `<div class="stat-detail-value">${displayValue(values[id])}<small>${values[id] ? row[2] : ''}</small></div><p>${source} Изменения в прототипе не пересчитывают показатели.</p><div class="subtle-panel"><h3>Из чего складывается показатель</h3><p>Здесь будет объяснение из отчёта оригинального Lua: вклад предметов, дерева, умений и действующих условий.</p></div><details class="technical-detail"><summary>Поле отчёта</summary><code>${id}</code><p>Привязку к API и доступность подробного отчёта нужно проверить при переносе во Flutter.</p></details>`);
}

function openPinSettings() {
  const pins = currentBuild().pinnedStats;
  const choices = ['Life', 'EnergyShield', 'Mana', 'Spirit', 'TotalEHP', 'Armour', 'EvadeChance', 'Dex'];
  openWorkspaceDialog('Важные показатели', `<form id="pin-stats-form"><p>Выберите от одного до шести показателей для постоянной панели.</p><div class="pin-choices">${choices.map(id => `<label class="plain-check"><input type="checkbox" name="stat" value="${id}" ${pins.includes(id) ? 'checked' : ''}>${STAT_INDEX[id][1]}</label>`).join('')}</div><p id="pin-error" class="error-text" role="alert"></p><div class="form-actions"><button class="button" type="submit">Сохранить</button></div></form>`);
}

function openWarnings() {
  const build = currentBuild();
  const notices = [noticeCard('info', 'Lua не подключён', 'Показатели сохранены как пример и не обновляются при редактировании.')];
  if (build.reportChanged) notices.push(noticeCard('warning', 'Есть изменения', 'Для текущего состояния сборки ещё нет нового расчёта.'));
  if (build.pendingXml) notices.push(noticeCard('warning', 'XML ожидает импорта', 'Файл подготовлен локально. Сборку должен прочитать исходный Lua PoB.'));
  openWorkspaceDialog('Состояние расчёта', `${notices.join('')}<details class="warning-examples"><summary>Как будут выглядеть ошибки сборки</summary>${noticeCard('warning', 'Пример: требования к предмету', 'Здесь появятся недостающие характеристики и ссылка на предмет.')}${noticeCard('warning', 'Пример: камень или модификатор', 'Здесь будет сообщение Lua об ошибке камня или неподдерживаемом эффекте.')}<p>Это образцы сообщений, а не найденные ошибки вашей сборки.</p></details>`);
}

function noticeCard(kind, title, text) {
  return `<div class="notice-card ${kind}">${uiIcon(kind === 'info' ? 'info' : 'shield')}<div><strong>${title}</strong><p>${text}</p></div></div>`;
}

function openNodeDetails() {
  if (state.selectedNode === null) { toast('Сначала выберите узел дерева'); return; }
  const name = NODE_LABELS[Math.floor(state.selectedNode / 10)];
  openWorkspaceDialog(name, `<span class="tag">Узел макета ${state.selectedNode + 1}</span><p class="node-description">В рабочем редакторе здесь будут свойства узла, стоимость пути и изменение показателей из Lua.</p><p>В прототипе узлы иллюстративные и не соответствуют игровому дереву.</p>`);
}

function confirmReset() {
  openWorkspaceDialog('Сбросить вариант дерева?', `<p>Будет очищен только «${TREE_SETS[currentBuild().treeSet]}». В прототипе действие можно отменить кнопкой со стрелкой.</p><div class="form-actions"><button class="button secondary" data-close>Отмена</button><button class="button" data-action="reset-nodes">Сбросить</button></div>`);
}

function resetNodes() {
  rememberNodes();
  setCurrentNodes([]);
  state.selectedNode = null;
  document.getElementById('workspace-dialog').close();
  page.querySelector('.tree-options')?.removeAttribute('open');
  refreshNodes();
  persist();
}

function openTransfer(mode = 'json') {
  document.getElementById('import-dialog').close();
  const tabs = `<div class="transfer-tabs"><button data-transfer="json" aria-pressed="${mode === 'json'}">Файл прототипа</button><button data-transfer="xml" aria-pressed="${mode === 'xml'}">XML PoB</button></div>`;
  const content = mode === 'json' ? `<p>Сохраните свою идею или откройте JSON, экспортированный из этого прототипа.</p><label class="field">Открыть файл<input type="file" id="import-file" accept="application/json,.json"></label><p id="import-error" class="error-text" role="alert"></p><button class="button" data-action="export">${uiIcon('upload')}Экспортировать JSON</button>` : `<p>Подготовьте XML для импорта в приложение. Прототип сохранит текст локально до подключения Lua.</p><label class="field">Файл XML<input type="file" id="xml-file" accept=".xml,text/xml,application/xml"></label><label class="field xml-field">Или вставьте XML<textarea id="pending-xml" rows="5" maxlength="2000000" placeholder="&lt;PathOfBuilding2&gt;…&lt;/PathOfBuilding2&gt;">${escapeHtml(currentBuild().pendingXml)}</textarea></label><p id="xml-error" class="error-text" role="alert"></p><button class="button" data-action="stage-xml">Подготовить импорт</button><p class="transfer-note">Импорт в сборку и экспорт XML выполняются только через Lua.</p>`;
  openWorkspaceDialog('Импорт и экспорт', tabs + `<div class="transfer-content">${content}</div>`);
}

function stageXml() {
  const raw = document.getElementById('pending-xml').value.trim();
  const error = document.getElementById('xml-error');
  if (!raw) { error.textContent = 'Добавьте XML сборки.'; return; }
  const parsed = new DOMParser().parseFromString(raw, 'application/xml');
  const correctRoot = ['PathOfBuilding', 'PathOfBuilding2'].includes(parsed.documentElement.nodeName);
  if (parsed.querySelector('parsererror') || !correctRoot) { error.textContent = 'Нужен корректный XML Path of Building.'; return; }
  currentBuild().pendingXml = raw;
  persist();
  document.getElementById('workspace-dialog').close();
  toast('XML подготовлен · для импорта нужен Lua');
}

function openBuildComparison() {
  const builds = state.builds.filter(build => build.id !== currentBuild().id);
  if (!builds.length) { toast('Для сравнения нужна ещё одна сборка'); return; }
  state.compareBuildId = builds.some(build => build.id === state.compareBuildId) ? state.compareBuildId : builds[0].id;
  openWorkspaceDialog('Сравнить сборки', `<label class="field">Сравнить с<select id="compare-build-select">${selectOptions(Object.fromEntries(builds.map(build => [build.id, build.name])), state.compareBuildId)}</select></label><div id="build-comparison">${renderBuildComparison()}</div>`);
}

function renderBuildComparison() {
  const other = state.builds.find(build => build.id === state.compareBuildId);
  const left = reportValues(currentBuild());
  const right = reportValues(other);
  const rows = ['TotalDPS', 'Life', 'EnergyShield', 'Mana', 'Spirit', 'TotalEHP', 'Armour', 'EvadeChance'];
  return `<div class="comparison-head"><span>Показатель</span><span>Текущая</span><span>Выбранная</span></div>${rows.map(id => `<div class="comparison-row"><span>${STAT_INDEX[id][1]}</span><b>${displayValue(left[id])}</b><b>${displayValue(right[id])}</b></div>`).join('')}<p class="transfer-note">Сравнение сохранённых примеров. Условия расчёта могут различаться; пересчёт не выполняется.</p>`;
}

const workspaceActions = {
  character: openCharacter, rename: () => openRename(), 'copy-build': () => openRename(true),
  'skill-options': openSkillOptions, 'pin-stats': openPinSettings, warnings: openWarnings,
  'node-details': openNodeDetails, 'confirm-reset': confirmReset, 'reset-nodes': resetNodes,
  'undo-tree': () => restoreNodes('undo'), 'redo-tree': () => restoreNodes('redo'),
  transfer: () => openTransfer(), 'stage-xml': stageXml, 'compare-builds': openBuildComparison,
  'toggle-stats': () => toggleStats(), 'close-stats': () => toggleStats(false)
};

function saveWorkspaceForm(event) {
  const handler = workspaceForms[event.target.id];
  if (!handler) return;
  event.preventDefault();
  handler(new FormData(event.target), event.target);
}

const workspaceForms = {
  'character-form': form => {
    const build = currentBuild();
    const character = { className: form.get('className'), ascendancy: form.get('ascendancy'), level: Number(form.get('level')) };
    const changed = Object.entries(character).some(([key, value]) => build[key] !== value);
    Object.assign(build, character);
    if (changed) { build.fixture = null; build.reportChanged = true; }
    finishWorkspaceForm('Персонаж сохранён');
  },
  'rename-form': (form, element) => {
    const name = String(form.get('name')).trim();
    if (!name) return;
    if (element.dataset.copy === 'true') {
      const copy = validBuild({ ...structuredClone(currentBuild()), id: createId(), name, updated: Date.now() });
      state.builds.unshift(copy);
      state.activeId = copy.id;
    } else currentBuild().name = name;
    finishWorkspaceForm('Сохранено');
  },
  'skill-options-form': form => {
    currentBuild().skillGroup = form.get('group');
    currentBuild().skillPart = form.get('part');
    finishWorkspaceForm('Умение выбрано');
  },
  'pin-stats-form': form => {
    const pins = form.getAll('stat');
    if (!pins.length || pins.length > 6) { document.getElementById('pin-error').textContent = 'Выберите от одного до шести показателей.'; return; }
    currentBuild().pinnedStats = pins;
    finishWorkspaceForm('Панель настроена');
  }
};

function finishWorkspaceForm(message) {
  persist();
  document.getElementById('workspace-dialog').close();
  refreshWorkspace();
  toast(message);
}

function changeTreeOption(key, value) {
  currentBuild()[key] = value;
  state.selectedNode = null;
  persist();
  refreshWorkspace();
}

const workspaceChanges = {
  'tree-set': element => changeTreeOption('treeSet', element.value),
  'weapon-set': element => { currentBuild().reportChanged = true; changeTreeOption('weaponSet', element.value); },
  'compare-tree': element => { state.compareTree = element.checked; refreshTreeView(); },
  'node-power': element => { state.nodePower = element.checked; refreshTreeView(); },
  'character-class': element => { document.getElementById('character-ascendancy').innerHTML = ascendancyOptions(element.value, ''); },
  'compare-build-select': element => { state.compareBuildId = element.value; document.getElementById('build-comparison').innerHTML = renderBuildComparison(); },
  'party-enabled': element => { currentBuild().party = element.checked; currentBuild().reportChanged = true; persist(); refreshReportStatus(); },
  'xml-file': async element => {
    const file = element.files[0];
    if (!file) return;
    if (file.size > 2000000) { document.getElementById('xml-error').textContent = 'Максимальный размер XML — 2 МБ.'; return; }
    document.getElementById('pending-xml').value = await file.text();
  }
};

function refreshTreeView() {
  refreshNodes();
  page.querySelector('#tree-view-state').textContent = treeViewDescription();
}

document.addEventListener('submit', saveWorkspaceForm);
document.addEventListener('click', event => {
  const stat = event.target.closest('[data-stat]');
  if (stat) openStatDetails(stat.dataset.stat);
  const transfer = event.target.closest('[data-transfer]');
  if (transfer) openTransfer(transfer.dataset.transfer);
  const skill = event.target.closest('[data-skill-group]');
  if (skill) { currentBuild().skillGroup = skill.dataset.skillGroup; currentBuild().skillPart = 'hit'; persist(); refreshWorkspace(); }
});
document.addEventListener('change', event => workspaceChanges[event.target.id]?.(event.target));
document.addEventListener('input', event => {
  if (event.target.id === 'tree-search') { state.treeQuery = event.target.value; refreshNodes(); }
});
document.addEventListener('toggle', event => {
  if (!event.target.matches('.inspector-scroll [data-stat-group]')) return;
  const id = event.target.dataset.statGroup;
  if (event.target.open) state.openGroups.add(id);
  else state.openGroups.delete(id);
}, true);
document.addEventListener('keydown', event => {
  if (event.key === 'Escape' && state.statsVisible && !document.querySelector('dialog[open]')) toggleStats(false);
  if (event.key !== 'Tab' || !state.statsVisible || document.querySelector('dialog[open]')) return;
  const inspector = page.querySelector('.build-inspector[aria-modal=true]');
  if (!inspector) return;
  const controls = [...inspector.querySelectorAll('button, select, input, summary')].filter(element => element.offsetParent !== null);
  const first = controls[0];
  const last = controls[controls.length - 1];
  if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
  if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
});
window.matchMedia('(max-width: 1100px)').addEventListener('change', syncInspectorAccess);

let treeDrag;
document.addEventListener('pointerdown', event => {
  const canvas = event.target.closest('.tree-canvas');
  if (!canvas || event.target.closest('[data-node]') || event.button !== 0) return;
  treeDrag = { id: event.pointerId, x: event.clientX, y: event.clientY, start: { ...state.pan }, scale: 640 / canvas.clientWidth };
  canvas.setPointerCapture(event.pointerId);
  canvas.classList.add('is-dragging');
});
document.addEventListener('pointermove', event => {
  if (!treeDrag || treeDrag.id !== event.pointerId) return;
  state.pan = { x: treeDrag.start.x + (event.clientX - treeDrag.x) * treeDrag.scale, y: treeDrag.start.y + (event.clientY - treeDrag.y) * treeDrag.scale };
  applyTreeTransform();
});
function endTreeDrag() { treeDrag = null; page.querySelector('.is-dragging')?.classList.remove('is-dragging'); }
document.addEventListener('pointerup', endTreeDrag);
document.addEventListener('pointercancel', endTreeDrag);

// Примеры оформления. Значения со скриншота находятся отдельно в workspace-data.js; игровых формул здесь нет.
const DEMO = {
  ranger: { skill: 'Shattering Concoction', subtitle: 'Умение со скриншота', items: null },
  ember: { stats: ['1,24', '3 840', '2 160', '68'], skill: 'Огненный шар', subtitle: 'Снаряд · огонь', icon: 'gem', items: ['Посох тлеющего рассвета', 'Мантия тихого пламени', 'Печать уголька'], resist: ['75%', '75%', '75%', '32%'] },
  frost: { stats: ['846', '2 920', '4 180', '54'], skill: 'Ледяная волна', subtitle: 'Заклинание · холод', icon: 'gem', items: ['Жезл зимнего света', 'Облачение инея', 'Кольцо холодной луны'], resist: ['75%', '75%', '75%', '25%'] },
  monk: { stats: ['928', '3 210', '1 420', '72'], skill: 'Удар бури', subtitle: 'Атака · молния', icon: 'sword', items: ['Боевой посох грозы', 'Одежды странника', 'Кольцо ветра'], resist: ['75%', '75%', '75%', '40%'] }
};
const CLASSES = ['Ranger', 'Ведьма', 'Воин', 'Монах', 'Наёмник', 'Охотница', 'Волшебница'];
const STORAGE_KEY = 'pob2-design-v1';
const initialBuilds = [
  screenshotBuild(),
  { id: 'ember', name: 'Искра и пепел', className: 'Ведьма', level: 90, fixture: 'ember', updated: 3, nodes: [0, 1, 2, 3, 4, 5, 10, 11, 12], notes: '', config: {} },
  { id: 'frost', name: 'Тихая зима', className: 'Волшебница', level: 88, fixture: 'frost', updated: 2, nodes: [0, 8, 9, 10, 18, 19], notes: '', config: {} },
  { id: 'monk', name: 'Голос бури', className: 'Монах', level: 92, fixture: 'monk', updated: 1, nodes: [0, 20, 21, 22, 30], notes: '', config: {} }
];
const state = { builds: [], activeId: 'ranger', page: 'workspace', tab: 'tree', query: '', sort: 'recent', zoom: 1, selectedNode: null, motion: true, treeQuery: '', compareTree: false, nodePower: false, pan: { x: 0, y: 0 }, statsVisible: false, inspectorScroll: 0, openGroups: new Set(), compareBuildId: null };
const page = document.getElementById('page');
let toastTimer;
let storageAvailable = true;

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, character => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[character]);
}

function createId() { return `build-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`; }
function currentBuild() { return state.builds.find(build => build.id === state.activeId) || state.builds[0]; }
function currentDemo() { return DEMO[currentBuild()?.fixture]; }
function hydrateIcons(root = document) {
  root.querySelectorAll('[data-icon]').forEach(element => { element.innerHTML = uiIcon(element.dataset.icon); });
}

function loadState() {
  try {
    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY));
    if (!stored || stored.version !== 1 || !Array.isArray(stored.builds)) return;
    state.builds = stored.builds.slice(0, 100).map(validBuild);
    state.activeId = stored.activeId;
    state.motion = stored.motion !== false;
  } catch { /* Повреждённое хранилище не мешает открыть демонстрацию. */ }
}

function persist() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({ version: 1, builds: state.builds, activeId: state.activeId, motion: state.motion }));
  } catch {
    storageAvailable = false;
    const label = page.querySelector('.save-label');
    if (label) label.textContent = 'В памяти';
    document.getElementById('save-status').textContent = 'ХРАНИЛИЩЕ НЕДОСТУПНО · ИЗМЕНЕНИЯ В ПАМЯТИ';
    toast('Браузер не разрешает сохранение. Используйте экспорт.');
  }
}

function toast(message) {
  const element = document.getElementById('toast');
  clearTimeout(toastTimer);
  element.textContent = message;
  element.classList.add('visible');
  toastTimer = setTimeout(() => element.classList.remove('visible'), 3400);
}

function updateRecent() {
  document.getElementById('build-count').textContent = state.builds.length;
  document.getElementById('recent-builds').innerHTML = [...state.builds].sort((a, b) => b.updated - a.updated).slice(0, 3).map(build =>
    `<button class="recent-item ${build.id === state.activeId ? 'active' : ''}" data-build="${escapeHtml(build.id)}"><span class="dot"></span>${escapeHtml(build.name)}</button>`).join('');
}

function navigate(nextPage, nextTab = state.tab) {
  state.page = nextPage;
  state.tab = nextTab === 'overview' ? 'tree' : nextTab;
  state.selectedNode = null;
  render();
  page.scrollTop = 0;
}

function render() {
  page.classList.toggle('workspace-open', state.page === 'workspace');
  const renderers = { workspace: renderWorkspace, library: renderLibrary, components: renderComponents };
  page.innerHTML = `<div class="page-content">${renderers[state.page]()}</div>`;
  document.getElementById('breadcrumb').textContent = { workspace: 'Сборка', library: 'Мои сборки', components: 'Компоненты' }[state.page];
  document.querySelectorAll('.app-nav [data-page]').forEach(button => {
    if (button.dataset.page === state.page) button.setAttribute('aria-current', 'page');
    else button.removeAttribute('aria-current');
  });
  updateRecent();
  afterWorkspaceRender();
}

function renderLibrary() {
  return `<div class="page-heading"><div><p class="eyebrow" style="margin-bottom:12px">ВАШЕ ПРОСТРАНСТВО ДЛЯ ИДЕЙ</p><h1>Мои сборки</h1></div><div class="heading-actions"><button class="button secondary" data-action="import" aria-label="Импортировать сборку">${uiIcon('download')}<span class="action-label">Импорт</span></button><button class="button" data-action="new" aria-label="Новая сборка">${uiIcon('plus')}<span class="action-label">Новая сборка</span></button></div></div><div class="library-tools"><label class="search-field">${uiIcon('search')}<input id="build-search" type="search" placeholder="Найти сборку" aria-label="Найти сборку" value="${escapeHtml(state.query)}"></label><select class="sort-select" id="build-sort" aria-label="Порядок сборок"><option value="recent" ${state.sort === 'recent' ? 'selected' : ''}>По последним</option><option value="name" ${state.sort === 'name' ? 'selected' : ''}>По названию</option><option value="level" ${state.sort === 'level' ? 'selected' : ''}>По уровню</option></select></div><div id="build-grid" class="build-grid">${renderBuildCards()}</div><p class="page-bottom-note">${uiIcon('info')}Снимок PoB и примеры оформления. Ваши идеи сохраняются в этом браузере.</p>`;
}

function renderBuildCards() {
  const builds = state.builds.filter(build => `${build.name} ${build.className}`.toLocaleLowerCase('ru').includes(state.query.toLocaleLowerCase('ru')));
  const comparators = { name: (a, b) => a.name.localeCompare(b.name, 'ru'), level: (a, b) => b.level - a.level, recent: (a, b) => b.updated - a.updated };
  builds.sort(comparators[state.sort]);
  if (!builds.length) return `<div class="empty-state"><h2>Пока ничего</h2><p>${state.query ? 'Попробуйте другое название или класс.' : 'У каждой сборки есть первая искра.'}</p>${state.query ? '' : '<button class="button" data-action="new">Создать сборку</button>'}</div>`;
  return builds.map((build, index) => `<article class="build-card reveal" style="animation-delay:${Math.min(index * 65, 260)}ms"><div class="build-card-art">${build.fixture === 'ember' ? '<img src="assets/brand/mark.svg" alt="">' : uiIcon(build.fixture === 'monk' ? 'sword' : 'gem')}</div><button class="build-card-copy" data-build="${escapeHtml(build.id)}"><h2>${escapeHtml(build.name)}</h2><p>${escapeHtml(build.className)} · Уровень ${build.level}</p><div class="build-card-footer"><span class="mono">${build.fixture ? 'ДЕМОНСТРАЦИЯ' : 'ВАША ИДЕЯ'}</span>${uiIcon('arrow')}</div></button></article>`).join('');
}

function emptyLibrary() { return `<div class="empty-state"><h2>Начните с искры</h2><p>Создайте первую сборку.</p><button class="button" data-action="new">Новая сборка</button></div>`; }

function renderComponents() {
  return `<div class="page-heading"><div><p class="eyebrow" style="margin-bottom:12px">ОСНОВА МАСТЕРСКОЙ</p><h1>Компоненты</h1></div><button class="button secondary" data-action="check" id="check-button">${uiIcon('refresh')}<span class="action-label">Проверить</span></button></div><p class="component-intro">Два компонента — одна рабочая среда.<br>Интерфейс отдельно. Расчёты — в оригинальном PoB.</p><div class="component-grid">${componentCard('pob', 'Path of Building', 'Движок Lua и игровые данные PoE 2')}${componentCard('mcp', 'MCP-адаптер', 'Связь интерфейса с локальным движком')}</div><div class="component-info">${uiIcon('shield')}<span id="component-status">Демонстрация установки. Файлы не загружаются, система не изменяется.</span></div><div class="component-actions"><button class="text-link" data-action="doctor">${uiIcon('check')}Проверить совместимость</button><button class="text-link" data-action="rollback">${uiIcon('back')}Предыдущая пара</button></div><p class="page-bottom-note">${uiIcon('info')}В приложении новая пара активируется после настоящей проверки Lua.</p>`;
}

function componentCard(id, name, description) {
  const illustration = id === 'pob' ? 'atlas' : 'components';
  return `<section class="component-card"><div class="component-art"><img src="assets/illustrations/${illustration}.svg" alt=""></div><h2>${name}</h2><p>${description}</p><div class="component-version"><span>Состояние</span><span class="mono" id="version-${id}">Не установлен · демо</span></div><button class="button" data-install="${id}" id="install-${id}">${uiIcon('download')}Показать установку</button><div class="progress-track" id="progress-${id}" hidden><span></span></div></section>`;
}

function renderItems() {
  const items = currentDemo()?.items;
  if (!items) return `<div class="editor-note">${uiIcon('sword')}<h2>Место для снаряжения</h2><p>Редактор предметов будет получать данные и правила из Lua PoB.</p></div>`;
  return `<div class="editor-grid"><section><h2 class="section-title">Снаряжение</h2><div class="item-list">${items.map((name, index) => itemRow(name, ['Двуручное оружие', 'Нагрудная броня', 'Кольцо'][index], ['sword', 'shield', 'gem'][index], index)).join('')}</div></section><div><h2 class="section-title">Флаконы</h2><div class="item-list">${itemRow('Глоток рассвета', 'Флакон здоровья', 'flask', 3)}${itemRow('Тихий источник', 'Флакон маны', 'flask', 4)}</div><p class="page-bottom-note">Предметы вымышлены для демонстрации дизайна.</p></div></div>`;
}

function itemRow(name, description, icon, index) {
  return `<button class="item-row" data-item="${index}"><span class="gear-icon">${uiIcon(icon)}</span><span><strong>${name}</strong><small>${description}</small></span>${uiIcon('chevron')}</button>`;
}

function renderConfig() {
  const build = currentBuild();
  const options = [['boss', 'Бой с боссом', 'Условия противника'], ['charges', 'Заряды активны', 'Эффекты персонажа'], ['lowLife', 'Мало здоровья', 'Состояние персонажа']];
  return `<div class="editor-grid"><section class="panel"><div class="panel-head"><h2>Условия расчёта</h2><span class="tag">Демо</span></div>${options.map(([key, label, description]) => `<div class="config-row"><div>${label}<small>${description}</small></div><label class="switch"><input type="checkbox" data-config="${key}" aria-label="${label}" ${build.config[key] ? 'checked' : ''}><span></span></label></div>`).join('')}<p class="page-bottom-note">Переключатели сохраняют выбор. Расчёт не выполняется.</p><details class="party-options"><summary>Группа и эффекты союзников</summary><label class="plain-check"><input type="checkbox" id="party-enabled" ${build.party ? 'checked' : ''}>Учитывать союзников</label><p>Состав группы и каталог эффектов подключаются через Lua. В макете сохраняется только выбор режима.</p></details></section><section class="panel"><div class="panel-head"><h2>Заметки к сборке</h2>${uiIcon('book')}</div><label class="field"><span class="muted">Что хочется попробовать?</span><textarea class="notes-field" id="build-notes" maxlength="10000" placeholder="Оставьте мысль для следующего эксперимента…">${escapeHtml(build.notes)}</textarea></label><p class="page-bottom-note" id="notes-status">${storageAvailable ? 'Сохраняется автоматически в браузере' : 'Хранилище недоступно — используйте экспорт'}</p></section></div>`;
}

function openBuild(id) {
  state.activeId = id;
  currentBuild().updated = Date.now();
  persist();
  navigate('workspace', 'overview');
}

function newBuild() {
  const form = document.getElementById('build-form');
  form.reset();
  document.getElementById('build-dialog').showModal();
}

function exportBuild() {
  const build = currentBuild();
  const blob = new Blob([JSON.stringify({ format: 'pob2-ui-design', version: 1, build }, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = `${build.name.replace(/[^\p{L}\p{N}_-]/gu, '_')}.pob2-demo.json`;
  anchor.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
  toast('JSON прототипа экспортирован');
}

async function importFile(file) {
  const error = document.getElementById('import-error');
  error.textContent = '';
  if (!file) return;
  try {
    if (file.size > 10000000) throw new Error('Файл слишком большой. Максимум — 10 МБ.');
    const data = JSON.parse(await file.text());
    if (data.format !== 'pob2-ui-design' || data.version !== 1) throw new Error('Нужен JSON, экспортированный из этого прототипа.');
    const build = validBuild(data.build);
    build.id = createId();
    build.updated = Date.now();
    state.builds.unshift(build);
    state.activeId = build.id;
    persist();
    document.getElementById('import-dialog').close();
    document.getElementById('workspace-dialog').close();
    navigate('workspace', 'overview');
    toast('Сборка импортирована');
  } catch (failure) { error.textContent = failure instanceof SyntaxError ? 'Не удалось прочитать JSON. Проверьте файл.' : failure.message; }
}

function showDetail(title, icon, text, values = '') {
  document.getElementById('detail-title').textContent = title;
  document.getElementById('detail-content').innerHTML = `<div class="detail-art">${uiIcon(icon)}</div>${values}<p>${escapeHtml(text)}</p><span class="tag">Демонстрационный элемент</span>`;
  document.getElementById('detail-dialog').showModal();
}

function showItem(index) {
  const demo = currentDemo();
  if (!demo?.items) { toast('Состав снаряжения пока не указан'); return; }
  const names = [...demo.items, 'Глоток рассвета', 'Тихий источник', 'Оберег пути'];
  const extras = { skill: demo.skill, move: 'Шаг сквозь тень', buff: 'Внутренняя искра' };
  const name = extras[index] || names[Number(index)] || names[0];
  const icon = extras[index] ? 'gem' : ['sword', 'shield', 'gem', 'flask', 'flask', 'gem'][Number(index)];
  showDetail(name, icon, 'Пример карточки для будущего редактора. Название и свойства вымышлены. Реальные данные и доступные действия будут поступать из исходного Lua PoB.');
}

async function simulateInstall(id) {
  const button = document.getElementById(`install-${id}`);
  const progress = document.getElementById(`progress-${id}`);
  button.disabled = true;
  progress.hidden = false;
  const phases = ['Загрузка · демо', 'Проверка Lua · демо', 'Активация · демо'];
  for (const [index, label] of phases.entries()) {
    button.innerHTML = `${uiIcon('refresh', 'spinning')}${label}`;
    progress.firstElementChild.style.width = `${(index + 1) * 33}%`;
    await new Promise(resolve => setTimeout(resolve, 700));
    if (!button.isConnected) return;
  }
  progress.firstElementChild.style.width = '100%';
  button.innerHTML = `${uiIcon('check')}Готово · демо`;
  document.getElementById(`version-${id}`).textContent = 'Установлен · демо';
  toast('Сценарий установки завершён. Файлы не загружались.');
}

async function simulateCheck() {
  const button = document.getElementById('check-button');
  button.disabled = true;
  button.innerHTML = `${uiIcon('refresh', 'spinning')}<span class="action-label">Проверяем</span>`;
  await new Promise(resolve => setTimeout(resolve, 900));
  if (!button.isConnected) return;
  button.disabled = false;
  button.innerHTML = `${uiIcon('check')}<span class="action-label">Готово</span>`;
  document.getElementById('component-status').textContent = 'Сценарий проверки завершён. Реальный запрос к GitHub не выполнялся.';
  toast('Проверка показана в демонстрационном режиме');
}

const actions = {
  new: newBuild,
  export: exportBuild,
  info: () => document.getElementById('info-dialog').showModal(),
  settings: () => { document.getElementById('info-dialog').close(); document.getElementById('settings-dialog').showModal(); },
  'zoom-in': () => zoomTree(.15), 'zoom-out': () => zoomTree(-.15), 'zoom-reset': () => zoomTree(0),
  check: simulateCheck,
  doctor: () => showDetail('Проверка совместимости', 'shield', 'В рабочем приложении настоящий Lua проверяет новую пару компонентов. Здесь показано оформление результата; реальная проверка не запускалась.'),
  rollback: () => showDetail('Предыдущая пара', 'box', 'После обновления в приложении можно будет вернуться к предыдущей проверенной паре компонентов. В прототипе компоненты не устанавливаются.'),
  ...workspaceActions,
  import: () => openTransfer()
};

document.addEventListener('click', event => {
  const target = event.target.closest('[data-action], [data-page], [data-tab], [data-build], [data-close], [data-item], [data-node], [data-support], [data-install]');
  if (!target) return;
  if (target.hasAttribute('data-close')) { target.closest('dialog').close(); return; }
  if (target.dataset.action) { actions[target.dataset.action]?.(); return; }
  if (target.dataset.page) { navigate(target.dataset.page); return; }
  if (target.dataset.tab) { navigate('workspace', target.dataset.tab); return; }
  if (target.dataset.build) { openBuild(target.dataset.build); return; }
  if (target.dataset.install) { simulateInstall(target.dataset.install); return; }
  if (target.hasAttribute('data-node')) { selectNode(Number(target.dataset.node)); return; }
  if (target.hasAttribute('data-support')) { showDetail('Камень умения', 'gem', 'Пример карточки камня. В приложении список умений, совместимость поддержек и эффекты будет определять исходный Lua PoB.'); return; }
  if (target.hasAttribute('data-item')) showItem(target.dataset.item);
});

document.addEventListener('keydown', event => {
  const node = event.target.closest('[data-node]');
  if (node && ['Enter', ' '].includes(event.key)) { event.preventDefault(); selectNode(Number(node.dataset.node)); }
  if (event.target.getAttribute('role') !== 'tab') return;
  const tabs = [...page.querySelectorAll('[role="tab"]')];
  let index = tabs.indexOf(event.target);
  if (event.key === 'ArrowRight') index = (index + 1) % tabs.length;
  else if (event.key === 'ArrowLeft') index = (index - 1 + tabs.length) % tabs.length;
  else if (event.key === 'Home') index = 0;
  else if (event.key === 'End') index = tabs.length - 1;
  else return;
  event.preventDefault();
  const tab = tabs[index].dataset.tab;
  navigate('workspace', tab);
  document.getElementById(`tab-${tab}`).focus();
});

document.getElementById('build-form').addEventListener('submit', event => {
  event.preventDefault();
  const form = new FormData(event.target);
  if (!String(form.get('name')).trim()) { toast('Введите название сборки'); return; }
  const build = validBuild({ id: createId(), name: form.get('name'), className: form.get('class'), level: Number(form.get('level')), updated: Date.now() });
  state.builds.unshift(build);
  state.activeId = build.id;
  persist();
  document.getElementById('build-dialog').close();
  navigate('workspace', 'overview');
  toast('Новая идея готова к работе');
});

document.addEventListener('input', event => {
  if (event.target.id === 'build-search') { state.query = event.target.value; document.getElementById('build-grid').innerHTML = renderBuildCards(); }
  if (event.target.id === 'build-notes') {
    currentBuild().notes = event.target.value;
    persist();
    document.getElementById('notes-status').textContent = storageAvailable ? 'Сохранено в браузере' : 'Хранилище недоступно — используйте экспорт';
  }
});

document.addEventListener('change', event => {
  if (event.target.id === 'build-sort') { state.sort = event.target.value; document.getElementById('build-grid').innerHTML = renderBuildCards(); }
  if (event.target.id === 'import-file') importFile(event.target.files[0]);
  if (event.target.dataset.config) {
    currentBuild().config[event.target.dataset.config] = event.target.checked;
    currentBuild().reportChanged = true;
    refreshReportStatus();
    persist();
    toast('Условие сохранено · расчёт в прототипе не выполняется');
  }
  if (event.target.id === 'motion-toggle') {
    state.motion = event.target.checked;
    document.body.classList.toggle('no-motion', !state.motion);
    persist();
  }
});

loadState();
if (!state.builds.length) state.builds = structuredClone(initialBuilds).map(validBuild);
if (!state.builds.some(build => build.id === 'ranger')) state.builds.unshift(validBuild(screenshotBuild()));
if (!state.builds.some(build => build.id === state.activeId)) state.activeId = state.builds[0].id;
document.body.classList.toggle('no-motion', !state.motion);
document.getElementById('motion-toggle').checked = state.motion;
hydrateIcons();
document.querySelector('#build-form select[name=class]').innerHTML = selectOptions(Object.fromEntries(CLASSES.map(name => [name, name])), 'Ведьма');
render();

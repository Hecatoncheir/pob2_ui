// Значения вручную перенесены со скриншота пользователя, без пересчёта.
const SCREENSHOT_VALUES = {
  AverageDamage: '394,1', Speed: '1,50', CritChance: '13,75', CritMultiplier: '200',
  HitChance: '100', TotalDPS: '591,5', AreaOfEffectRadius: '1,8',
  Str: '157', Dex: '185', Int: '142', TotalEHP: '22 239',
  PhysicalMaximumHitTaken: '4 493', ElementalMaximumHitTaken: '18 162', ChaosMaximumHitTaken: '13 468',
  Life: '2 258', LifeInc: '5', Mana: '870', ManaRegenRecovery: '45,2',
  Spirit: '100', SpiritUnreserved: '0', EnergyShield: '2 218', EnergyShieldInc: '165',
  Evasion: '5 246', EvasionInc: '225', EvadeChance: '34', Armour: '172', PhysicalDamageReduction: '12',
  FireResist: '75', ColdResist: '75', LightningResist: '75', ChaosResist: '75',
  EffectiveMovementSpeedMod: '+28,0', MovementSpeedWhileUsingSkill: '−57,1', PresenceRadius: '4,0'
};

const REPORT_GROUPS = [
  { id: 'damage', title: 'Урон', icon: 'spark', open: true, rows: [
    ['TotalDPS', 'DPS попаданий', '/ с'], ['AverageDamage', 'Среднее попадание', ''],
    ['Speed', 'Частота атак', '/ с'], ['CritChance', 'Шанс крит. удара', '%'],
    ['CritMultiplier', 'Множитель крита', '%'], ['HitChance', 'Шанс попадания', '%'],
    ['AreaOfEffectRadius', 'Радиус области', 'м']
  ] },
  { id: 'resources', title: 'Ресурсы', icon: 'heart', open: true, rows: [
    ['Life', 'Здоровье', ''], ['EnergyShield', 'Энергощит', ''], ['Mana', 'Мана', ''],
    ['ManaRegenRecovery', 'Восстановление маны', '/ с'], ['Spirit', 'Дух', ''],
    ['SpiritUnreserved', 'Свободный дух', ''], ['ManaUnreserved', 'Свободная мана', ''],
    ['LifeInc', 'Здоровье с дерева', '%'], ['EnergyShieldInc', 'Энергощит с дерева', '%']
  ] },
  { id: 'defence', title: 'Защита', icon: 'shield', open: true, rows: [
    ['TotalEHP', 'Эффективный запас', ''], ['PhysicalMaximumHitTaken', 'Макс. физический удар', ''],
    ['ElementalMaximumHitTaken', 'Макс. стихийный удар', ''], ['ChaosMaximumHitTaken', 'Макс. удар хаосом', ''],
    ['Armour', 'Броня', ''], ['PhysicalDamageReduction', 'Снижение физ. урона', '%'],
    ['Evasion', 'Рейтинг уклонения', ''], ['EvadeChance', 'Шанс уклонения', '%'],
    ['EvasionInc', 'Уклонение с дерева', '%']
  ] },
  { id: 'resists', title: 'Сопротивления', icon: 'shield', open: true, rows: [
    ['FireResist', 'Огонь', '%'], ['ColdResist', 'Холод', '%'],
    ['LightningResist', 'Молния', '%'], ['ChaosResist', 'Хаос', '%']
  ] },
  { id: 'attributes', title: 'Характеристики', icon: 'gem', open: false, rows: [
    ['Str', 'Сила', ''], ['Dex', 'Ловкость', ''], ['Int', 'Интеллект', '']
  ] },
  { id: 'movement', title: 'Передвижение', icon: 'arrow', open: false, rows: [
    ['EffectiveMovementSpeedMod', 'Скорость передвижения', '%'],
    ['MovementSpeedWhileUsingSkill', 'При использовании умения', '%'], ['PresenceRadius', 'Радиус присутствия', 'м']
  ] }
];

const ASCENDANCY_EXAMPLES = {
  Ranger: ['Pathfinder'], 'Ведьма': ['Infernalist'], 'Волшебница': ['Chronomancer']
};
const NODE_LABELS = ['Начало пути', 'Сила', 'Ловкость', 'Интеллект', 'Здоровье', 'Энергощит', 'Скорость', 'Критический удар', 'Область действия'];
const TREE_SETS = { main: 'Основное дерево', alternative: 'Вариант дерева' };
const WEAPON_SETS = { both: 'Общие очки', one: 'Оружие I', two: 'Оружие II' };
const PART_OPTIONS = { hit: 'Попадание', effect: 'Вторичный эффект' };

function cleanNodes(value) {
  if (!Array.isArray(value)) return [];
  return [...new Set(value.filter(id => Number.isInteger(id) && id >= 0 && id < 90))];
}

function knownOption(value, options, fallback) {
  return Object.hasOwn(options, value) ? value : fallback;
}

function validPinnedStats(value) {
  const candidates = Array.isArray(value) ? value : ['Life', 'EnergyShield', 'Mana', 'Spirit'];
  const pins = [...new Set(candidates.filter(id => Object.hasOwn(STAT_INDEX, id)))].slice(0, 6);
  return pins.length ? pins : ['Life', 'EnergyShield', 'Mana', 'Spirit'];
}

function normalizeWorkspace(value) {
  return {
    ascendancy: typeof value.ascendancy === 'string' ? value.ascendancy.slice(0, 50) : '',
    treeSet: knownOption(value.treeSet, TREE_SETS, 'main'),
    weaponSet: knownOption(value.weaponSet, WEAPON_SETS, 'both'),
    skillGroup: knownOption(value.skillGroup, { main: 1, movement: 1, buff: 1 }, 'main'),
    skillPart: knownOption(value.skillPart, PART_OPTIONS, 'hit'),
    alternativeNodes: Array.isArray(value.alternativeNodes) ? cleanNodes(value.alternativeNodes) : [0, 10, 12, 20, 21, 30],
    reportChanged: value.reportChanged === true,
    pendingXml: typeof value.pendingXml === 'string' ? value.pendingXml.slice(0, 2000000) : '',
    party: value.party === true
  };
}

function screenshotBuild() {
  return {
    id: 'ranger', name: 'Shattering Concoction', className: 'Ranger', level: 90,
    fixture: 'ranger', updated: 4, nodes: [0, 1, 2, 3, 10, 11, 12, 30, 31, 32, 40, 41, 50, 51],
    notes: '', config: {}, ...normalizeWorkspace({ ascendancy: 'Pathfinder' })
  };
}

function reportValues(build) {
  if (build.fixture === 'ranger') return SCREENSHOT_VALUES;
  const demo = DEMO[build.fixture];
  if (!demo) return {};
  return { Life: demo.stats[1], EnergyShield: demo.stats[2], EvadeChance: demo.stats[3],
    FireResist: demo.resist[0].replace('%', ''), ColdResist: demo.resist[1].replace('%', ''),
    LightningResist: demo.resist[2].replace('%', ''), ChaosResist: demo.resist[3].replace('%', '') };
}

function currentNodes() {
  const build = currentBuild();
  return build.treeSet === 'alternative' ? build.alternativeNodes : build.nodes;
}

function setCurrentNodes(nodes) {
  const build = currentBuild();
  const key = build.treeSet === 'alternative' ? 'alternativeNodes' : 'nodes';
  build[key] = nodes;
  build.reportChanged = true;
}

function validBuild(value) {
  if (!value || typeof value.name !== 'string' || !value.name.trim()) throw new Error('В файле нет названия сборки.');
  if (!CLASSES.includes(value.className)) throw new Error('Неизвестный класс в файле.');
  if (!Number.isInteger(value.level) || value.level < 1 || value.level > 100) throw new Error('Уровень должен быть от 1 до 100.');
  return {
    ...normalizeWorkspace(value),
    pinnedStats: validPinnedStats(value.pinnedStats),
    id: typeof value.id === 'string' ? value.id.slice(0, 80) : createId(),
    name: value.name.trim().slice(0, 60), className: value.className, level: value.level,
    fixture: Object.hasOwn(DEMO, value.fixture) ? value.fixture : null,
    updated: Number.isFinite(value.updated) ? value.updated : 0,
    nodes: cleanNodes(value.nodes),
    notes: typeof value.notes === 'string' ? value.notes.slice(0, 10000) : '',
    config: Object.fromEntries(['boss', 'charges', 'lowLife'].map(key => [key, value.config?.[key] === true]))
  };
}

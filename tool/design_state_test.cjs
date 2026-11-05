// Проверки переноса сохранённых данных и импорта прототипа; игровые расчёты не запускаются.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');
const vm = require('node:vm');

function model() {
  const context = vm.createContext({ createId: () => 'новый-id' });
  const scripts = resolve(__dirname, '../docs/scripts');
  vm.runInContext(readFileSync(resolve(scripts, 'workspace-data.js'), 'utf8'), context);
  vm.runInContext(readFileSync(resolve(scripts, 'workspace.js'), 'utf8'), context);
  vm.runInContext("const DEMO = { ranger: {}, ember: {} }; const CLASSES = ['Ranger', 'Ведьма'];", context);
  return context;
}

function plain(value) { return JSON.parse(JSON.stringify(value)); }

test('Старое сохранение получает отдельный вариант дерева и важные показатели', () => {
  const context = model();
  context.input = { name: 'Идея', className: 'Ведьма', level: 90, fixture: 'ember', nodes: [0, 1] };
  const build = plain(vm.runInContext('validBuild(input)', context));
  assert.deepEqual(build.nodes, [0, 1]);
  assert.equal(build.treeSet, 'main');
  assert.equal(build.weaponSet, 'both');
  assert.deepEqual(build.pinnedStats, ['Life', 'EnergyShield', 'Mana', 'Spirit']);
  assert.notDeepEqual(build.alternativeNodes, build.nodes);
});

test('Импорт сохраняет оба дерева, выбор умения, заметки и ожидающий XML', () => {
  const context = model();
  context.input = { ...plain(vm.runInContext('screenshotBuild()', context)), treeSet: 'alternative',
    weaponSet: 'two', skillGroup: 'movement', skillPart: 'effect', alternativeNodes: [20, 21],
    notes: '<заметка> & текст', pendingXml: '<PathOfBuilding2/>', pinnedStats: ['TotalEHP', 'Life'], party: true };
  const first = plain(vm.runInContext('validBuild(input)', context));
  context.roundtrip = JSON.parse(JSON.stringify(first));
  const second = plain(vm.runInContext('validBuild(roundtrip)', context));
  assert.deepEqual(second, first);
  assert.equal(second.treeSet, 'alternative');
  assert.equal(second.pendingXml, '<PathOfBuilding2/>');
});

test('Импорт отбрасывает неизвестные режимы, повторные узлы и посторонние поля', () => {
  const context = model();
  context.input = { name: 'Проверка', className: 'Ranger', level: 90, fixture: '__proto__',
    nodes: [1, 1, -1, 90, '2', 2], treeSet: 'constructor', weaponSet: 'unknown',
    pinnedStats: ['__proto__', 'Life', 'Life', 'missing'], unexpected: true };
  const build = plain(vm.runInContext('validBuild(input)', context));
  assert.deepEqual(build.nodes, [1, 2]);
  assert.deepEqual(build.pinnedStats, ['Life']);
  assert.equal(build.fixture, null);
  assert.equal(build.treeSet, 'main');
  assert.equal(build.weaponSet, 'both');
  assert.equal(Object.hasOwn(build, 'unexpected'), false);
});

test('Некорректные класс, уровень и пустое название отклоняются', () => {
  const context = model();
  for (const changes of [{ name: ' ' }, { className: 'нет' }, { level: 0 }, { level: 101 }, { level: 1.5 }]) {
    context.input = { name: 'Идея', className: 'Ranger', level: 90, ...changes };
    assert.throws(() => vm.runInContext('validBuild(input)', context));
  }
});

test('Снимок доступен отдельно от новых сборок без рассчитанных показателей', () => {
  const context = model();
  assert.equal(vm.runInContext("reportValues({fixture:'ranger'}).TotalDPS", context), '591,5');
  assert.deepEqual(plain(vm.runInContext('reportValues({fixture:null})', context)), {});
});

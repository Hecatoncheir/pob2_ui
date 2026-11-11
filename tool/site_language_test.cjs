const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');
const test = require('node:test');
const { resolveSiteLanguage } = require('../docs/scripts/site-language.js');
const { siteStrings } = require('../docs/scripts/site-strings.js');

test('Автовыбор учитывает порядок языков и региональные варианты', () => {
  assert.equal(resolveSiteLanguage('auto', ['fr-FR', 'ru-RU', 'en-US']), 'ru');
  assert.equal(resolveSiteLanguage('auto', ['en-GB', 'ru']), 'en');
  assert.equal(resolveSiteLanguage(null, ['zh-TW', 'en']), 'zh-Hans');
});

test('Ручной выбор имеет приоритет; для неподдерживаемых языков используется английский', () => {
  assert.equal(resolveSiteLanguage('ru', ['en-GB']), 'ru');
  assert.equal(resolveSiteLanguage('zh-Hans', ['ru']), 'zh-Hans');
  assert.equal(resolveSiteLanguage('es', ['de', 'ja']), 'en');
  assert.equal(resolveSiteLanguage(null, []), 'en');
});

test('На всех страницах переключатель и подписи имеют три перевода', () => {
  for (const page of ['index', 'gallery', 'brand']) {
    const html = readFileSync(resolve(__dirname, '../docs', `${page}.html`), 'utf8');
    assert.match(html, /<select\b[^>]*\bdata-site-language\b/);
    for (const value of ['auto', 'ru', 'en', 'zh-Hans']) {
      assert.ok(html.includes(`<option value="${value}"`), `${page}: ${value}`);
    }
    for (const [, key] of html.matchAll(/\bdata-i18n(?:-[\w-]+)?="(\w+)"/g)) {
      const translations = siteStrings[key];
      assert.ok(translations?.length === 3 && translations.every(value => value.trim()), `${page}: ${key}`);
    }
  }
});

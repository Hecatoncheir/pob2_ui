const { test } = require('node:test');
const assert = require('node:assert/strict');
const { releaseDownloads } = require('../docs/scripts/downloads.js');
const release = require('../docs/data/release.json');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');

test('Последний выпуск содержит прямые загрузки трёх ОС', () => {
  const result = releaseDownloads(release);
  assert.match(result.downloads.windows, /\.exe$/);
  assert.match(result.downloads.macos, /\.dmg$/);
  assert.match(result.downloads.linux, /\.run$/);
});
test('Неполный, предварительный или подменённый выпуск не заменяет ссылки', () => {
  assert.throws(() => releaseDownloads({ ...release, assets: [] }));
  assert.throws(() => releaseDownloads({ ...release, prerelease: true }));
  assert.throws(() => releaseDownloads({ ...release, html_url: 'https://example.com' }));
  assert.throws(() => releaseDownloads({ ...release, assets: release.assets.map(asset => ({ ...asset, browser_download_url: 'javascript:alert(1)' })) }));
});
test('Ссылки без JavaScript и оригиналы галереи включены в сайт', () => {
  const html = readFileSync(resolve(__dirname, '../docs/index.html'), 'utf8');
  for (const url of Object.values(releaseDownloads(release).downloads)) assert.ok(html.includes(url));
  const gallery = readFileSync(resolve(__dirname, '../docs/gallery.html'), 'utf8');
  const originals = [...gallery.matchAll(/<a target="_blank" rel="noopener" href="(assets\/screenshots\/[^\"]+\.png)" data-gallery/g)];
  assert.equal(originals.length, 8);
  for (const [, path] of originals) {
    const image = readFileSync(resolve(__dirname, '../docs', path));
    assert.equal(image.subarray(1, 4).toString(), 'PNG');
    assert.ok(image.length > 10000);
  }
});

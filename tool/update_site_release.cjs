// Обновляет статический каталог из последнего стабильного выпуска GitHub.
const { readFileSync, writeFileSync } = require('node:fs');
const { resolve } = require('node:path');
const { releaseDownloads } = require('../docs/scripts/downloads.js');

async function main() {
  const response = await fetch('https://api.github.com/repos/Hecatoncheir/pob2_ui/releases/latest', {
    headers: { Accept: 'application/vnd.github+json', ...(process.env.GITHUB_TOKEN ? { Authorization: `Bearer ${process.env.GITHUB_TOKEN}` } : {}) },
  });
  if (!response.ok) throw new Error(`GitHub: ${response.status}`);
  const release = await response.json();
  const checked = releaseDownloads(release);
  const catalog = { tag_name: release.tag_name, html_url: release.html_url,
    assets: release.assets.map(({ name, browser_download_url }) => ({ name, browser_download_url })) };
  writeFileSync(resolve(__dirname, '../docs/data/release.json'), `${JSON.stringify(catalog, null, 2)}\n`);
  const homepage = resolve(__dirname, '../docs/index.html');
  let html = readFileSync(homepage, 'utf8');
  for (const [platform, url] of Object.entries(checked.downloads)) {
    html = html.replace(new RegExp(`(<a[^>]*data-download="${platform}"[^>]*href=")[^"]+("[^>]*>)`), (_, before, after) => before + url + after);
  }
  html = html.replace(/(<a[^>]*data-release-version[^>]*href=")[^"]+("[^>]*>)[^<]+/, (_, before, after) => before + checked.url + after + checked.version + ' ↗');
  writeFileSync(homepage, html);
  console.log(`Каталог загрузок: ${checked.version}, три ОС`);
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });

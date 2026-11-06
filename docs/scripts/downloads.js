// Одни и те же правила проверяют выпуск при публикации и при загрузке страницы.
function releaseDownloads(release) {
  const root = 'https://github.com/Hecatoncheir/pob2_ui/releases/';
  if (!/^v\d+\.\d+\.\d+$/.test(release.tag_name) || release.draft || release.prerelease) {
    throw new Error('Ожидался стабильный выпуск');
  }
  if (release.html_url !== `${root}tag/${release.tag_name}`) throw new Error('Неизвестный источник выпуска');
  const patterns = { windows: /-windows-x64-setup\.exe$/, macos: /-macos-arm64\.dmg$/, linux: /-linux-x64\.run$/ };
  const downloads = {};
  for (const [platform, pattern] of Object.entries(patterns)) {
    const matches = release.assets.filter(asset => pattern.test(asset.name));
    if (matches.length !== 1) throw new Error(`Нет однозначного установщика: ${platform}`);
    const asset = matches[0];
    const expected = `${root}download/${release.tag_name}/${asset.name}`;
    if (asset.browser_download_url !== expected || !/^[a-z0-9.+-]+$/.test(asset.name)) throw new Error('Некорректная ссылка установщика');
    downloads[platform] = expected;
  }
  return { version: release.tag_name, url: release.html_url, downloads };
}

if (typeof module !== 'undefined') module.exports = { releaseDownloads };
if (typeof document !== 'undefined') {
  fetch('data/release.json').then(response => {
    if (!response.ok) throw new Error('Каталог недоступен');
    return response.json();
  }).then(releaseDownloads).then(release => {
    document.querySelectorAll('[data-download]').forEach(link => {
      link.href = release.downloads[link.dataset.download];
    });
    document.querySelectorAll('[data-release-version]').forEach(link => {
      link.textContent = `${release.version} ↗`;
      link.href = release.url;
    });
  }).catch(() => {
    // Ссылки последнего проверенного выпуска остаются доступны без JavaScript и сети API.
  });
}

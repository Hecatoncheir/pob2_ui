// Общая геометрия значков для прототипа и отдельных SVG-файлов.
const iconPaths = {
  grid: '<rect x="3" y="3" width="7" height="7" rx="2"/><rect x="14" y="3" width="7" height="7" rx="2"/><rect x="3" y="14" width="7" height="7" rx="2"/><rect x="14" y="14" width="7" height="7" rx="2"/>',
  tree: '<path d="M12 21V4m0 11-7-5m7 1 7-5m-7 13 7-4"/><circle cx="12" cy="3" r="2"/><circle cx="3" cy="9" r="2"/><circle cx="21" cy="5" r="2"/><circle cx="21" cy="14" r="2"/>',
  sword: '<path d="m6 15 11-12 4-1-1 5L9 18M3 13l8 8M2 22l4-5m-2 2 2 2"/>',
  gem: '<path d="m12 2 8 8-8 12L4 10Zm-8 8h16M12 2l-3 8 3 12 3-12Z"/>',
  flask: '<path d="M8 3h8M9 3v6L3 19c-.6 1 .1 2 1.3 2h15.4c1.2 0 1.9-1 1.3-2L15 9V3M6 15h12"/><circle cx="11" cy="17" r=".6"/>',
  box: '<path d="m12 2 9 5v10l-9 5-9-5V7Zm-9 5 9 5 9-5m-9 5v10M7.5 4.5l9 5V14"/>',
  settings: '<path d="M4 7h16M4 17h16"/><circle cx="9" cy="7" r="3" fill="var(--paper, #f2efe5)"/><circle cx="15" cy="17" r="3" fill="var(--paper, #f2efe5)"/>',
  plus: '<path d="M12 5v14M5 12h14"/>',
  arrow: '<path d="M4 12h16m-6-6 6 6-6 6"/>',
  download: '<path d="M12 3v12m-5-5 5 5 5-5M4 17v4h16v-4"/>',
  upload: '<path d="M12 16V4m-5 5 5-5 5 5M4 17v4h16v-4"/>',
  search: '<circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/>',
  chevron: '<path d="m9 5 7 7-7 7"/>',
  check: '<path d="m5 12 4 4L19 6"/>',
  close: '<path d="m6 6 12 12M6 18 18 6"/>',
  refresh: '<path d="M20 8a8 8 0 0 0-14-3L3 8m0-5v5h5M4 16a8 8 0 0 0 14 3l3-3m0 5v-5h-5"/>',
  heart: '<path d="M12 21C7 17 2 13 2 8a5 5 0 0 1 10-1A5 5 0 0 1 22 8c0 5-5 9-10 13Z"/>',
  shield: '<path d="m12 2 8 3v7c0 5-8 10-8 10S4 17 4 12V5Zm0 5v10"/>',
  spark: '<path d="m12 2 3 7 7 3-7 3-3 7-3-7-7-3 7-3Z"/>',
  chart: '<path d="M4 3v17h17M8 14l4-5 4 2 5-7"/>',
  link: '<path d="m9 15 6-6m-5-3 2-2a5 5 0 0 1 8 8l-2 2m-4 4-2 2a5 5 0 0 1-8-8l2-2"/>',
  moon: '<path d="M20 14A8 8 0 0 1 10 4a8.5 8.5 0 1 0 10 10Z"/>',
  sun: '<circle cx="12" cy="12" r="4"/><path d="M12 1v2m0 18v2M1 12h2m18 0h2M4 4l2 2m12 12 2 2M4 20l2-2M18 6l2-2"/>',
  minus: '<path d="M5 12h14"/>',
  fit: '<path d="M8 3H3v5m13-5h5v5M3 16v5h5m13-5v5h-5"/>',
  back: '<path d="M20 12H4m6-6-6 6 6 6"/>',
  book: '<path d="M3 4h6c2 0 3 1 3 3 0-2 1-3 3-3h6v16h-6c-2 0-3 1-3 2 0-1-1-2-3-2H3Zm9 3v15"/>',
  eye: '<path d="M2 12S6 5 12 5s10 7 10 7-4 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/>',
  copy: '<rect x="8" y="8" width="13" height="13" rx="2"/><path d="M16 8V3H3v13h5"/>',
  info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v6m0-10v.1"/>',
  code: '<path d="m7 6-6 6 6 6m10-12 6 6-6 6M14 3l-4 18"/>',
  trash: '<path d="M3 6h18M9 6V3h6v3M5 6l1 15h12l1-15M10 10v7m4-7v7"/>'
};
function uiIcon(name, extra = '') {
  return `<svg class="icon ${extra}" viewBox="0 0 24 24" aria-hidden="true">${iconPaths[name] || iconPaths.spark}</svg>`;
}
if (typeof module !== 'undefined') module.exports = { iconPaths, uiIcon };

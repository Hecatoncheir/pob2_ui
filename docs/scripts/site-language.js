const siteLanguageIndexes = { ru: 0, en: 1, 'zh-Hans': 2 };

function resolveSiteLanguage(preference, browserLanguages) {
  if (Object.hasOwn(siteLanguageIndexes, preference)) return preference;
  const supported = { ru: 'ru', en: 'en', zh: 'zh-Hans' };
  for (const locale of browserLanguages) {
    const primary = locale.toLowerCase().split('-')[0];
    if (Object.hasOwn(supported, primary)) return supported[primary];
  }
  return 'en';
}

function setupSiteLanguage(select) {
  const storageKey = 'pob-site-language';
  const attributes = ['aria-label', 'alt', 'content', 'data-title', 'data-description'];
  let language = 'ru';

  function text(key, name = '') {
    return siteStrings[key][siteLanguageIndexes[language]].replace('{name}', () => name);
  }

  function apply(preference) {
    select.value = Object.hasOwn(siteLanguageIndexes, preference) ? preference : 'auto';
    const browserLanguages = navigator.languages?.length ? navigator.languages : [navigator.language];
    language = resolveSiteLanguage(select.value, browserLanguages.filter(Boolean));
    document.documentElement.lang = language;
    document.querySelectorAll('[data-i18n]').forEach(element => {
      element.textContent = text(element.dataset.i18n);
    });
    for (const attribute of attributes) {
      const marker = `data-i18n-${attribute}`;
      document.querySelectorAll(`[${marker}]`).forEach(element => {
        element.setAttribute(attribute, text(element.getAttribute(marker), element.dataset.i18nName));
      });
    }
    document.dispatchEvent(new Event('site-language-change'));
  }

  window.pobSiteLanguage = { text };
  let saved;
  try { saved = localStorage.getItem(storageKey); } catch (_) { /* Сайт работает и без хранилища. */ }
  apply(saved);
  select.hidden = false;
  select.addEventListener('change', () => {
    apply(select.value);
    try { localStorage.setItem(storageKey, select.value); } catch (_) { /* Выбор действует до закрытия страницы. */ }
  });
  window.addEventListener('languagechange', () => {
    if (select.value === 'auto') apply('auto');
  });
  window.addEventListener('storage', event => {
    if (event.key === storageKey) apply(event.newValue);
  });
}

if (typeof module !== 'undefined') module.exports = { resolveSiteLanguage };
if (typeof document !== 'undefined') setupSiteLanguage(document.querySelector('[data-site-language]'));

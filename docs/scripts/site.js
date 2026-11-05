document.querySelectorAll('[data-icon]').forEach(element => {
  element.innerHTML = uiIcon(element.dataset.icon);
});
document.querySelectorAll('[data-dialog]').forEach(button => {
  button.addEventListener('click', () => document.getElementById(button.dataset.dialog).showModal());
});
document.querySelectorAll('[data-close]').forEach(button => {
  button.addEventListener('click', () => button.closest('dialog').close());
});
document.querySelectorAll('dialog').forEach(dialog => {
  dialog.addEventListener('click', event => {
    if (event.target !== dialog) return;
    const bounds = dialog.getBoundingClientRect();
    const outsideX = event.clientX < bounds.left || event.clientX > bounds.right;
    const outsideY = event.clientY < bounds.top || event.clientY > bounds.bottom;
    if (outsideX || outsideY) dialog.close();
  });
});
const themeToggle = document.getElementById('theme-toggle');
themeToggle?.addEventListener('click', () => {
  const dark = document.body.classList.toggle('dark');
  themeToggle.innerHTML = uiIcon(dark ? 'sun' : 'moon');
  themeToggle.setAttribute('aria-label', dark ? 'Включить светлую тему' : 'Включить тёмную тему');
});

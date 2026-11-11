document.querySelectorAll('[data-icon]').forEach(element => { element.innerHTML = uiIcon(element.dataset.icon); });
document.getElementById('icon-gallery').innerHTML = Object.keys(iconPaths).map(name => `<a class="icon-tile" href="assets/icons/${name}.svg" download aria-label="Скачать значок ${name}" data-i18n-aria-label="downloadIcon" data-i18n-name="${name}">${uiIcon(name)}<span>${name}</span></a>`).join('');
const motionButton = document.getElementById('motion-demo');
motionButton.addEventListener('click', () => {
  motionButton.classList.remove('playing');
  requestAnimationFrame(() => requestAnimationFrame(() => motionButton.classList.add('playing')));
});

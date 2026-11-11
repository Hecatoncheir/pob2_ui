const screenshots = [...document.querySelectorAll('[data-gallery]')];
const viewer = document.getElementById('screenshot-viewer');
let currentScreenshot = 0;

function showScreenshot(index) {
  currentScreenshot = (index + screenshots.length) % screenshots.length;
  const link = screenshots[currentScreenshot];
  document.getElementById('viewer-image').src = link.getAttribute('href');
  updateScreenshotText();
  document.getElementById('viewer-count').textContent = `${currentScreenshot + 1} / ${screenshots.length}`;
}

function updateScreenshotText() {
  const link = screenshots[currentScreenshot];
  document.getElementById('viewer-image').alt = link.querySelector('img').alt;
  document.getElementById('viewer-title').textContent = link.dataset.title;
  document.getElementById('viewer-description').textContent = link.dataset.description;
}
document.addEventListener('site-language-change', () => {
  if (viewer.open) updateScreenshotText();
});
screenshots.forEach((link, index) => link.addEventListener('click', event => {
  if (window.matchMedia('(max-width: 640px)').matches) return;
  event.preventDefault();
  showScreenshot(index);
  viewer.showModal();
}));
document.getElementById('viewer-prev').addEventListener('click', () => showScreenshot(currentScreenshot - 1));
document.getElementById('viewer-next').addEventListener('click', () => showScreenshot(currentScreenshot + 1));
document.getElementById('viewer-image').addEventListener('click', () => viewer.close());
document.getElementById('viewer-image').addEventListener('keydown', event => {
  if (event.key === 'Enter' || event.key === ' ') {
    event.preventDefault();
    viewer.close();
  }
});
viewer.addEventListener('keydown', event => {
  if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
    event.preventDefault();
    showScreenshot(currentScreenshot + (event.key === 'ArrowRight' ? 1 : -1));
  }
});

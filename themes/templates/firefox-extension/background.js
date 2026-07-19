/* Static extension logic; themes.js is generated from both standard variants. */
function applyTheme(mode) {
  const theme = THEMES[mode];
  if (theme) {
    browser.theme.update(theme);
  }
}

const appearance = window.matchMedia('(prefers-color-scheme: dark)');
const syncTheme = event => applyTheme(event.matches ? 'dark' : 'light');

syncTheme(appearance);
if (appearance.addEventListener) {
  appearance.addEventListener('change', syncTheme);
} else {
  appearance.addListener(syncTheme);
}

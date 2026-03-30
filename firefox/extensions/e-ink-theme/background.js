function applyTheme(mode) {
  const theme = THEMES[mode];
  if (theme) {
    browser.theme.update(theme);
  }
}

const mq = window.matchMedia("(prefers-color-scheme: dark)");
applyTheme(mq.matches ? "dark" : "light");

mq.addEventListener("change", (e) => {
  applyTheme(e.matches ? "dark" : "light");
});

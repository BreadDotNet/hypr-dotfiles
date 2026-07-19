# Аудит и миграция dotfiles

Этот документ фиксирует состояние, обнаруженное перед миграцией, принятые
решения и проверяемые результаты. Возраст файла сам по себе не использовался как
признак неактуальности: учитывались ссылки из shell/Hyprland/tmux/Yazi,
theme-скриптов, документации, Git index и живых symlink текущего `$HOME`.

## Текущая структура

До миграции каждый Stow-совместимый пакет находился в корне репозитория:
`hyprland/`, `nvim/`, `tmux/`, `zshrc/` и так далее. Формального manifest,
единого install CLI и платформенных адаптеров не было; существующая система
использовала прямые ссылки из `$HOME`.

Целевая активная структура:

- `packages/` — все устанавливаемые Stow-пакеты по приложениям;
- `manifests/` — common, Linux, Arch и macOS selection;
- `scripts/platforms/` — расширяемые адаптеры ОС/дистрибутивов;
- `packages-list/` — отдельные Arch official, AUR и Brewfile;
- `themes/` — исходная палитра, templates и generated artifacts;
- `hosts/` — примеры machine-specific overrides без секретов;
- `archive/legacy/` — восстановимые, но неактивные конфиги;
- `.migration-backups/` — локальные Git bundles, старые gitdir и inventory;
  каталог исключён из Git.

Во время миграции старые корневые имена временно представлялись compatibility
symlink на `packages/` или `archive/legacy/`. Они использовались только для
безопасного удаления/перенаправления уже существующих ссылок текущего `$HOME` и
удалены перед финальными проверками; в итоговой архитектуре это не Stow-пакеты.

## Найденные проблемы

- Neovim одновременно отслеживался основным репозиторием как обычное дерево и
  содержал собственный `.git` с отдельными remote/history и локальными правками.
- Три tmux-плагина были записаны в основном index как gitlink mode `160000`, но
  `.gitmodules` отсутствовал. Такой checkout нельзя было воспроизвести обычным
  клонированием dotfiles.
- Конфиги лежали в плоском корне, не было явного автоматического разделения
  common/Linux/Arch/macOS/host.
- Старый генератор e-ink изменял файлы разных пакетов непосредственно и смешивал
  source of truth с generated output.
- Встречались неактивные X11-конфиги, старые Catppuccin fragments и явные
  дубликаты/остатки Wofi, Waybar и Kitty.
- `tmux/.tmux.conf` ссылался на checkout-specific `~/dotfiles/tmux/...` и
  безусловно ожидал TPM.
- Polybar содержал broken symlink launcher.
- Hyprland ожидает локальный `~/.config/hypr/monitors.conf`, которого нет в Git;
  это корректно считать hardware-specific файлом, но прежняя документация не
  объясняла его жизненный цикл.
- Конфиги ссылаются на внешние/локальные объекты, которые репозиторий не должен
  создавать из предположений: `~/.face`, `notion-calendar-electron`, polkit agent
  и локальный Wofi theme fragment.
- В прежнем `CLAUDE.md` были фактически устаревшие утверждения: ручные symlink,
  NvChad и отсутствие install/test команд.

## Активные конфигурации

Подтверждены ссылками, связями между конфигами и/или существовавшими ссылками из
пользовательского HOME:

- Hyprland, Hyprlock, Hyprpaper, Waybar и Wofi;
- Kitty;
- Zsh, Starship и fzf-настройки shell;
- Neovim с lazy.nvim и сохранённым `lazy-lock.json`;
- tmux; TPM и vim-tmux-navigator при этом являются отдельными optional plugins;
- Yazi с существующим Catppuccin Mocha flavor;
- Gitu и backgrounds;
- Firefox e-ink theme extension как существующая theme-интеграция.

Эти конфиги переносятся в отдельные `packages/<app>` без стилистического
переписывания не относящихся к миграции настроек.

## Предположительно устаревшие конфигурации

К точно не участвующим в новой установке отнесены конфиги прежнего X11-стека и
заменённые/дублирующие theme artifacts:

- Alacritty, i3, Polybar, Picom, Rofi, Xresources и screenlayout;
- `hyprmocha`;
- старый Kitty `current-theme.conf`;
- Waybar `mocha.css`;
- лишний корневой `wofi/config`;
- прежняя e-ink система `theme/` и сгенерированные ею файлы после переноса
  актуальных основных конфигов на новый theme contract.

Они сохранены с относительной структурой в `archive/legacy/` и не входят в
manifests. Broken Polybar symlink заменён текстовым файлом с исходным target;
этого достаточно для точного восстановления ссылки без сохранения broken link в
рабочем дереве.

## Конфигурации с неопределённым статусом

- Ghostty: конфиг существует, но не был представлен живыми ссылками; хранится как
  optional пакет и не должен автоматически выбираться.
- Hypridle: присутствует конфиг и ссылка из старого Hyprland package, но процесс
  не запускается основной конфигурацией; выделяется в optional пакет.
- Неиспользуемые wallpapers: отсутствие ссылки из Hyprpaper не доказывает, что
  пользователь не выбирает их вручную, поэтому изображения сохранены.
- Monitor template: остаётся примером host-specific настройки, а не общим
  автоматически устанавливаемым `monitors.conf`.
- Локальный `~/.face`, `notion-calendar-electron`, Wofi theme fragment и путь
  polkit agent требуют ручного подтверждения; они не добавляются автоматически.

## Вложенные Git-репозитории

### Neovim

Фактический путь до миграции: `nvim/.config/nvim`. Это был **обычный вложенный
Git-репозиторий**, не submodule и не gitlink: основной Git отдельно отслеживал
рабочие файлы этого каталога как tree.

- remote: `git@github.com:BreadDotNet/kickstart.nvim.git`;
- branch: `master`;
- HEAD: `6cd07b54e2b0aeaffd39c7d604f08a9592453aa5` (`update config structure`);
- на момент аудита: 9 modified и 6 untracked файлов во вложенном checkout;
- следующие предыдущие commits: `3338d39`, `6ba2408`, `f5a9f9c`, `fb73617`.

До удаления метаданных создан и проверен полный bundle:

```text
.migration-backups/neovim/kickstart.nvim-6cd07b54e2b0aeaffd39c7d604f08a9592453aa5.bundle
```

`git bundle verify` подтверждает полный history и refs `master`,
`origin/master`, `origin/HEAD`, `HEAD`. Старый gitdir также перенесён в
игнорируемый каталог с именем без `.git`. Актуальный внешний working tree,
включая локальные изменения/новые файлы и `lazy-lock.json`, перенесён в
`packages/nvim`.

### tmux

В основном index находились три gitlink без `.gitmodules`:

| Старый путь | Remote, записанный в gitdir | Branch | HEAD |
| --- | --- | --- | --- |
| `.tmux/plugins/tmux` | `https://git::@github.com/catppuccin/tmux` | `main` | `d6458527ef121cc280c5dd119ba638749de1f713` |
| `.tmux/plugins/tpm` | `https://github.com/tmux-plugins/tpm` | `master` | `99469c4a9b1ccf77fade25842dc7bafbc8ce9946` |
| `.tmux/plugins/vim-tmux-navigator` | `https://git::@github.com/christoomey/vim-tmux-navigator` | `master` | `a9b52e7d36114d40350099f254b5f299a35df978` |

Неканоничные строки remote записаны дословно. Для каждого checkout создан
bundle и сохранён gitdir/worktree под `.migration-backups/tmux-plugins/`; все
bundles проверены `git bundle verify` и восстановительным клонированием. Сторонние
исходники не переносятся в основной репозиторий. Catppuccin checkout не был
подключён активным `.tmux.conf`; TPM и navigator становятся manual optional
dependencies.

## Потенциальные конфликты Stow

- Активные пакеты обязаны иметь уникальные конечные пути. В частности, Hypridle
  не должен одновременно принадлежать `hyprland` и отдельному `hypridle`.
- Platform/host layers не создают второй `.zshrc` или `hyprland.conf`; основной
  файл условно загружает отдельные fragments.
- Старые Waybar/Kitty/Wofi fragments и compatibility symlink в archive нельзя
  включать в устанавливаемые пакеты.
- Реальный `monitors.conf`, обычный Ghostty config и любые файлы, не являющиеся
  ссылками этого репозитория, нельзя заменять автоматически.
- GNU Stow directory folding затрудняет точный контроль отдельных ссылок; CLI
  использует no-folding и проверяет conflicts до изменения `$HOME`.
- Старые live symlink инвентаризированы в
  `.migration-backups/live-links/before.txt`; результат переключения записан в
  `after.txt`. Перенастраивались только ссылки, уже указывавшие внутрь этого
  репозитория.

## Потенциальные секреты

- Поиск по отслеживаемым именам и содержимому не обнаружил SSH private keys,
  токены, cookies, history, keychain data или private certificates.
- Локальные `.claude/settings.local.json`, Firefox `.amo-upload-uuid` и
  `web-ext-artifacts/`, `.migration-backups/`, theme local override и shell local
  fragment должны оставаться ignored.
- Git config старого Neovim checkout содержит имя/e-mail автора; поэтому весь
  сохранённый gitdir остаётся локальной migration backup и не коммитится.
- Отсутствие найденного совпадения не является доказательством отсутствия секрета;
  перед commit требуется повторный diff/secret review.

## Принятые архитектурные решения

- GNU Stow сохранён: фактической несовместимости не найдено, а это минимизирует
  риск миграции существующих ссылок.
- Все активные packages находятся под одним `packages/`; выбор хранится отдельно
  в manifests.
- Overlay order: `common → linux → arch/macos → host → local`; optional fragment
  безопасно отсутствует.
- Неизвестный Linux получает common+linux, но не угаданный package manager.
- Установка пакетов отделена от установки dotfiles; AUR helper, Homebrew
  bootstrap, system settings и login shell не автоматизируются.
- Конфликтующий пользовательский файл блокирует установку. `stow --adopt` не
  используется; backup возможен только явно и восстановимо.
- `themes/palettes/terminal-macos.env` хранит общий ANSI/semantic base;
  `terminal-basic.env` и `terminal-pro.env` задают светлый и тёмный варианты.
  Полный generated tree сначала создаётся и проверяется во временном каталоге,
  затем атомарно переключается runtime-ссылка `~/.config/dotfiles/theme`.
- Runtime theme state вынесен из Git/Stow: ежедневный toggle не меняет
  `git status`, а ordinary file/unmanaged symlink на его месте блокирует команду.
- Basic/Pro описываются как переносимые Terminal-compatible палитры, не как
  точный рендеринг Terminal.app.
- Явный `theme apply/toggle` синхронизирует system appearance и поддерживаемые
  live-приложения; install/restow и `--no-reload` этого не делают.
- Tmux plugins не vendor'ятся и не скачиваются автоматически.
- Neovim получает offline mode для headless-проверки без clone/update plugins.

## Выполненные перемещения

- Активные корневые каталоги приложений перенесены в `packages/<app>/`.
- Neovim перенесён в `packages/nvim`; nested `.git` перемещён в локальную backup,
  bundle создан и проверен.
- Hypridle выделен из Hyprland в optional пакет; Ghostty сохранён optional.
- Устаревшие X11, Catppuccin duplicates и прежняя e-ink generator system
  перемещены в `archive/legacy/` с сохранением относительной структуры.
- Firefox extension переведён на стабильные template/generated-ссылки; bundle
  содержит обе палитры и следует системному `prefers-color-scheme`. Прежние
  версии сохранены в legacy archive, локальные AMO/build artifacts ignored.
- Промежуточный Stow-пакет `theme-runtime`, отслеживаемый `themes/current` и его
  старый generated tree сохранены в `archive/legacy/theme-runtime/`; активный
  runtime symlink мигрирован на прямую ссылку в content-addressed generated tree.
- Старые tmux plugin checkouts/gitdirs/bundles сохранены только локально в
  `.migration-backups/tmux-plugins/`; основной пакет не должен содержать gitlinks.
- Старые live-ссылки сняты через GNU Stow и заменены ссылками из `packages/`.
  Существующий `monitors.conf` сохранён обычным файлом и подключён локальным
  `conf.d/90-host.conf`; резервная ссылка Waybar перенаправлена на новый путь.
- Созданный Hyprland stub и совпадающий Neovim `.gitignore` не перезаписаны:
  CLI переместил их в восстановимую копию
  `~/.local/state/dotfiles/backups/20260719-162854-32880/` до Stow.
- После замены Hyprland stub на Stow-ссылку уже запущенный compositor продолжил
  использовать конфигурацию старого inode: runtime оставался на единственной
  раскладке `us` и автоматическом monitor layout, хотя новый файл проходил
  `Hyprland --verify-config`. Явный полный `hyprctl reload` применил сохранённые
  input/monitor settings. Это не выполняется обычным install автоматически.
- Старый `CLAUDE.md` заменён указателем на `AGENTS.md`; факты прежней структуры
  отражены здесь.

## Оставшиеся ручные действия

- На новых хостах создать при необходимости локальный `monitors.conf` и fragment,
  который его подключает; не коммитить аппаратно-зависимое значение как common.
- Проверить наличие/пути `~/.face`, `notion-calendar-electron`, Wofi fragment и
  polkit authentication agent.
- На реальной macOS выполнить `doctor`, dry-run, install/restow/uninstall во
  временном HOME и проверить BSD userland. Linux simulation не считается
  фактической macOS-проверкой.
- Установить TPM/plugins только вручную, если они нужны.
- При первом подключении или изменении Firefox extension вручную перезагрузить
  её; дальнейший light/dark выбор следует системному appearance.
- Перед commit проверить полный diff и убедиться, что migration backups, local
  overrides и персональные artifacts ignored.

### Статус проверок миграции

Проверки выполнены 19 июля 2026 года на Arch Linux. Симуляция Darwin проверяет
только логику выбора и shell-переносимость, но не заменяет реальную macOS.

| Проверка | Статус |
| --- | --- |
| `git status`, remote/branch и отсутствие изменения истории | успешно: `master`, HEAD `8b38a297…`, remote не изменён, push/rewrite не выполнялись |
| Отсутствие nested `.git`, `.git` files и gitlink mode `160000` | успешно для итогового staged tree; `.gitmodules` отсутствует |
| Отсутствие broken symlink внутри репозитория | успешно, `.git` и ignored migration backup исключены из обхода |
| `sh -n`/`zsh -n`; shellcheck/shfmt при наличии | синтаксис успешно; `shellcheck` и `shfmt` отсутствуют, не устанавливались |
| Stow dry-run во временном HOME | успешно, включая путь с пробелом |
| Install → repeated install/restow → uninstall | успешно в temp HOME; повторный live install также успешен |
| Conflict detection и recoverable backup | успешно в temp fixture и live для двух обычных файлов |
| Archive не попадает в установку; выбранные targets уникальны | успешно для 15 Arch-пакетов |
| Theme apply/toggle и byte-identical result | успешно для Basic/Pro; checksum-списки совпали, `git status` не меняется |
| Invalid theme не меняет предыдущий complete output | успешно: incomplete palette отклонена, runtime target не изменился |
| Live theme adapters | успешно в изолированном fixture для Linux `gsettings`, macOS `osascript`, строгой ошибки и обнаружения неожиданного изменения monitor/input state Hyprland; реальные system settings не менялись |
| Zsh/Neovim live integration | успешно: shell helper найден через Stow `.zshrc`, Neovim сменил dark/light по runtime path без сигналов |
| Neovim headless offline без plugin download/update | успешно с отдельными HOME/XDG и `DOTFILES_OFFLINE=1` |
| Isolated tmux config check | успешно в отдельном tmux server/socket под `/tmp` |
| Neovim/tmux bundles verify и recovery clone | успешно для всех четырёх bundles; восстановленные HEAD совпали |
| Simulated macOS и unknown Linux platform fixtures | успешно: macOS выбрал common+macOS; unknown Linux common+linux и отказ от package manager |
| Hyprland live config | после явного reload ошибок нет; runtime подтверждает `us,ru`, `grp:win_space_toggle`, DP-3 165 Hz в `0x0` и вертикальный DP-1 в `-1080x0` |
| Переключение раскладки | успешно переключено English → Russian → English через Hyprland IPC |
| `shellcheck` и `shfmt` | пропущены: инструменты отсутствуют |
| Реальная macOS | не выполнялась; требуется macOS-хост |

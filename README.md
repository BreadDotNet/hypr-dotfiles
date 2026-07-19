# Dotfiles

Персональные конфигурации для Arch Linux, macOS и других Linux-систем. GNU Stow
остаётся основным механизмом размещения файлов в `$HOME`; небольшой CLI
выбирает платформенные manifests, заранее ищет конфликты и управляет общей
цветовой темой.

Репозиторий не устанавливает пакеты, не меняет login shell и не применяет
системные настройки при обычной установке dotfiles.

## Поддерживаемые системы

- **Arch Linux** — common, Linux и Arch manifests; официальный список пакетов
  отделён от AUR.
- **macOS** — common и macOS manifests; пакеты описываются `Brewfile`, но
  Homebrew автоматически не устанавливается.
- **Другой Linux** — common и Linux manifests. Менеджер пакетов намеренно не
  угадывается.

Фактическая миграция и основные проверки выполнялись на Arch Linux. Ветка macOS
проверяется изолированно на уровне выбора manifests и переносимости shell-кода,
но это не заменяет запуск на настоящем macOS-хосте.

## Зависимости

Для управления dotfiles нужны:

- POSIX-совместимый `/bin/sh`;
- Git;
- GNU Stow.

Приложения из `packages/` нужны только для использования соответствующих
конфигураций. `doctor` показывает найденные и отсутствующие обязательные и
необязательные инструменты.

## Структура

```text
.
├── bin/dotfiles          # единая точка входа
├── packages/             # единственный корень активных Stow-пакетов
├── manifests/            # common/linux/arch/macos наборы пакетов
├── packages-list/        # pacman, AUR и Homebrew списки
├── scripts/
│   ├── lib/              # общая логика CLI
│   ├── platforms/        # платформенные адаптеры
│   └── tests/            # изолированные проверки
├── themes/
│   ├── palettes/terminal-macos.env
│   ├── terminal-basic.env
│   ├── terminal-pro.env
│   ├── default
│   ├── templates/
│   └── generated/
├── firefox/              # extension, следующий системному light/dark
├── hosts/                # примеры и host-specific данные без секретов
├── archive/legacy/       # сохранённые, но не устанавливаемые конфиги
├── AUDIT.md              # аудит и журнал миграции
└── AGENTS.md             # правила дальнейшей разработки
```

Сгенерированные файлы темы — воспроизводимые артефакты. Источник истины — файл
палитры в `themes/`, а не содержимое `themes/generated/`.

## Быстрый старт: Arch Linux

```sh
git clone git@github.com:BreadDotNet/hypr-dotfiles.git ~/dotfiles
cd ~/dotfiles
./bin/dotfiles doctor
./bin/dotfiles install --dry-run
./bin/dotfiles install
```

Если установка заменила активный `hyprland.conf` в уже запущенной сессии,
Hyprland может продолжить использовать старый inode до явного reload. Сначала
проверьте новый конфиг, затем осознанно примените его:

```sh
Hyprland --verify-config --config "$HOME/.config/hypr/hyprland.conf"
hyprctl reload
hyprctl configerrors
```

Обычный `install` намеренно не перезагружает compositor. Явная команда
переключения темы использует только `hyprctl reload config-only`, предварительно
проверяет конфиг и сравнивает monitor/input state до и после reload.

Обычный `install` не вызывает `pacman`, `sudo` или AUR helper. Сначала изучите
списки:

```sh
./bin/dotfiles packages list
```

Установка официальных Arch-пакетов — отдельное явное действие:

```sh
./bin/dotfiles packages install
```

Команда может вызвать `sudo pacman -S --needed`, поэтому запускайте её только
осознанно. `packages-list/arch-aur.txt` — информационный список: CLI не выбирает
и не запускает AUR helper.

## Быстрый старт: macOS

Установите Xcode Command Line Tools, GNU Stow и, если хотите пользоваться
`Brewfile`, Homebrew самостоятельно. Затем:

```sh
git clone git@github.com:BreadDotNet/hypr-dotfiles.git ~/dotfiles
cd ~/dotfiles
./bin/dotfiles doctor
./bin/dotfiles install --dry-run
./bin/dotfiles install
```

`packages install` использует существующий Homebrew и `packages-list/Brewfile`.
Установка Homebrew и применение `defaults` не входят в этот workflow.

## Dry-run и отдельные пакеты

Всегда начинайте с dry-run:

```sh
./bin/dotfiles list
./bin/dotfiles install --dry-run
./bin/dotfiles restow --dry-run
./bin/dotfiles uninstall --dry-run
```

Установить только один явно выбранный Stow-пакет можно так:

```sh
./bin/dotfiles install --package nvim --dry-run
./bin/dotfiles install --package nvim
```

CLI не зависит от текущего рабочего каталога. Повторный `install` и `restow`
идемпотентны. `archive/legacy` не входит ни в один manifest.

## Конфликты, резервные копии и откат

Перед изменениями CLI сравнивает конечные пути всех выбранных пакетов и
проверяет `$HOME`. Обычный файл или ссылка, не принадлежащая этому репозиторию,
не удаляется автоматически: установка останавливается и показывает путь.

После проверки конфликта его можно вручную переместить в безопасное место и
повторить dry-run. Либо явно запросите восстановимую резервную копию:

```sh
./bin/dotfiles install --dry-run --backup-conflicts
./bin/dotfiles install --backup-conflicts
```

Копии хранятся под `~/.local/state/dotfiles/backups/`. `stow --adopt` не
используется, поскольку он может незаметно изменить файлы в репозитории.

Удалить только управляемые ссылки:

```sh
./bin/dotfiles uninstall --dry-run
./bin/dotfiles uninstall
```

Затем восстановите свой файл из созданной резервной копии. Инвентаризация
ссылок, существовавших до миграции на текущей машине, сохранена в игнорируемом
`.migration-backups/live-links/before.txt`.

## Цветовая тема

Доступна пара переносимых совместимых палитр, основанных на стандартном стиле
macOS Terminal, но не обещающих идентичный рендеринг конкретной Terminal.app:

- `terminal-basic` — светлая;
- `terminal-pro` — тёмная.

Общие 16 ANSI-цветов и семантические токены хранятся один раз в
`themes/palettes/terminal-macos.env`; variant-файлы задают фон, текст, surface и
режим `light`/`dark`.

```sh
./bin/dotfiles theme list
./bin/dotfiles theme current
./bin/dotfiles theme toggle --dry-run
./bin/dotfiles theme toggle
./bin/dotfiles theme apply terminal-pro
./bin/dotfiles theme apply terminal-basic --no-reload
```

Генератор сначала проверяет палитру, создаёт и валидирует полный набор временных
файлов и лишь затем атомарно переключает runtime-ссылку
`~/.config/dotfiles/theme` на `themes/generated/<name>-<content-hash>/`. Эта
ссылка является runtime-state, а не отслеживаемым Git-файлом, поэтому обычное
переключение не меняет `git status`. Ошибка генерации оставляет предыдущую тему;
ошибка Hyprland preflight также восстанавливает прежнюю ссылку.

В интерактивном Zsh доступны короткие команды:

```sh
theme              # toggle
theme light
theme dark
theme current
theme list
```

Явные `theme apply` и `theme toggle` переключают тему на лету и синхронизируют
системный appearance: Linux использует доступный writable `gsettings`, macOS —
`osascript` appearance preferences. Это влияет на GTK-приложения и Firefox.
`--no-reload` меняет только runtime-ссылку, не посылает сигналы и не меняет
системный режим. `install`/`restow` всегда используют именно этот безопасный
вариант и только создают светлую тему, если выбор отсутствует.

Live-интеграции: Kitty перечитывает конфиг, Waybar получает `SIGUSR2`, tmux
выполняет `source-file`, Hyprland проходит verify и `config-only` reload. Текущий
Zsh обновляется сразу, другие shell — на следующем prompt; Neovim проверяет
runtime на focus/idle. Starship/fzf обновляются с shell, а Ghostty, Wofi и
Hyprlock гарантированно используют новую тему при следующем запуске.

Интеграции создаются только для конфигураций, уже присутствующих в репозитории:
Kitty, optional Ghostty, Zsh/fzf, Neovim, tmux, Starship, Hyprland/Hyprlock,
Waybar, Wofi и Firefox theme extension. Gitu использует ANSI-имена и наследует
палитру терминала; Yazi сохраняет существующую Catppuccin Mocha theme.
Firefox bundle содержит обе палитры и следует `prefers-color-scheme`; его рабочие
файлы ссылаются на стабильные templates/generated artifacts, а локальные AMO UUID
и build artifacts по-прежнему игнорируются.

Для локальной корректировки создайте игнорируемый `themes/local.env`. Для
машинной корректировки используйте `hosts/<name>/theme.env`; оба файла должны
содержать только разрешённые цветовые переменные и не должны хранить секреты.

## Host-specific настройки

Host overlay применяется после common и platform fragments:

```text
common → linux → arch/macos → host → local
```

Необязательные fragment-файлы подключаются только если существуют. Скопируйте
`hosts/example` под имя машины, добавьте безопасные настройки и
`hosts/<name>/manifest.txt`, перечисляющий host-пакеты из `packages/`. Выберите
хост через `--host NAME`. Не коммитьте реальные имена, если они раскрывают
приватную информацию; можно использовать нейтральный псевдоним.

Файл `monitors.conf` по определению зависит от оборудования. Пример находится в
`hosts/example/hypr/`; реальный локальный файл не должен перезаписываться общей
установкой.

## Локальные настройки и секреты

Секреты не принадлежат этому репозиторию. Храните токены, SSH-ключи,
сертификаты, history, cookie и персональные данные вне Git и подключайте их через
игнорируемый локальный fragment, например:

```text
~/.config/dotfiles/shell/local.zsh
```

Fragment должен безопасно отсутствовать. Для настоящих секретов предпочтителен
системный keychain или отдельный secret manager; тема и host manifests не
являются secret storage.

## Добавление приложения

1. Создайте `packages/<app>/` с деревом путей относительно `$HOME`.
2. Убедитесь, что targets не дублируют другой автоматически выбранный пакет.
3. Добавьте имя пакета только в подходящий manifest.
4. Если приложение использует общую тему, добавьте template и проверку
   сгенерированного формата; не копируйте HEX-значения в основной конфиг.
5. Выполните dry-run, двукратную установку и uninstall во временном HOME.

Не добавляйте конфигурацию неиспользуемого приложения только для демонстрации.

## Добавление Linux-дистрибутива

1. Добавьте адаптер `scripts/platforms/<id>.sh` с определением платформы и только
   специфичной для неё логикой.
2. Зарегистрируйте соответствие `ID` из `/etc/os-release` адаптеру в
   `scripts/lib/platform.sh`.
3. Добавьте `manifests/<id>.txt`; общий Linux manifest не копируйте.
4. При необходимости добавьте отдельный package list и явную реализацию
   `packages install`.
5. Добавьте fixture, которая проверяет выбор `common → linux → <id>`.

Неизвестный дистрибутив обязан продолжать устанавливать common+linux и
отказываться от установки пакетов с понятным сообщением.

## Neovim после миграции

`packages/nvim` теперь обычная часть основного репозитория; отдельный clone или
submodule не нужен. `lazy-lock.json` сохранён. Offline headless-проверка с
`DOTFILES_OFFLINE=1` выполнена без клонирования или обновления плагинов.

История прежнего вложенного репозитория сохранена локально на машине миграции:

```text
.migration-backups/neovim/
  kickstart.nvim-6cd07b54e2b0aeaffd39c7d604f08a9592453aa5.bundle
  gitdir-6cd07b54e2b0aeaffd39c7d604f08a9592453aa5/
```

Этот каталог исключён из Git и потому отсутствует в свежем clone. Исходный
remote: `git@github.com:BreadDotNet/kickstart.nvim.git`, branch `master`, HEAD
`6cd07b54e2b0aeaffd39c7d604f08a9592453aa5`.

Проверка и восстановление bundle в новый каталог:

```sh
git bundle verify .migration-backups/neovim/kickstart.nvim-6cd07b54e2b0aeaffd39c7d604f08a9592453aa5.bundle
git clone .migration-backups/neovim/kickstart.nvim-6cd07b54e2b0aeaffd39c7d604f08a9592453aa5.bundle /tmp/kickstart-nvim-recovery
```

## tmux и TPM

Сторонние исходники tmux-плагинов больше не должны быть частью основного Git.
Основной конфиг условно загружает тему, local fragment и TPM, поэтому tmux
работает и без них.

TPM устанавливается только отдельным ручным сетевым действием:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

После этого запустите tmux и нажмите `prefix` + `I`, если хотите загрузить
объявленные плагины. Перед этим проверьте их список в `.tmux.conf`. Старые
checkout и bundles сохранены локально в `.migration-backups/tmux-plugins/`.

## Известные ограничения

- macOS пока не проверена на реальном Mac.
- Обычная установка не меняет system settings, login shell, Homebrew или AUR.
  Однако явная команда `theme apply/toggle` по выбранному workflow меняет
  системный light/dark appearance; `--no-reload` отключает этот эффект.
- `~/.face`, hardware-specific `monitors.conf`, команда
  `notion-calendar-electron`, Wofi theme fragment и polkit agent должны быть
  проверены владельцем машины; CLI не создаёт их из предположений.
- Firefox extension реагирует на системный appearance после загрузки extension;
  первое подключение или обновление её файлов может требовать ручной reload.
- Neovim plugins и tmux plugins не загружаются во время безопасных проверок.
- Локальный `monitors.conf` на машине миграции сохранён обычным файлом и
  подключён через неотслеживаемый `conf.d/90-host.conf`; на других машинах этот
  fragment нужно создать самостоятельно.

## Проверки

Основные команды:

```sh
git status --short
./bin/dotfiles doctor
./bin/dotfiles install --dry-run
./bin/dotfiles theme apply terminal-basic --dry-run
sh -n bin/dotfiles
find scripts -type f -name '*.sh' -exec sh -n {} \;
./scripts/tests/theme-reload.sh
./scripts/tests/smoke.sh
```

Также проверяются временный HOME (install → повторный install/restow →
uninstall), отсутствие nested Git/gitlinks/broken links, конфликтующие targets,
детерминированность theme generation и offline Neovim headless. Полный журнал и
пропущенные из-за отсутствующих инструментов проверки находятся в `AUDIT.md`.

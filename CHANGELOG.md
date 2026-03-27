# Changelog

All notable changes to this project will be documented in this file.

## [0.1.2] - 2026-03-27

### Fixed
- Fix shift-left/right directory navigation: avoid inline-expanding `_ZSHIFT_LIST_ALL_CMD` which caused quoting breakage in awk scripts
- Fix shift-left: pass `b` value via `printf %s` instead of broken action construction
- Fix multi-select: use `${(f)picks}` for reliable newline splitting in zsh
- Fix shift navigation key bindings (debug and stabilize)

### Added
- i18n support for fzf header: shows English or Japanese based on system locale (`LANG`/`LC_ALL`)

### Documentation
- Add English README with Japanese translation link
- Add screenshot and replace Demo section in README
- Japanize all headings in README.ja.md
- Remove inaccurate rows from feature comparison table

### Install
- Add `source ~/.zshrc` step to Homebrew install instructions

## [0.1.1] - 2026-03-12

### Fixed
- Fix Homebrew Formula install path: create `share/zshift` subdirectory properly

## [0.1.0] - 2026-03-12

### Added
- Initial release: zshift — supercharged Ctrl+T for zsh
  - Path-aware Ctrl+T file/directory picker powered by fzf
  - Shift+← / Shift+→ to navigate directories without leaving the picker
  - `~` key to jump to home directory
  - Cyan highlight for directories, gray for files
  - Multi-select support
  - zoxide integration (`z` / `zi`)
  - Homebrew Formula for easy installation

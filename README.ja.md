# zshift

**zsh のファイル選択を、もっと速く、もっと賢く。**

[English](README.md)

`Ctrl+T` を押すだけで、ファイルやディレクトリを fzf で一覧表示。矢印キーでディレクトリをその場で潜り、`~` でホームに一発ジャンプ。fzf のパワーを活かしつつ、zsh ネイティブの操作感を壊さない――そんなファイルナビゲーションを実現します。

## Demo

<!-- ![demo](assets/demo.gif) -->

## Why zshift?

| 素の fzf `Ctrl+T` | zshift |
|---|---|
| フラットな一覧を検索するだけ | **Shift+矢印でディレクトリを行き来** しながら探せる |
| 選択するまで中身がわからない | ディレクトリは **水色**、ファイルは **グレー** で一目瞭然 |
| ホームに戻るには打ち直し | **`~` キー一発** でホームへジャンプ |
| パスが絶対パスで長い | `~/...` や `./...` の **短い表記** で自動挿入 |
| 空ディレクトリで迷子 | 空なら自動で `..` を表示、**行き止まりなし** |
| 権限エラーで無言 | **ピンクの警告メッセージ** でわかりやすく通知 |

## Features

- **Shift+← / Shift+→** でディレクトリをインタラクティブに移動
- **`~` キー** でホームディレクトリへ即座にジャンプ
- **複数選択対応** ── `Tab` で複数ファイルを選んでまとめて挿入
- `~/` 配下のパスは `~` 表記を保持したまま挿入
- カレントディレクトリ配下は `./` 付きで挿入
- 権限のないディレクトリに入ろうとすると **ピンクの警告** を表示

## Requirements

- **zsh**
- [**fzf**](https://github.com/junegunn/fzf)
- [**zoxide**](https://github.com/ajeetdsouza/zoxide) ── `z` / `zi` による高速ディレクトリ移動

## Install

### Homebrew（推奨）

```zsh
brew install ayumuwall/tap/zshift
```

インストール後、`~/.zshrc` に以下を追加してください:

```zsh
source $(brew --prefix)/share/zshift/zshift.zsh
```

### zinit

```zsh
zinit light ayumuwall/zshift
```

### sheldon

```toml
[plugins.zshift]
github = "ayumuwall/zshift"
```

### 手動

```zsh
git clone https://github.com/ayumuwall/zshift.git ~/.zsh/zshift
echo 'source ~/.zsh/zshift/zshift.zsh' >> ~/.zshrc
```

## Usage

### `Ctrl+T` ── ファイル選択

コマンドラインのどこでも `Ctrl+T` を押すと、カレントディレクトリの中身が fzf で表示されます。

```
  Documents/          # 水色 = ディレクトリ
  Downloads/
  ./README.md         # グレーの ./ = ファイル
  ./setup.sh

  Shift+←→:ディレクトリ移動  ~:ホーム  Enter:確定
```

### キー操作

| キー | 動作 |
|---|---|
| `Shift+→` | 選択中のディレクトリに入る |
| `Shift+←` | 親ディレクトリに戻る |
| `~` | ホームディレクトリへジャンプ |
| `Tab` | 複数選択のトグル |
| `Enter` | 確定してコマンドラインに挿入 |
| `Esc` | キャンセル |

### `z` ── zoxide 連携

zshift は zoxide を `zi`（インタラクティブ選択）モードで初期化します。`z` と打つだけで、過去に訪れたディレクトリから fzf で選択できます。

## Tips

- 入力途中のパスがあれば、そのパスを起点にブラウズを開始します
  ```
  vim src/<Ctrl+T>   # src/ の中身が表示される
  ```
- 元の fzf `Ctrl+T` は `Ctrl+G` に退避されるので、いつでも使えます

## Platform

- **macOS** で動作確認済み
- Linux では `stat` コマンドの差異により追加対応が必要です（PR 歓迎）

## License

[MIT](LICENSE)

# dotfiles-core

プライベート/仕事で共通する dotfiles の設定。

> [!IMPORTANT]
> このリポジトリは private リポジトリ `mm1995tk/platform` から CI で自動配信される
> **読み取り専用ミラー**です。ここへ直接コミットしても次回の同期で上書きされます。
> 編集は platform 側（`dotfiles/modules/`）で行うこと。

## 使い方

flake のトップレベル output に機能単位の Home Manager モジュールがある
（現在: `agent-bridge` / `ghostty` / `helix` / `hunk` / `kitty` / `shijimi` / `starship` / `yazi` / `zsh`）。

```nix
# flake.nix
inputs.dotfiles-core.url = "github:mm1995tk/dotfiles-core";
```

消費側のモジュールで必要なものだけ import する:

```nix
{
  imports = [
    dotfiles-core.zsh
    dotfiles-core.starship
  ];
}
```

import した上で、消費側で `programs.<name>` に差分を足して拡張できる。
git の user.name / user.email などの個人情報はこのリポジトリには置かず、
消費側のリポジトリで設定する。

`shijimi` は設定だけを持つ。オプション `programs.shijimi-editor` と本体は
[mm1995tk/shijimi-editor](https://github.com/mm1995tk/shijimi-editor) の flake が持つので、それも import する:

```nix
{
  imports = [
    inputs.shijimi.homeManagerModules.default # inputs.shijimi.url = "github:mm1995tk/shijimi-editor";
    dotfiles-core.shijimi
  ];
}
```

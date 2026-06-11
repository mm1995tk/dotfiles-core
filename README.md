# dotfiles-core

プライベート/仕事で共通する dotfiles の設定。

> [!IMPORTANT]
> このリポジトリは private リポジトリ `mm1995tk/homelab` の `dotfiles-core/`
> ディレクトリから CI で自動同期される**読み取り専用ミラー**です。
> ここへ直接コミットしても次回の同期で上書きされます。編集は homelab 側で行うこと。

## 使い方

flake のトップレベル output に機能単位の Home Manager モジュールがある
（`modules/` 直下から自動発見される。現在: `helix` / `neovim` / `starship` / `wezterm` / `zsh`）。

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

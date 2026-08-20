# dotfiles-core

プライベート/仕事で共通する dotfiles の設定。

> [!IMPORTANT]
> このリポジトリは private リポジトリ `mm1995tk/homelab` から CI で自動配信される
> **読み取り専用ミラー**です。ここへ直接コミットしても次回の同期で上書きされます。
> 編集は homelab 側（`dotfiles/modules/`）で行うこと。

## 使い方

flake のトップレベル output に機能単位の Home Manager モジュールがある
（現在: `helix` / `hunk` / `nixvim` / `starship` / `wezterm` / `yazi` / `zsh`）。

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

`nixvim` だけは `programs.nixvim` のオプションを宣言しないので、消費側で
[nixvim](https://github.com/nix-community/nixvim) 本体のモジュールと重ねて import する:

```nix
{
  imports = [
    nixvim.homeModules.nixvim
    dotfiles-core.nixvim
  ];
}
```

import した上で、消費側で `programs.<name>` に差分を足して拡張できる。
git の user.name / user.email などの個人情報はこのリポジトリには置かず、
消費側のリポジトリで設定する。

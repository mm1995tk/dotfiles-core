# このファイルは mm1995tk/platform の dotfiles/dist/ から生成されている。直接編集しない。
{
  description = "Nix System Configuration";

  outputs = _: {
    ghostty = ./modules/ghostty.nix;
    kisui-terminal = ./modules/kisui-terminal.nix;
    kitty = ./modules/kitty.nix;
    shijimi = ./modules/shijimi;
    starship = ./modules/starship;
    zsh = ./modules/zsh;
  };
}

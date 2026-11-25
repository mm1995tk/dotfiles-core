# このファイルは mm1995tk/platform の dotfiles/dist/ から生成されている。直接編集しない。
{
  description = "Nix System Configuration";

  outputs = _: {
    kisui-terminal = ./modules/kisui-terminal.nix;
    shijimi = ./modules/shijimi;
    starship = ./modules/starship;
    zsh = ./modules/zsh;
  };
}

# このファイルは mm1995tk/homelab の dotfiles/dist/ から生成されている。直接編集しない。
{
  description = "Nix System Configuration";

  outputs = _: {
    helix = ./modules/helix.nix;
    nixvim = ./modules/nixvim.nix;
    starship = ./modules/starship;
    wezterm = ./modules/wezterm;
    zsh = ./modules/zsh;
  };
}

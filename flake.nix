# このファイルは mm1995tk/homelab の home/dist/ から生成されている。直接編集しない。
{
  description = "Nix System Configuration";

  outputs = _: {
    helix = ./modules/helix.nix;
    neovim = ./modules/neovim.nix;
    starship = ./modules/starship;
    wezterm = ./modules/wezterm;
    zsh = ./modules/zsh;
  };
}

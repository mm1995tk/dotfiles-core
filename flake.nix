# このファイルは mm1995tk/homelab の dotfiles/dist/ から生成されている。直接編集しない。
{
  description = "Nix System Configuration";

  outputs = _: {
    agent-bridge = ./modules/agent-bridge;
    helix = ./modules/helix.nix;
    hunk = ./modules/hunk.nix;
    nixvim = ./modules/nixvim.nix;
    starship = ./modules/starship;
    wezterm = ./modules/wezterm;
    yazi = ./modules/yazi.nix;
    zsh = ./modules/zsh;
  };
}

# このファイルは mm1995tk/platform の dotfiles/dist/ から生成されている。直接編集しない。
{
  description = "Nix System Configuration";

  outputs = _: {
    agent-bridge = ./modules/agent-bridge;
    alacritty = ./modules/alacritty.nix;
    helix = ./modules/helix.nix;
    hunk = ./modules/hunk.nix;
    starship = ./modules/starship;
    wezterm = ./modules/wezterm;
    yazi = ./modules/yazi.nix;
    zsh = ./modules/zsh;
  };
}

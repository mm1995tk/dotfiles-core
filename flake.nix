# このファイルは mm1995tk/platform の dotfiles/dist/ から生成されている。直接編集しない。
{
  description = "Nix System Configuration";

  outputs = _: {
    agent-bridge = ./modules/agent-bridge;
    dageki = ./modules/dageki;
    ghostty = ./modules/ghostty.nix;
    helix = ./modules/helix.nix;
    hunk = ./modules/hunk.nix;
    kitty = ./modules/kitty.nix;
    starship = ./modules/starship;
    yazi = ./modules/yazi.nix;
    zsh = ./modules/zsh;
  };
}

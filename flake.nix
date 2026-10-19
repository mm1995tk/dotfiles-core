# このファイルは mm1995tk/platform の dotfiles/dist/ から生成されている。直接編集しない。
{
  description = "Nix System Configuration";

  outputs = _: {
    agent-bridge = ./modules/agent-bridge;
    ghostty = ./modules/ghostty.nix;
    helix = ./modules/helix.nix;
    hunk = ./modules/hunk.nix;
    kitty = ./modules/kitty.nix;
    shijimi = ./modules/shijimi;
    starship = ./modules/starship;
    yazi = ./modules/yazi.nix;
    zsh = ./modules/zsh;
  };
}

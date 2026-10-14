{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    dotDir = "${config.xdg.configHome}/zsh";
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    plugins = [
      {
        name = "nix-zsh-completions";
        src = pkgs.nix-zsh-completions.src;
      }
    ];
    loginExtra = ''
      mkdir -p $HOME/workspace
    '';
    shellAliases = {
      grep = "grep --colour=auto";
      la = "ls -A";
      ll = "ls -lh";
      mv = "mv -i";
      z = "cd";
      zi = "cdi";
    };
    initContent = lib.mkAfter ''
      zstyle ':completion:*:default' menu select=1
      . ${./index.zsh}
    '';
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };
}

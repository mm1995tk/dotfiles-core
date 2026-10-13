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
      # Enter は改行を入れるだけにし、実行は Ctrl-J（端末が cmd+Enter に送らせる文字。modules/ghostty.nix）。
      # 複数行のコマンドを Enter で書き足せるようにするため。この割り当てを知らない端末でも Ctrl-J で実行できる。
      # 補完のメニューの中では Enter で候補を確定する（未割り当てだと確定したあと改行まで入る）。
      bindkey '^M' self-insert-unmeta
      zmodload zsh/complist
      bindkey -M menuselect '^M' accept-line
      . ${./index.zsh}
    '';
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };
}

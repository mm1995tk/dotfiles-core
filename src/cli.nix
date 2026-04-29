_: {
  # CLI環境とGUI環境を分離しているのは、開発時に導入したツールやスクリプトの実行を
  # コンテナ内で安全に隔離して行うためです。
  #
  # direnvをCLIのみに限定しているのは、ホストOS側で `direnv allow` を実行しても
  # 本環境の構成上意味をなさないためです。
  # 常にコンテナ内でのみ実行を許可し、安全な開発コンテキストを維持することを意図しています。
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}

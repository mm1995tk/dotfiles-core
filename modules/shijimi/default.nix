# shijimi（VS Code の画面と Helix の操作の TUI エディタ。コマンドは shj、nightly 版は shj-nightly）の設定。
# オプション programs.shijimi-editor は shijimi-editor の flake の home-manager モジュールが宣言するので、
# 使う側はそれも import する（platform では dotfiles/default.nix が重ね、nightly 版を入れる）。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.shijimi-editor;
  # nightly 版は設定を ~/.config/shijimi-editor-nightly/ から読み、安定版と並べて入れられる。
  # 本体のモジュールの languages は版によらず ~/.config/shijimi-editor/ に書くので、使わずに
  # 入れた版の置き場へ自分で書く。
  nightly = cfg.package.meta.mainProgram == "shj-nightly";
  configDir = if nightly then "shijimi-editor-nightly" else "shijimi-editor";
  toml = pkgs.formats.toml { };
in
{
  config = lib.mkMerge [
    { programs.shijimi-editor.enable = lib.mkDefault true; }
    (lib.mkIf cfg.enable {
      # git のコミットメッセージなど、他のツールが開くエディタも shijimi にする。ファイルを渡すと単体編集
      # モード（ツリー・LSP・ターミナルを起動しない）で開く。キー単位で mkDefault にするのは、セット全体に
      # 掛けると別のモジュールが home.sessionVariables を定義した時点で既定値が丸ごと消えるため。
      home.sessionVariables = {
        EDITOR = lib.mkDefault "shj";
        VISUAL = lib.mkDefault "shj";
      };
      # 形式は Helix の languages.toml と同じで、組み込みの既定値に name ごとに重ねる（既定の nix は nil）。
      xdg.configFile."${configDir}/languages.toml".source = toml.generate "shijimi-languages.toml" {
        language-server.nixd.command = lib.getExe pkgs.nixd;
        language = [
          {
            name = "nix";
            language-servers = [ "nixd" ];
          }
        ];
      };
      # shj でも nightly 版が起動するようにする。nightly 版が書き出す skill も shj を呼ぶので、エイリアスでは
      # なく PATH のコマンドにして、対話でないシェル（コーディングエージェント）からも届くようにする。
      home.packages = lib.mkIf nightly [
        (pkgs.writeShellScriptBin "shj" ''exec ${lib.getExe cfg.package} "$@"'')
      ];
    })
  ];
}

# kisui-terminal（ターミナルのデスクトップアプリ）の設定。オプション programs.kisui-terminal は
# kisui-terminal の flake の home-manager モジュールが宣言するので、使う側はそれも import する
# （platform では dotfiles/default.nix が重ねる）。
#
# アプリ本体は Release の .dmg から入れて自動更新で更新しているので、package = null にして設定ファイルだけを置く。
# 試しているのは nightly 版（kisui-terminal-nightly）なので、channel = "nightly" で
# ~/.config/kisui-terminal-nightly/ に置く。nightly 版はこのフォルダがあれば普通の版のフォルダを読まない。
{
  programs.kisui-terminal = {
    enable = true;
    package = null;
    channel = "nightly";
    settings = {
      # 内蔵ブラウザとパスキーの連携を試す。パスキーを使うサイトを開くと、Chrome か Firefox に移って
      # ログインし、拡張機能が Cookie を内蔵ブラウザに戻す。
      gui.browser = {
        enabled = true;
        passkey_sites = [
          "github.com"
          "accounts.google.com"
        ];
      };
    };
  };
}

# Kitty の窓と文字の設定。分割・タブ・作業の永続化は多重化ツール（standard では herdr。
# 起動のしかたは features/herdr-desktop.nix）が担当するので、Kitty 自身は 1 枚の窓だけを持つ。
{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
  ];

  programs.kitty = {
    enable = true;
    themeFile = "GitHub_Dark";
    font.name = "JetBrainsMono Nerd Font Mono";
    shellIntegration.enableZshIntegration = true;
    darwinLaunchOptions = ["--directory=~/workspace"];

    settings = {
      disable_ligatures = "always";
      remember_window_size = false;
      initial_window_width = "178c";
      initial_window_height = "48c";
      window_padding_width = 8;
      macos_option_as_alt = "yes";
    };

    # Kitty の中に窓やタブを作ると多重化ツールのものと二重になり、どちらのキーで動かすかを
    # 取り違えるので、既定のキーを潰しておく。
    keybindings = {
      "cmd+enter" = "no_op";
      "kitty_mod+enter" = "no_op";
      "cmd+t" = "no_op";
      "kitty_mod+t" = "no_op";
      "alt+cmd+space" = "kitten hints";
      "shift+enter" = "send_text all \\n";
    };

    mouseBindings = {
      "cmd+left press" = "grabbed discard_event";
      "cmd+left release" = "grabbed,ungrabbed mouse_handle_click link";
    };

    # OS のフォールバック順に日本語の字形を任せない。Kitty はフォールバックの
    # 順序リストではなく、文字範囲ごとにフォントを指定する。
    extraConfig = ''
      symbol_map U+3000-U+30FF,U+31F0-U+31FF,U+3400-U+4DBF,U+4E00-U+9FFF,U+F900-U+FAFF,U+FF00-U+FFEF,U+20000-U+2FA1F,U+30000-U+323AF Noto Sans Mono CJK JP
    '';
  };
}

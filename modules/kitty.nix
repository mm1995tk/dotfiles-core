# Kitty の窓と文字の設定。作業の永続化と workspace の管理は herdr が担当するので、
# Kitty 自身は通常のローカル端末として起動する。
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
      initial_window_width = "120c";
      initial_window_height = "30c";
      enabled_layouts = "splits,stack";
      macos_option_as_alt = "yes";
      tab_title_template = "{session_name} {title} {keyboard_mode}";
    };

    # キーは WezTerm と揃える。Kitty 内の分割を操作するためのもので、
    # herdr 内のペインには herdr のキーを使う。
    keybindings = {
      "cmd+backslash" = "launch --location=vsplit --cwd=current";
      "ctrl+backslash" = "launch --location=hsplit --cwd=current";
      "alt+cmd+right" = "neighboring_window right";
      "alt+cmd+left" = "neighboring_window left";
      "alt+cmd+h" = "neighboring_window left";
      "alt+cmd+j" = "neighboring_window down";
      "alt+cmd+k" = "neighboring_window up";
      "alt+cmd+l" = "neighboring_window right";
      "alt+cmd+z" = "toggle_layout stack";
      "alt+cmd+p" = "focus_visible_window";
      "alt+cmd+s" = "swap_with_window";
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

      map --new-mode resize_pane alt+cmd+r
      map --mode resize_pane h resize_window narrower 3
      map --mode resize_pane l resize_window wider 3
      map --mode resize_pane j resize_window taller 3
      map --mode resize_pane k resize_window shorter 3
      map --mode resize_pane left resize_window narrower 3
      map --mode resize_pane right resize_window wider 3
      map --mode resize_pane down resize_window taller 3
      map --mode resize_pane up resize_window shorter 3
      map --mode resize_pane esc pop_keyboard_mode
      map --mode resize_pane enter pop_keyboard_mode
    '';
  };
}

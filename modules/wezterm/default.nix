{pkgs, ...}: {
  # wezterm.lua の font_with_fallback が名前で参照する日本語フォント。
  # これを入れないと CJK のフォールバック先が OS 任せになり、マシンごとに字形が変わる。
  home.packages = [pkgs.noto-fonts-cjk-sans];

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}

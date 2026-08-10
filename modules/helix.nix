{...}: {
  # https://home-manager-options.extranix.com/?query=helix&release=release-25.05
  programs.helix = {
    enable = true;

    languages = {
      # https://docs.helix-editor.com/languages.html
      language = [
        {
          name = "go";
          language-id = "go";
          indent = {
            tab-width = 2;
            unit = "  ";
          };
        }
      ];
    };

    settings = {
      theme = "rose_pine_moon_matte";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        true-color = true;
        popup-border = "all";
        file-picker.hidden = false;
      };
    };

    # rose_pine_moon の text #e0def4 は紫寄りの白で、同じく紫がかった背景
    # #232136 と並ぶと同時対比でくすんで見える。wezterm / starship と同じ
    # ニュートラルな白に差し替える。
    themes.rose_pine_moon_matte = {
      inherits = "rose_pine_moon";
      palette.text = "#c8c8c8";
    };
  };
}

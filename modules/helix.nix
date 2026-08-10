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
      theme = "rose_pine_moon";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        true-color = true;
        popup-border = "all";
        file-picker.hidden = false;
      };
    };
  };
}

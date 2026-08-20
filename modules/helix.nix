{lib, ...}: {
  # 他のツールが開くエディタもこれに揃える。yazi の opener や git のコミットメッセージ
  # 編集はここを見る。キー単位で mkDefault にするのは、セット全体に掛けると別のモジュール
  # が home.sessionVariables を定義した時点で既定値が丸ごと消えるため。
  home.sessionVariables = {
    EDITOR = lib.mkDefault "hx";
    VISUAL = lib.mkDefault "hx";
  };

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

    # 外部ツールを呼ぶキー (C-y = yazi, C-g = hunk) は modules/yazi.nix と
    # modules/hunk.nix が足す。呼ばれる側の都合が濃いので、定義もそちらに置いてある。
    settings = {
      theme = "github_dark_popup";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        true-color = true;
        popup-border = "all";
        file-picker.hidden = false;
      };
    };

    themes.github_dark_popup = {
      inherits = "github_dark";
      "ui.popup" = {
        bg = "#212830";
      };
    };
  };
}

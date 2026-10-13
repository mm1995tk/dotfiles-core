# Alacritty の窓と文字の設定。分割・タブ・作業の永続化は多重化ツール（herdr など）が
# 担当するので、Alacritty 自身は 1 枚の窓だけを持つ。
{
  config,
  lib,
  pkgs,
  ...
}: {
  # CJK のフォントは入れない。Alacritty はフォールバック先を設定できず、日本語の字形は OS が選ぶ。
  home.packages = [pkgs.nerd-fonts.jetbrains-mono];

  programs.alacritty = {
    enable = true;
    # github_dark は GitHub の古い配色（背景が灰色がかった #24292e）なので、今の配色の方を使う。
    theme = "github_dark_default";

    settings = {
      # テーマが GitHub 本家の配色から外している色（文字が黄みがかる）と、持っていない色を足す。
      colors = {
        primary.foreground = "#c9d1d9";
        bright.white = "#ffffff";
        cursor = {
          cursor = "#58a6ff";
          text = "CellBackground";
        };
        selection = {
          background = "#58a6ff";
          text = "#0d1117";
        };
      };

      font = {
        normal.family = "JetBrainsMono Nerd Font Mono";
        size = 11;
      };

      window = {
        dimensions = {
          columns = 178;
          lines = 48;
        };
        padding = {
          x = 8;
          y = 8;
        };
        option_as_alt = "Both";
      };

      # Finder から起動すると作業ディレクトリが / になる。無いディレクトリを指すと起動に
      # 失敗するので、~/workspace を置く決まりのある macOS だけに絞る。
      general = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        working_directory = "${config.home.homeDirectory}/workspace";
      };

      keyboard.bindings = [
        # Alacritty の中にタブを作ると多重化ツールのものと二重になり、どちらのキーで動かすかを
        # 取り違えるので、既定のキーを潰しておく。
        {
          key = "T";
          mods = "Command";
          action = "None";
        }
        {
          key = "Enter";
          mods = "Shift";
          chars = "\n";
        }
      ];
    };
  };
}

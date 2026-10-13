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
    theme = "github_dark";

    settings = {
      font.normal.family = "JetBrainsMono Nerd Font Mono";

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

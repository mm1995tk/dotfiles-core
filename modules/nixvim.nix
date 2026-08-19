# neovim を nixvim で構成する。プラグイン・treesitter grammar・LSP をすべてビルド時に
# 固めるので、起動時のプラグイン取得も grammar のコンパイルも起きない。
#
# このファイルは `programs.nixvim` の**設定だけ**を持ち、オプションを宣言する nixvim 本体の
# モジュール (`nixvim.homeModules.nixvim`) は import 側 (dotfiles/default.nix) が重ねる。
# dotfiles/dist/ が配信するミラーの flake は inputs を持たない契約なので、ここから
# flake input を参照できないため。ミラーの消費者もこのモジュールを使うには自分の flake に
# nixvim input を足して同じ 2 枚重ねをする必要がある。
{
  config,
  pkgs,
  ...
}: {
  programs.nixvim = {
    enable = true;

    # 既定では nixvim が自分で pin した nixpkgs を import し直し、そこから vim プラグインと
    # grammar を引く。home-manager 側と 2 つの nixpkgs が同居してクロージャが膨らむので、
    # 評価済みの pkgs をそのまま渡して 1 つに揃える。
    nixpkgs.pkgs = pkgs;

    # ruby / python3 の remote-plugin provider。ここで使うプラグインはどれも要求しないのに
    # 既定で on になっていて、ruby は処理系ごと clang を引き込む。
    withRuby = false;
    withPython3 = false;

    # gitsigns 等が要求する git。フル版は git-p4 のために python3（さらにその先の
    # Apple SDK / cctools）を引き込むので、それらを持たない gitMinimal に差し替える。
    # 上の 3 つ合わせてクロージャが 2.3GiB → 900MiB になる。
    dependencies.git.package = pkgs.gitMinimal;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    globals.mapleader = " ";

    opts = {
      mouse = "a";
      clipboard = "unnamedplus";
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      autoindent = true;
      smartindent = true;
      # gitsigns と診断マークが出入りするたびに本文が横にずれるのを防ぐ
      signcolumn = "yes";

      # treesitter の folding は foldlevel の既定値 0 だと、ファイルを開いた瞬間に
      # 全体が閉じて `+-- N lines:` の 1 行しか見えなくなる。畳むのは手動 (zc) に任せ、
      # 開いた直後は常に展開済みにする。
      foldlevel = 99;
      foldlevelstart = 99;
    };

    autoGroups.ScrollQuarter.clear = true;
    autoCmd = [
      {
        event = ["WinEnter" "VimResized"];
        group = "ScrollQuarter";
        command = "let &l:scroll = winheight(0) / 4";
      }
    ];

    # helix (modules/helix.nix) と同じ github_dark に揃える
    colorschemes.github-theme.enable = true;

    plugins = {
      treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
        folding.enable = true;
        # extraConfigLua 等を lua としてハイライトする
        nixvimInjections = true;

        # 既定は「全 grammar」。コンテナ (kali / claude) にも base.nix 経由で入るので、
        # 実際に触る言語だけに絞ってクロージャを抑える。
        grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
          bash
          comment
          css
          diff
          dockerfile
          git_config
          git_rebase
          gitcommit
          gitignore
          go
          gomod
          gowork
          hcl
          html
          javascript
          jsdoc
          json
          lua
          luadoc
          markdown
          markdown_inline
          nix
          python
          query
          regex
          sql
          terraform
          toml
          tsx
          typescript
          vim
          vimdoc
          yaml
        ];
      };

      treesitter-textobjects.enable = true;

      blink-cmp = {
        enable = true;
        settings.keymap.preset = "super-tab";
      };

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
          "<leader>fd" = "diagnostics";
        };
      };

      # lsp.servers.* が呼ぶ vim.lsp.enable() は、サーバの既定設定 (cmd / filetypes /
      # root マーカー) を runtimepath 上の lsp/<名前>.lua から引く。それを配っているのが
      # nvim-lspconfig なので、これが無いと enable しても何も起動しない。
      lspconfig.enable = true;

      gitsigns.enable = true;
      lualine.enable = true;
      which-key.enable = true;
      web-devicons.enable = true;
    };

    # LSP。サーバのバイナリは nixvim が各サーバの package として引くので、
    # PATH 上の nixd (base.nix、helix が使う) とは独立している。
    lsp = {
      inlayHints.enable = true;

      servers = {
        nixd.enable = true;
        gopls = {
          enable = true;
          # gopls は root_dir の解決 (`go env GOMODCACHE`) にもモジュール解決にも go 本体を
          # 呼ぶ。PATH に無いと .go を開いた瞬間にスタックトレースが出るので一緒に配る。
          packages.prefix = [pkgs.go];
        };
        ts_ls.enable = true;
        eslint.enable = true;
        jsonls.enable = true;
        yamlls.enable = true;
        bashls.enable = true;
        lua_ls.enable = true;
      };

      keymaps = [
        {
          key = "gd";
          lspBufAction = "definition";
        }
        {
          key = "gr";
          lspBufAction = "references";
        }
        {
          key = "gi";
          lspBufAction = "implementation";
        }
        {
          key = "gt";
          lspBufAction = "type_definition";
        }
        {
          key = "K";
          lspBufAction = "hover";
        }
        {
          key = "<leader>rn";
          lspBufAction = "rename";
        }
        {
          key = "<leader>ca";
          lspBufAction = "code_action";
        }
      ];
    };
  };
}

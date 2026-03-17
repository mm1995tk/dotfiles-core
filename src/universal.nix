{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
    csvq
    jq
    nixd
    nix-prefetch-docker
    nix-prefetch-git
    ripgrep
    tree
    yq
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };

  programs.starship = {
    enable = true;
    settings = fromTOML (builtins.readFile ../config/starship.toml);
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    dotDir = "${config.xdg.configHome}/zsh";
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    plugins = [
      {
        name = "nix-zsh-completions";
        src = pkgs.nix-zsh-completions.src;
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions.src;
      }
    ];
    loginExtra = ''
      mkdir -p $HOME/workspace
    '';
    initContent = lib.mkAfter ''
      zstyle ':completion:*:default' menu select=1
      . ${../config/index.zsh}
    '';
    shellAliases = {
      grep = "grep --colour=auto";
      la = "ls -A";
      ll = "ls -lh";
      mv = "mv -i";
      comp = "cargo compete";
      z = "cd";
      zi = "cdi";
    };
  };

  programs.helix = {
    # https://home-manager-options.extranix.com/?query=helix&release=release-25.05

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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.fzf.enable = true;
  programs.gh.enable = true;

  programs.git = {
    enable = true;
    ignores = [
      "*~"
      "*.swp"
      ".DS_Store"
      ".direnv"
    ];
  };

  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = ''
      set mouse=a
      set clipboard=unnamedplus
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set autoindent
      set smartindent
      syntax on
      filetype plugin indent on
      augroup ScrollQuarter
        autocmd!
        autocmd WinEnter,VimResized * let &l:scroll = winheight(0) / 4
      augroup END
    '';
  };
}

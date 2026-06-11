{...}: {
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

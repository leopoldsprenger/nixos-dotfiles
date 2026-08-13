{ ... }: {
  programs.nvf.settings.vim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    options = {
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
    };
  };
}


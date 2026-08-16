{...}: {
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

    clipboard = {
      enable = true;
      registers = "unnamedplus";
      providers.wl-copy.enable = true;
    };
  };
}

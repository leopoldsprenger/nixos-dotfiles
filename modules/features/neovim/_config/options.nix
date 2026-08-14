{...}: {
  programs.nvf.settings.vim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      {
        key = "<Space>";
        action = "<Nop>";
        mode = ["n" "v"];
        silent = true;
      }
    ];

    options = {
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
    };

    clipboard.providers.wl-copy.enable = true;
  };
}

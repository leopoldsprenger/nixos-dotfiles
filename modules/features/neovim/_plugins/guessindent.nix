{ pkgs, ... }: {
  programs.nvf.settings = {
    vim.startPlugins = [
      pkgs.vimPlugins.guess-indent-nvim
    ];
  
    vim.luaConfigRC.guess-indent = ''
      require('guess-indent').setup({})
    '';
  };
}

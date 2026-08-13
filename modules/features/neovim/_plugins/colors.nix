{ ... }: {
  programs.nvf.settings.vim = {
    theme = {
      enable = true;
      name = "tokyonight";
      style = "moon";
      transparent = true;
    };

    statusline.lualine = {
      enable = true;
      theme = "tokyonight";
    };

    luaConfigRC.themeOverrides = ''
      local c = require("tokyonight.colors").setup({ style = "moon" })
      vim.api.nvim_set_hl(0, "CurSearch", { bg = c.blue0, fg = c.blue5 })
      vim.api.nvim_set_hl(0, "IncSearch", { bg = c.blue0, fg = c.blue5 })
      vim.api.nvim_set_hl(0, "Search", { bg = c.bg_visual, fg = c.none })
    '';
  };
}


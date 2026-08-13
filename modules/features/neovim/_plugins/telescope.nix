{ ... }: {
  programs.nvf.settings.vim = {
    telescope.enable = true;

    maps.normal = {
      "<leader>ff" = { action = ''function() require("telescope.builtin").find_files() end''; lua = true; desc = "Telescope find files"; };
      "<leader>fg" = { action = ''function() require("telescope.builtin").live_grep() end''; lua = true; desc = "Telescope live grep"; };
      "<leader>fb" = { action = ''function() require("telescope.builtin").buffers() end''; lua = true; desc = "Telescope buffers"; };
      "<leader>fh" = { action = ''function() require("telescope.builtin").help_tags() end''; lua = true; desc = "Telescope help tags"; };
    };
  };
}


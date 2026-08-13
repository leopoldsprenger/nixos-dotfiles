{...}: {
  programs.nvf.settings.vim = {
    luaConfigRC.autocmdsCustom = ''
      local autocmd = vim.api.nvim_create_autocmd

      autocmd("VimEnter", {
        callback = function()
          local arg = vim.fn.argv(0)

          if arg == "" then
            vim.cmd.cd(".")
            vim.cmd.edit(".")
          elseif vim.fn.isdirectory(arg) == 1 then
            vim.cmd.cd(arg)
          end
        end,
      })

      -- Highlight on Yank
      autocmd("TextYankPost", {
        callback = function()
          vim.highlight.on_yank()
        end,
      })
    '';
  };
}

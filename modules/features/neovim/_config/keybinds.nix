# modules/features/neovim/keybinds.nix
{ ... }: {
  programs.nvf.settings.vim = {
    maps = {
      normal = {
        "<leader>cd" = { action = "vim.cmd.Ex"; silent = true; desc = "Open file explorer"; };
        "<leader>w"  = { action = "vim.cmd.w"; silent = true; desc = "Write file"; };
        "<Esc>"      = { action = "vim.cmd.nohlsearch"; silent = true; desc = "Clear search highlights"; };
        
        # Diagnostic Float & Formatter
        "<leader>e"  = { action = "vim.diagnostic.open_float"; desc = "Open Diagnostic Float"; };
        "<leader>f"  = { action = ''function() require("conform").format() end''; lua = true; desc = "Format Buffer"; };

        # Modern diagnostic navigation mappings
        "[d"         = { action = ''function() vim.diagnostic.jump({ count = -1 }) end''; lua = true; desc = "Previous Diagnostic"; };
        "]d"         = { action = ''function() vim.diagnostic.jump({ count = 1 }) end''; lua = true; desc = "Next Diagnostic"; };
      };

      insert = {
        "jk"         = { action = "<Esc>"; silent = true; desc = "Exit insert mode"; };
      };

      terminal = {
        "<Esc>"      = { action = "<C-\\><C-n>"; silent = true; desc = "Exit terminal mode"; };
      };
    };

    luaConfigRC.keybindsCustom = ''
      -- Safely bind LSP tools only when a valid language server attaches to the buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local telescope = require("telescope.builtin")
          
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Definition", buffer = event.buf })
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration", buffer = event.buf })
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Implementation", buffer = event.buf })
          vim.keymap.set("n", "gr", telescope.lsp_references, { desc = "References", buffer = event.buf })
          
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover", buffer = event.buf })
          
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename", buffer = event.buf })
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", buffer = event.buf })
        end,
      })

      -- Intelligent toggle/focus behavior for the diagnostic loclist window
      vim.keymap.set("n", "<leader>q", function()
          -- Check if the current window is a quickfix/loclist window
          if vim.bo.filetype == "qf" then
              vim.cmd("lclose")
          else
              -- Get window ID of the loclist for current window (returns 0 if not open)
              local loclist_win = vim.fn.getloclist(0, { winid = 0 }).winid
              if loclist_win > 0 then
                  -- Loclist is open but not focused; refocus it
                  vim.api.nvim_set_current_win(loclist_win)
              else
                  -- Loclist is not open; open and focus it
                  vim.diagnostic.setloclist()
              end
          end
      end, { desc = "Toggle/Focus Diagnostic List" })
    '';
  };
}


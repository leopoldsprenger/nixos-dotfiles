{...}: {
  programs.nvf.settings.vim = {
    maps = {
      normal = {
        # Direct function reference
        "<Esc>" = {
          action = "vim.cmd.nohlsearch";
          lua = true;
          silent = true;
          desc = "Clear highlights and stay in normal mode";
        };

        # Direct function reference
        "<leader>w" = {
          action = "vim.cmd.w";
          lua = true;
          silent = true;
          desc = "Save current file";
        };

        # Direct API call wrapped to evaluate the path argument
        "<leader>cd" = {
          action = "function() vim.cmd.cd(vim.fn.expand('%:p:h')) end";
          lua = true;
          silent = true;
          desc = "Change working directory to current file";
        };

        "]d" = {
          action = "function() vim.diagnostic.jump({ count = 1 }) end";
          lua = true;
          desc = "Next Diagnostic";
        };
      };

      insert = {
        "jk" = {
          action = "<Esc>";
          silent = true;
          desc = "Exit insert mode";
        };
      };

      terminal = {
        "<Esc>" = {
          action = "<C-\\><C-n>";
          silent = true;
          desc = "Exit terminal mode";
        };
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
          if vim.bo.filetype == "qf" then
              vim.cmd.lclose()
          else
              local loclist_win = vim.fn.getloclist(0, { winid = 0 }).winid
              if loclist_win > 0 then
                  vim.api.nvim_set_current_win(loclist_win)
              else
                  vim.diagnostic.setloclist()
              end
          end
      end, { desc = "Toggle/Focus Diagnostic List" })
    '';
  };
}

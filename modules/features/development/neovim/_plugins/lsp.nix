{pkgs, ...}: {
  programs.nvf.settings.vim = {
    lsp.enable = true;
    lsp.lspconfig.enable = true;

    languages = {
      lua = {
        enable = true;
        lsp.enable = true;
      };
      clang = {
        enable = true;
        lsp.enable = true;
      };
      python = {
        enable = true;
        lsp.enable = true;
      };
      rust = {
        enable = true;
        lsp.enable = true;
      };
      tex = {
        enable = true;
        lsp.enable = true;
        # FIX: Changed from lsp.server = "texlab" to a list element
        lsp.servers = ["texlab"];
      };
    };

    extraPlugins = with pkgs.vimPlugins; {
      lazydev = {
        package = lazydev-nvim;
        setup = "require('lazydev').setup({})";
      };

      vimtex = {
        package = vimtex;
        setup = ''
          vim.g.vimtex_syntax_enabled = 0
          vim.g.vimtex_view_method = 'zathura'
          vim.g.vimtex_compiler_latexmk = {
            continuous = 1,
            callback = 1,
          }
        '';
      };
    };

    diagnostics.config = {
      virtual_text = true;
      signs = true;
      underline = true;
      update_in_insert = false;
      severity_sort = true;
    };
  };
}

{ pkgs, ... }: {
  programs.nvf.settings.vim = {
    lsp = {
      enable = true;
    };

    treesitter = {
      enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; {
      lazydev = {
        package = lazydev-nvim;
        setup = "require('lazydev').setup({})";
      };
    };

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
    };

    diagnostics = {
      config = {
        virtual_text = true;
        signs = true;
        underline = true;
        update_in_insert = false;
        severity_sort = true;
      };
    };
  };
}


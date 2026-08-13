{ ... }: {
  programs.nvf.settings.vim.formatter.conform-nvim = {
    enable = true;
    setupOpts = {
      lsp_fallback = true;
      async = false;
      format_on_save = {
        timeout_ms = 500;
        lsp_fallback = true;
      };
      formatters_by_ft = {
        lua = [ "stylua" ];
        cpp = [ "clang_format" ];
        c = [ "clang_format" ];
        python = [ "ruff_format" ];
        nix = [ "alejandra" ];
      };
    };
  };
}

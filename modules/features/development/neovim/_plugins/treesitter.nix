{pkgs, ...}: {
  programs.nvf.settings.vim.treesitter = {
    enable = true;
    autotagHtml = true;
    highlight.enable = true;
    indent.enable = true;

    grammars = with pkgs.tree-sitter-grammars; [
      tree-sitter-lua
      tree-sitter-python
      tree-sitter-cpp
      tree-sitter-latex
    ];
  };
}

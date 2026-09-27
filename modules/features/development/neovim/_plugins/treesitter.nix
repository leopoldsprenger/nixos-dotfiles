{pkgs, ...}: {
  programs.nvf.settings.vim = {
    treesitter = {
      enable = true;
      autotagHtml = true;
      highlight.enable = true;
      indent.enable = true;
    };
  };
}

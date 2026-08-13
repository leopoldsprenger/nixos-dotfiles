{ ... }: {
  programs.nvf.settings.vim = {
    autocomplete.blink-cmp = {
      enable = true;
      setupOpts = {
        appearance = {
          nerd_font_variant = "mono";
        };
        completion = {
          documentation = {
            auto_show = true;
          };
        };
        sources = {
          default = [ "lsp" "path" "snippets" "buffer" ];
        };
        fuzzy = {
          implementation = "prefer_rust_with_warning";
        };
        keymap = {
          preset = "none";
          "<CR>" = [ "accept" "fallback" ];
          "<Tab>" = [ "select_next" "snippet_forward" "fallback" ];
          "<S-Tab>" = [ "select_prev" "snippet_backward" "fallback" ];
        };
      };
    };
  };
}


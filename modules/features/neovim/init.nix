{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.neovim = {
    config,
    pkgs,
    ...
  }: {
    imports =
      [
        inputs.nvf.nixosModules.default

        ./_config/options.nix
        ./_config/keybinds.nix
        ./_config/autocmds.nix
      ]
      ++ (
        let
          targetDirs = [
            ./_plugins
          ];

          getNixFiles = dir: let
            dirContents = builtins.readDir dir;

            validFiles =
              lib.filterAttrs (
                name: type: ((type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
                  || (type == "directory"))
              )
              dirContents;
          in
            map (name: dir + "/${name}") (builtins.attrNames validFiles);
        in
          lib.concatMap getNixFiles targetDirs
      );

    home-manager.users.leo = {
      home.file = {
        ".config/noctalia/user-templates.toml".text = ''
          [templates.nvim-base16]
          input_path = "~/.config/nvim/lua/matugen-template.lua"
          output_path = "~/.config/nvim/lua/matugen.lua"
          post_hook = 'pkill -SIGUSR1 nvim'
        '';

        ".config/nvim/lua/matugen-template.lua".text = ''
          local M = {}

          function M.setup()
            require('base16-colorscheme').setup {
              -- Background tones
              base00 = '${"{"}colors.surface.default.hex}}',
              base01 = '${"{"}colors.surface_container.default.hex}}',
              base02 = '${"{"}colors.surface_container_high.default.hex}}',
              base03 = '${"{"}colors.outline.default.hex}}',
              -- Foreground tones
              base04 = '${"{"}colors.on_surface_variant.default.hex}}',
              base05 = '${"{"}colors.on_surface.default.hex}}',
              base06 = '${"{"}colors.on_surface.default.hex}}',
              base07 = '${"{"}colors.on_background.default.hex}}',
              -- Accent colors
              base08 = '${"{"}colors.error.default.hex}}',
              base09 = '${"{"}colors.tertiary.default.hex}}',
              base0A = '${"{"}colors.secondary.default.hex}}',
              base0B = '${"{"}colors.primary.default.hex}}',
              base0C = '${"{"}colors.tertiary_fixed_dim.default.hex}}',
              base0D = '${"{"}colors.primary_fixed_dim.default.hex}}',
              base0E = '${"{"}colors.secondary_fixed_dim.default.hex}}',
              base0F = '${"{"}colors.error_container.default.hex}}',
            }
          end

          -- Signal Handler für Echtzeit-Reload (SIGUSR1)
          local signal = vim.uv.new_signal()
          signal:start(
            'sigusr1',
            vim.schedule_wrap(function()
              local home = os.getenv("HOME")
              if home then
                local matugen_path = home .. "/.config/nvim/lua/matugen.lua"

                -- Cache leeren, damit dofile die Datei wirklich neu einliest
                package.loaded['matugen'] = nil

                local success, matugen_mod = pcall(dofile, matugen_path)
                if success and type(matugen_mod) == "table" and matugen_mod.setup then
                  package.loaded['matugen'] = matugen_mod
                  matugen_mod.setup()
                end
              end
            end)
          )

          -- In package.loaded UND package.preload registrieren, um lzn-auto-require auszuhebeln
          package.loaded['matugen'] = M
          package.preload['matugen'] = function() return M end

          return M
        '';
      };
    };

    programs.nvf = {
      enable = true;
      defaultEditor = true;

      settings = {
        vim.theme.enable = false;
        vim.startPlugins = [pkgs.vimPlugins.base16-nvim];

        vim.luaConfigRC.noctalia-matugen = ''
          local home = os.getenv("HOME")
          if home then
            local matugen_path = home .. "/.config/nvim/lua/matugen.lua"
            local file = io.open(matugen_path, "r")
            if file then
              file:close()

              -- Hilfsfunktion, um das Modul sicher zu laden
              local function load_matugen()
                return dofile(matugen_path)
              end

              -- Dem globalen Paket-System mitteilen, wie es 'matugen' ohne Suchpfade findet
              package.preload['matugen'] = load_matugen

              local success, matugen_mod = pcall(require, 'matugen')
              if success and type(matugen_mod) == "table" and matugen_mod.setup then
                matugen_mod.setup()
              elseif not success then
                print("Noctalia-Matugen Initialisierungs-Fehler: " .. tostring(matugen_mod))
              end
            end
          end
        '';
      };
    };
  };
}

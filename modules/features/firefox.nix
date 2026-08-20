{inputs, ...}: {
  flake.nixosModules.firefox = {
    home-manager.users.leo = {pkgs, ...}: {
      home.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      programs.firefox = {
        enable = true;

        profiles.default = {
          settings = {
            "extensions.autoDisableScopes" = 0;

            "sidebar.verticalTabs" = true;
            "sidebar.visibility" = "always";
            "sidebar.revamp" = true;

            "browser.tabs.groups.enabled" = false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "ui.systemUsesDarkTheme" = 1;

            "font.name.serif.x-western" = "JetBrainsMono Nerd Font";
            "font.name.sans-serif.x-western" = "JetBrainsMono Nerd Font";
            "font.name.monospace.x-western" = "JetBrainsMono Nerd Font";

            "font.size.variable.x-western" = 16;
            "font.size.fixed.x-western" = 14;

            "browser.tabs.inTitlebar" = 1;
            "browser.uiCustomization.state" = builtins.toJSON {
              placements = {
                widget-overflow-fixed-list = [];
                nav-bar = ["back-button" "forward-button" "urlbar-container"];
                toolbar-menubar = ["menubar-items"];
                TabsToolbar = [];
                PersonalToolbar = [];
              };
              seen = [];
              dirtyAreaCache = ["nav-bar" "TabsToolbar" "PersonalToolbar"];
              currentVersion = 20;
              newElementCount = 0;
            };
          };

          search = {
            force = true;
            default = "ddg";

            engines = {
              "ddg" = {
                urls = [
                  {
                    template = "https://duckduckgo.com";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                      {
                        name = "type";
                        value = "disableaibro";
                      }
                    ];
                  }
                ];
                definedAliases = ["@ddg"];
              };
            };
          };

          extensions = let
            addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
          in {
            force = true;
            packages = [
              addons.bitwarden
              addons.ublock-origin
              addons.sponsorblock
              addons.youtube-shorts-block
              addons.darkreader
              addons.vimium-c
            ];
          };

          bookmarks = {
            force = true;
            settings = [
              {
                name = "GitHub";
                url = "https://github.com";
              }
              {
                name = "HPI Slack";
                url = "https://slack.com";
              }
              {
                name = "HPI GitLab";
                url = "https://hpi.de";
              }
            ];
          };

          userContent = ''
            :root {
              --darkreader-neutral-background: #1a1b26 !important;
              --darkreader-neutral-text: #c0caf5 !important;
              --darkreader-selection-background: #33467c !important;
              --darkreader-selection-text: #c0caf5 !important;
            }
          '';

          userChrome = ''
            :root {
              --tn-bg: #1a1b26;
              --tn-bg-dark: #16161e;
              --tn-bg-alt: #24283b;
              --tn-selection: #33467c;
              --tn-fg: #c0caf5;
              --tn-fg-secondary: #a9b1d6;
              --tn-comment: #565f89;
              --tn-blue: #7aa2f7;
              --tn-cyan: #7dcfff;
              --tn-purple: #bb9af7;
              --tn-green: #9ece6a;
              --tn-red: #f7768e;
              --tn-orange: #ff9e64;
            }

            * {
              font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace !important;
            }

            #main-window,
            #navigator-toolbox,
            #browser,
            #appcontent,
            #tabbrowser-tabpanels,
            .browserContainer {
              background: var(--tn-bg) !important;
              color: var(--tn-fg) !important;
            }

            #navigator-toolbox {
              background: var(--tn-bg-dark) !important;
              border-bottom: 1px solid #292e42 !important;
            }

            #nav-bar {
              min-height: 34px !important;
              height: 34px !important;
              padding-block: 0 !important;
              background: var(--tn-bg-dark) !important;
              box-shadow: none !important;
              border: none !important;
            }

            #urlbar-container {
              margin-block: 3px !important;
            }

            #urlbar,
            #searchbar {
              font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace !important;
              font-size: 13px !important;
            }

            #urlbar-background {
              background: var(--tn-bg-alt) !important;
              border: 1px solid #292e42 !important;
              box-shadow: none !important;
            }

            #urlbar[focused="true"] #urlbar-background {
              border-color: var(--tn-blue) !important;
            }

            #urlbar-input {
              color: var(--tn-fg) !important;
            }

            #reload-button,
            #stop-button,
            #sidebar-button,
            #alltabs-button,
            #developer-button,
            #downloads-button,
            #fxa-avatar-button,
            #nav-bar-overflow-button,
            #unified-extensions-button {
              display: none !important;
            }

            #TabsToolbar {
              visibility: collapse !important;
            }

            .titlebar-spacer {
              display: none !important;
            }

            #PersonalToolbar {
              display: none !important;
            }

            #firefox-view-button {
              display: none !important;
            }

            #nav-bar > toolbarspring {
              display: none !important;
            }

            .tabbrowser-tab {
              min-height: 28px !important;
              max-height: 28px !important;
              height: 28px !important;
              margin-block: 0 !important;
              padding-block: 0 !important;
            }

            .tab-stack {
              min-height: 28px !important;
              max-height: 28px !important;
              height: 28px !important;
              margin: 0 !important;
              padding: 0 !important;
            }

            .tab-content {
              min-height: 28px !important;
              max-height: 28px !important;
              height: 28px !important;
              margin: 0 !important;
              padding: 0 12px 0 16px !important;
              align-items: center !important;
              box-shadow: none !important;
            }

            .tab-label-container {
              margin: 0 !important;
              padding: 0 !important;
              align-items: center !important;
              justify-content: center !important;
            }

            .tab-text,
            .tab-label {
              font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace !important;
              font-size: 12px !important;
              line-height: 1 !important;
              color: var(--tn-fg-secondary) !important;
            }

            .tab-background {
              margin: 2px 6px !important;
              padding: 0 !important;
              border: none !important;
              border-radius: 4px !important;
              box-shadow: none !important;
              background: transparent !important;
            }

            .tabbrowser-tab[selected="true"] .tab-background {
              background: var(--tn-bg-alt) !important;
            }

            .tabbrowser-tab[selected="true"] .tab-label {
              color: var(--tn-fg) !important;
            }

            .tabbrowser-tab:not([selected="true"]):hover .tab-background {
              background: #202331 !important;
            }

            .tabbrowser-tab:not([selected="true"]):hover .tab-label {
              color: var(--tn-fg) !important;
            }

            .tabbrowser-tab[pinned="true"] .tab-background {
              background: transparent !important;
            }

            .tabbrowser-tab[pinned="true"] {
              color: var(--tn-purple) !important;
            }

            .tab-icon-image {
              width: 16px !important;
              height: 16px !important;
              margin-inline-end: 10px !important;
            }

            #vertical-tabs-newtab-button {
              color: var(--tn-comment) !important;
            }

            #vertical-tabs-newtab-button:hover {
              color: var(--tn-blue) !important;
              background: var(--tn-bg-alt) !important;
            }

            #sidebar-box {
              background: var(--tn-bg-dark) !important;
              border: none !important;
            }

            #sidebar {
              background: var(--tn-bg-dark) !important;
            }

            #sidebar-splitter {
              width: 1px !important;
              border: none !important;
              background: #292e42 !important;
            }

            #sidebar-box *,
            #sidebar *,
            #tabbrowser-tabs * {
              font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace !important;
            }

            toolbarbutton {
              color: var(--tn-fg-secondary) !important;
            }

            toolbarbutton:hover {
              color: var(--tn-blue) !important;
              background: var(--tn-bg-alt) !important;
            }

            toolbarbutton[open="true"] {
              color: var(--tn-cyan) !important;
              background: var(--tn-bg-alt) !important;
            }

            menupopup,
            panel {
              --panel-background: var(--tn-bg-alt) !important;
              --panel-color: var(--tn-fg) !important;
              background: var(--tn-bg-alt) !important;
              color: var(--tn-fg) !important;
              border: 1px solid #292e42 !important;
            }

            menuitem,
            menu {
              color: var(--tn-fg-secondary) !important;
            }

            menuitem:hover,
            menu:hover {
              background: var(--tn-selection) !important;
              color: var(--tn-fg) !important;
            }

            findbar {
              background: var(--tn-bg-dark) !important;
              color: var(--tn-fg) !important;
              border-top: 1px solid #292e42 !important;
            }

            findbar textbox {
              background: var(--tn-bg-alt) !important;
              color: var(--tn-fg) !important;
              border: 1px solid #292e42 !important;
            }

            #statuspanel-label {
              background: var(--tn-bg-alt) !important;
              color: var(--tn-fg) !important;
              border: 1px solid #292e42 !important;
              font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace !important;
            }

            scrollbar {
              background: var(--tn-bg) !important;
            }

            scrollbar thumb {
              background: #3b4261 !important;
              border-radius: 0 !important;
            }

            scrollbar thumb:hover {
              background: #565f89 !important;
            }
          '';
        };
      };
    };
  };
}

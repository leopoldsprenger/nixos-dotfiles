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
            # "Other writing systems" fallback, so non-Latin pages that
            # don't hardcode their own font also pick up JetBrains Mono.
            "font.name.serif.x-unicode" = "JetBrainsMono Nerd Font";
            "font.name.sans-serif.x-unicode" = "JetBrainsMono Nerd Font";
            "font.name.monospace.x-unicode" = "JetBrainsMono Nerd Font";

            "font.size.variable.x-western" = 16;
            "font.size.fixed.x-western" = 14;

            # Make every website use the fonts above instead of whatever
            # font-family the page's own CSS requests - this is the
            # declarative equivalent of unchecking "Allow pages to choose
            # their own fonts" in about:preferences#general. Caveat: sites
            # that draw icons with ligature/PUA icon fonts (older
            # Material-Icons-style setups) can render literal fallback
            # text instead of the icon glyph while this is on - that's a
            # known Firefox limitation of this pref (see Mozilla bugs
            # 1638585 and 1363454), not something specific to this config.
            # If that turns out to be behind the "text is showing up where
            # an icon should be" issue, drop this line and do the font
            # override as a Stylus style instead (see extensions.settings
            # below) - Stylus lets you disable it per-site.
            "browser.display.use_document_fonts" = 0;

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
              # Stylus: userstyles manager. Used to (a) apply per-site
              # Tokyo Night userstyles for actual website content - Firefox
              # "themes" only ever skin browser chrome, never page content,
              # so there's no such thing as a theme extension that does
              # both; Stylus is the real mechanism for the website half -
              # and (b) as a fallback place to put a font-override style if
              # browser.display.use_document_fonts ends up breaking icon
              # fonts on sites you care about.
              addons.stylus
            ];
            settings = {
              # Grants vimium-c's optional "bookmarks" permission at
              # install time so Firefox never has to prompt for it and
              # the "index bookmarks" feature just works. addonId is read
              # straight off the built package rather than hardcoded, so
              # this stays correct if the extension's id ever changes.
              # If evaluation fails because addonId isn't exposed on this
              # package, open about:debugging#/runtime/this-firefox,
              # find Vimium C's "Extension ID" (NOT the moz-extension://
              # UUID in the popup URL - that's a per-install runtime id,
              # not the manifest id) and hardcode that string here instead.
              "${addons.vimium-c.addonId}" = {
                permissions = [
                  "bookmarks"
                  "clipboardRead"
                  "clipboardWrite"
                  "history"
                  "notifications"
                  "search"
                  "sessions"
                  "storage"
                  "tabs"
                  "webNavigation"
                  "<all_urls>"
                ];
              };
            };
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

          # userContent.css used to carry a hand-rolled attempt at forcing
          # Tokyo Night onto every website by overriding Dark Reader's
          # internal --darkreader-neutral-background/-text/-selection-*
          # CSS variables from outside the extension. Those variables are
          # real, but they're meant to be read inside Dark Reader's own
          # per-site "dynamic-theme-fixes" rules, computed fresh by Dark
          # Reader on every page load - pinning them globally with
          # !important from userContent.css fights that recalculation.
          # userContent.css is also documented as unreliable for actual
          # web content specifically (as opposed to userChrome.css, which
          # reliably styles the browser UI) because of how Firefox's
          # multiprocess content sandboxing interacts with it - which
          # lines up with things looking "randomly" wrong rather than
          # consistently wrong. Both are reasons to do content-page
          # styling through Stylus instead, which doesn't have either
          # problem. See the extensions list above for Stylus; add actual
          # Tokyo Night userstyles for the sites you care about (GitHub,
          # GitLab, etc.) from inside Stylus itself once installed - Nix
          # can install the extension declaratively but can't seed its
          # internal userstyle storage, so that part stays a one-time
          # manual step, same as any other Stylus install.

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

              /* Shared geometry so tabs, the sidebar's "+" button, and
                 other sidebar buttons (e.g. settings) all sit at the same
                 inline margin and round the same amount. --tn-hover-bg is
                 kept distinct from --tn-bg-alt: --tn-bg-alt marks
                 "active/selected/open" state (a selected tab, an open
                 menu), --tn-hover-bg marks plain mouse-over, so hovering
                 an unselected tab or button never looks identical to a
                 selected one. */
              --tn-row-radius: 4px;
              --tn-row-margin-inline: 6px;
              --tn-row-margin-block: 2px;
              --tn-hover-bg: #202331;
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
              /* Was 12px/16px (asymmetric) - that's what pushed the tab
                 icon+label off-center relative to the "+" button below,
                 which is centered. Symmetric padding fixes that. */
              padding-inline: 10px !important;
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
              margin: var(--tn-row-margin-block) var(--tn-row-margin-inline) !important;
              padding: 0 !important;
              border: none !important;
              border-radius: var(--tn-row-radius) !important;
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
              background: var(--tn-hover-bg) !important;
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

            /* Same margin/radius as .tab-background above, so the "+"
               button's edges line up with the tab pills in the column
               above it instead of floating at the toolbarbutton default. */
            #vertical-tabs-newtab-button {
              margin: var(--tn-row-margin-block) var(--tn-row-margin-inline) !important;
              border-radius: var(--tn-row-radius) !important;
              color: var(--tn-comment) !important;
            }

            #vertical-tabs-newtab-button:hover {
              color: var(--tn-blue) !important;
              background: var(--tn-hover-bg) !important;
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

            /* Every other sidebar button (settings gear, history, etc.)
               gets the same margin/radius/hover treatment as the "+"
               button and the tabs above, so the whole column reads as one
               consistent set instead of the "+" button looking like the
               odd one out. */
            #sidebar-box toolbarbutton,
            #sidebar toolbarbutton {
              margin: var(--tn-row-margin-block) var(--tn-row-margin-inline) !important;
              border-radius: var(--tn-row-radius) !important;
            }

            toolbarbutton {
              color: var(--tn-fg-secondary) !important;
            }

            toolbarbutton:hover {
              color: var(--tn-blue) !important;
              background: var(--tn-hover-bg) !important;
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

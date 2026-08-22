{inputs, ...}: {
  flake.nixosModules.firefox = {
    home-manager.users.leo = {pkgs, ...}: {
      programs.firefox = {
        enable = true;
        profileVersion = null;

        profiles.default = {
          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "extensions.autoDisableScopes" = 0;

            "browser.toolbars.bookmarks.visibility" = "never";

            "sidebar.verticalTabs" = true;
            "sidebar.visibility" = "always";
            "sidebar.revamp" = true;

            "browser.tabs.groups.enabled" = false;
            "ui.systemUsesDarkTheme" = 1;

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

          userChrome = ''

          '';

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
                url = "https://gitlab.hpi.de";
              }
            ];
          };
        };
      };
    };
  };
}

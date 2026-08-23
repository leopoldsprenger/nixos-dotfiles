{inputs, ...}: {
  flake.nixosModules.firefox = {
    home-manager.users.leo = {pkgs, ...}: {
      programs.firefox = {
        enable = true;

        # Without this, Firefox bumps profiles.ini to `Version=2` the
        # first time it launches, which makes it silently mint a
        # brand-new profile instead of using the one Home Manager
        # manages - so NOTHING declared below (bookmarks included)
        # ever shows up, even though the config evaluates fine.
        # https://github.com/nix-community/home-manager/issues/6170
        profileVersion = null;

        profiles.default = {
          isDefault = true;

          bookmarks = {
            force = true;
            settings = [
              {
                name = "Bookmarks Toolbar";
                toolbar = true;
                bookmarks = [
                  {
                    name = "HPI Slack";
                    url = "https://hpi.enterprise.slack.com/";
                  }
                  {
                    name = "GitHub";
                    url = "https://github.com/";
                  }
                  {
                    name = "HPI GitLab";
                    url = "https://gitlab.hpi.de/";
                  }
                ];
              }
            ];
          };

          settings = {
            # Lets extensions installed declaratively (below) enable
            # themselves at launch without Firefox prompting for
            # confirmation each time.
            "extensions.autoDisableScopes" = 0;

            # --- Hide elements ---
            "browser.toolbars.bookmarks.visibility" = "never";
            "browser.tabs.groups.enabled" = false;
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

            # --- Vertical tabs ---
            "sidebar.verticalTabs" = true;
            "sidebar.visibility" = "always";
            "sidebar.revamp" = true;
            "browser.tabs.inTitlebar" = 1;
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
            settings = {
              # Grants vimium-c's optional "bookmarks" permission at
              # install time so Firefox never has to prompt for it and
              # the "index bookmarks" feature just works. addonId is
              # read straight off the built package rather than
              # hardcoded, so this stays correct if the extension's id
              # ever changes.
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
        };
      };
    };
  };
}

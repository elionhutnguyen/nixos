# aspects/desktop.nix
# Aspect: Multi-class Wayland desktop stack (Niri, Greetd, Noctalia, Ghostty)
_: {
  den.aspects.desktop = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        programs.niri = {
          enable = true;
          useNautilus = false;
        };

        environment = {
          systemPackages = with pkgs; [
            xwayland-satellite
            wl-clipboard
            wl-mirror
            wlr-randr
            jq
          ];
          sessionVariables = {
            NIXOS_OZONE_WL = "1";
          };
        };

        security.pam.services.greetd.enableGnomeKeyring = true;

        services = {
          gnome = {
            gnome-keyring.enable = true;
            gcr-ssh-agent.enable = false;
          };

          greetd = {
            enable = true;
            settings = {
              default_session = {
                command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-user-session --asterisks --cmd ${lib.getExe' config.programs.niri.package "niri-session"}";
                user = "greeter";
              };
            };
          };
        };

        systemd.services.greetd.serviceConfig = {
          Type = "idle";
          StandardInput = "tty";
          StandardOutput = "tty";
          StandardError = "journal";
          TTYReset = true;
          TTYVHangup = true;
          TTYVTDisallocate = true;
        };
      };

    homeManager =
      { config, ... }:
      {
        xdg.configFile."niri".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/nixos/config/niri";

        programs = {
          ghostty = {
            enable = true;
            installVimSyntax = true;
            settings = {
              window-decoration = false;
              confirm-close-surface = false;
            };
          };

          noctalia = {
            enable = true;
            systemd.enable = true;
            checkConfig = true;
            settings = {
              shell = {
                polkit_agent = true;
                setup_wizard_enabled = false;
                telemetry_enabled = false;
                launch_apps_as_systemd_services = true;
              };
              bar.default = {
                position = "top";
                auto_hide = true;
                auto_hide_delay_ms = 250;
                show_on_workspace_switch = true;
                reserve_space = false;
                thickness = 28;
                margin_ends = 0;
                radius = 0;
                concave_edge_corners = false;
                padding = 10;
                widget_spacing = 4;
              };
              idle = {
                behavior_order = [
                  "lock"
                  "screen-off"
                ];
                behavior = {
                  lock = {
                    enabled = true;
                    timeout = 300;
                    action = "lock";
                  };
                  screen-off = {
                    enabled = true;
                    timeout = 600;
                    action = "screen_off";
                  };
                };
              };
            };
          };
        };
      };
  };
}

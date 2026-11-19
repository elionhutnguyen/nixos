# aspects/system.nix
# Aspect: Core kernel, bootloader, zram, sysctl, oomd, journald, NetworkManager, Bluetooth & Ananicy
_: {
  den.aspects.system.nixos =
    { pkgs, ... }:
    {
      boot = {
        kernelPackages = pkgs.linuxPackages;
        loader = {
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
          };
          efi.canTouchEfiVariables = true;
        };
        tmp = {
          useTmpfs = true;
          tmpfsSize = "50%";
          cleanOnBoot = false;
        };
        kernel.sysctl = {
          "vm.swappiness" = 100;
          "vm.page-cluster" = 0;
        };
        extraModprobeConfig = ''
          options rtw88_pci disable_aspm=1
          options rtw88_core disable_lps_deep=1
          options btusb enable_autosuspend=0
        '';
      };

      networking = {
        networkmanager = {
          enable = true;
          wifi = {
            powersave = false;
            scanRandMacAddress = false;
          };
        };
        firewall = {
          allowedUDPPorts = [
            53 # DNS for NetworkManager Wi-Fi hotspot (dnsmasq)
            67 # DHCP for NetworkManager Wi-Fi hotspot (dnsmasq)
          ];
          allowedTCPPorts = [
            53 # TCP DNS fallback for hotspot clients
          ];
        };
      };

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            FastConnectable = true;
            JustWorksRepairing = "always";
          };
        };
        input = {
          General = {
            UserspaceHID = true;
            IdleTimeout = 0;
          };
        };
      };

      systemd = {
        coredump.enable = false;
        oomd = {
          enable = true;
          enableUserSlices = false;
        };
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
        priority = 100;
      };

      services = {
        fstrim.enable = true;
        fwupd.enable = true;
        resolved = {
          enable = true;
          settings.Resolve = {
            FallbackDNS = [
              "1.1.1.1"
              "9.9.9.9"
            ];
            DNSOverTLS = "opportunistic";
          };
        };
        journald.settings.Journal = {
          SystemMaxUse = "500M";
          SystemMaxFiles = 5;
        };
        ananicy = {
          enable = true;
          package = pkgs.ananicy-cpp;
          rulesProvider = pkgs.ananicy-rules-cachyos;
        };
      };
    };
}

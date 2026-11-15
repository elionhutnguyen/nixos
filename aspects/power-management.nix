# aspects/power-management.nix
# Aspect: Power profiles daemon, laptop battery charge threshold & USB Bluetooth autosuspend lock
_: {
  den.aspects.power-management.nixos = {
    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
      udev.extraRules = ''
        ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{charge_control_end_threshold}!="", ATTR{charge_control_end_threshold}="80"
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="13d3", ATTR{idProduct}=="3548", ATTR{power/autosuspend_delay_ms}="-1", ATTR{power/control}="on"
      '';
    };
  };
}

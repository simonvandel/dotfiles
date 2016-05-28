# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let modprobe = "${config.system.sbin.modprobe}/sbin/modprobe";
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/common.nix
      /etc/nixos/hardware-configuration.nix
    ];

  boot = {
    loader = {
      gummiboot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModprobeConfig = ''
      options snd_hda_intel index=0 model=intel-mac-auto id=PCH
      options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
     '';
    kernelParams = [
      "hid_apple.fnmode=2" # f8 is f8, fn + f8 is media key
    ];
  };

  networking.hostName = "vandel-macair";

  boot.extraModulePackages = [ config.boot.kernelPackages.mba6x_bl ];
  systemd.services.mba6x_blWorkaround = {
    description = "Remove and reload mba6x to workaround no brightness bug (https://github.com/patjak/mba6x_bl/issues/43)";
    wantedBy = [ "multi-user.target" ];
    script = "${modprobe} -r mba6x_bl && ${modprobe} mba6x_bl";
    serviceConfig = {
      Type = "oneshot";
    };
  };
  hardware = {
    facetimehd.enable = true;
  };

  services = {
    # disable XHC1 acpi to avoid resume directly after suspend
    udev.extraRules = ''SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", ATTR{power/wakeup}="disabled"'';

    # power savings
    upower.enable = true;
    tlp.enable = true;

    xserver = {
      # keyboard settings
      xkbOptions = "ctrl:nocaps"; # make capslock = ctrl

      # touchpad
      synaptics = {
        enable = true;
        accelFactor = "0.1";
        minSpeed = "0.5";
        maxSpeed = "1";
        tapButtons = true;
        additionalOptions = ''
          Option "TapButton1" "1"
          Option "TapButton2" "3"
        '';
      };
    };
  };
}

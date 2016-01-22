# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/common.nix
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the gummiboot efi boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "vandel-macair";

  # touchpad
  services.xserver.synaptics = {
    enable = true;
    tapButtons = true;
    fingersMap = [ 0 0 0 ];
    buttonsMap = [ 1 3 2 ];
    twoFingerScroll = true; 
  };
}

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

  services = {
    # disable XHC1 acpi to avoid resume directly after suspend
    udev.extraRules = ''SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", ATTR{power/wakeup}="disabled"'';

    mba6x_bl.enable = true; # gives black screen on boot right now

    # power savings
    upower.enable = true;
    tlp.enable = true;

    xserver = {
      # keyboard settings
      xkbOptions = "ctrl:nocaps"; # make capslock = ctrl

      # touchpad
      multitouch = {
        enable = true;
        buttonsMap = [ 1 3 2 ];
        additionalOptions = ''
          Option "Sensitivity" "1"
          Option "FingerHigh" "5"
          Option "FingerLow" "4"
          Option "IgnoreThumb" "true"
          Option "IgnorePalm" "true"
          Option "TapButton1" "1"
          Option "TapButton2" "3"
          Option "TapButton3" "0"
          Option "TapButton4" "0"
          Option "ClickFinger1" "1"
          Option "ClickFinger2" "3"
          Option "ClickFinger3" "3"
          Option "ButtonMoveEmulate" "true"
          Option "ButtonIntegrated" "true"
          Option "ClickTime" "25"
          Option "BottomEdge" "10"
          Option "SwipeLeftButton" "8"
          Option "SwipeRightButton" "9"
          Option "SwipeUpButton" "0"
          Option "SwipeDownButton" "0"
          Option "ScrollDistance" "75"
          Option "ScrollUpButton" "4"
          Option "ScrollDownButton" "5"
          Option "ThumbSize" "35"
          Option "PalmSize" "55"
          Option "DisableOnThumb" "false"
          Option "DisableOnPalm" "true"
          Option "SwipeDistance" "1000"
          Option "ScrollLeftButton" "7"
          Option "ScrollRightButton" "6"
          Option "AccelerationProfile" "1"
          Option "ConstantDeceleration" "2.0" # Decelerate endspeed
          Option "AdaptiveDeceleration" "2.0" # Decelerate slow movements
          Option "ScrollSmooth" "true" # Experiment
        '';
      };
    };
  };
}

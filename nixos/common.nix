{ config, pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "dk";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  nix.useChroot = true;

# List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    atom
    arc-gtk-theme
    aspell
    aspellDicts.en
    biber
    google-chrome
    myHaskellEnv
    cabal2nix
    #dropbox
    elementary-icon-theme
    emacs
    file
    firefoxWrapper
    gcc
    gdb
    git
    gnupg
    goldendict
    gparted
    keepassx2
    hexchat
    idea.idea-ultimate
    kodi
    meld
    mpv
    mumble
    nix-repl
    nox
    numix-icon-theme
    paper-gtk-theme
    openssh
    qbittorrent
    silver-searcher
    skype
    source-code-pro
    spotify
    theme-vertex
    thunderbird
    (texlive.combine {
      inherit (texlive) epigraph soul bezos fmtcount datetime marginnote pdfcomment pgf-umlcd logreq biblatex-ieee nopageno pgfplots siunitx semantic braket was fixme biblatex csquotes lastpage cleveref titlesec scheme-medium algorithms algorithmicx enumitem collectbox adjustbox latexmk fourier;
    })
    vim
    vlc
    wakelan
    zsh
  ];


  nixpkgs.config = {
    allowUnfree = true;

    firefox = {
    enableAdobeFlash = true;
    };

    allowBroken = false;

    kodi = {
      enablePVRHTS = true;
    };

    packageOverrides = super: let self = super.pkgs; in
    {
      myHaskellEnv = self.haskellPackages.ghcWithHoogle
                       (haskellPackages: with haskellPackages; [
                         # libraries
                         word8 classy-prelude base64-bytestring base16-bytestring
                         # tools
                         cabal-install stylish-haskell ghc-mod hlint hasktags super-user-spark
                       ]);
    };
      gnupg = pkgs.gnupg21;
  };

  # misc
  programs.ssh.startAgent = false;
  services.xserver.startGnuPGAgent = true;
  hardware.pulseaudio.enable = true;

  # GUI
  services.xserver.enable = true;
  services.xserver.layout = "en_us";
  services.xserver.autorun = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  environment.gnome3.excludePackages = with pkgs.gnome3; [ empathy epiphany evolution totem vino yelp accerciser ];

  # User configuration
  users = {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    extraUsers.simon = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "sudo" ];
      description = "Simon Vandel Sillesen";
    };

    extraGroups.sudo = {};
  };

  security.sudo.extraConfig = "%sudo ALL=(ALL:ALL) ALL"; # users in the group sudo can use sudo

  # Shell
  programs.bash.enableCompletion = true;
  programs.zsh.enable = true;
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  environment.variables = { 
    EDITOR = "emacsclient";
    VISUAL = "emacsclient -c --no-wait";
    GIT_EDITOR = "emacsclient -c";
  };
  environment.pathsToLink = [ "/share/themes" ];
  environment.shellAliases = { e = "emacsclient -c --no-wait"; };

  # systemd services
  systemd.user.services.dropbox = {
    enable = true;
    description = "Dropbox service";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.dropbox}/bin/dropbox";
    };
  };

  systemd.user.services.emacs = {
   enable = true;
   description = "Emacs daemon";
   environment.PATH = "/run/current-system/sw";
   environment.GTK_DATA_PREFIX = config.system.path;
   environment.SSH_AUTH_SOCK = "%t/keyring/ssh";
   environment.GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
   serviceConfig = {
     Type = "forking";
     ExecStart = "${pkgs.emacs}/bin/emacs --daemon";
     ExecStop = "${pkgs.emacs}/bin/emacsclient --eval (kill-emacs)";
     Restart = "always";
   };
   wantedBy = [ "default.target" ];
 };
}

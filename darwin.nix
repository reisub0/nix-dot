# vim: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
{ pkgs, lib, ... }:
let
  brewBinPrefix = if pkgs.system == "aarch64-darwin" then
    "/opt/homebrew/bin"
  else
    "/usr/local/bin";
  brewConf = import ./brew.nix;
in {
  # Nix configuration ------------------------------------------------------------------------------

  nix.binaryCaches = [ "https://cache.nixos.org/" ];
  nix.binaryCachePublicKeys =
    [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  nix.trustedUsers = [ "@admin" ];
  users.nix.configureBuildUsers = true;

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    neovim
    nixfmt
    #kitty
    #terminal-notifier
  ];
  homebrew.enable = true;
  homebrew.brewPrefix = brewBinPrefix;
  homebrew.autoUpdate = true;
  homebrew.cleanup = "zap";
  homebrew.global.brewfile = true;
  homebrew.global.noLock = true;

  homebrew.taps = [
    "homebrew/cask"
    "homebrew/cask-drivers"
    "homebrew/cask-fonts"
    "homebrew/cask-versions"
    "homebrew/core"
    "homebrew/services"
  ];

  homebrew.casks = brewConf.casks;
  homebrew.brews = brewConf.brews;
  homebrew.masApps = brewConf.masApps;

  # https://github.com/nix-community/home-manager/issues/423
  #environment.variables = {
  #  TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  #};
  programs.nix-index.enable = true;

  # Fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs;
    [
      #recursive
      #(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

  # Customization
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  system.defaults.NSGlobalDomain.AppleShowScrollBars = "Always";
  system.defaults.loginwindow.LoginwindowText =
    "Please contact k.p.govind@gmail.com if found";
  system.defaults.dock.autohide = true;
  system.defaults.dock.show-recents = false;
  system.defaults.dock.static-only = true;
  system.defaults.dock.wvous-br-corner = 10;

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;

  # Trackpad
  system.defaults.NSGlobalDomain.AppleEnableSwipeNavigateWithScrolls = false;
  system.defaults.NSGlobalDomain.AppleEnableMouseSwipeNavigateWithScrolls =
    false;

  # Finder
  system.defaults.finder.CreateDesktop = false;
  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;
  # Search in current folder
  system.defaults.finder.FXDefaultSearchScope = "SCcf";
  system.defaults.finder.ShowStatusBar = true;
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder.QuitMenuItem = true;
  # Prefer List view
  system.defaults.finder.FXPreferredViewStyle = "Nlsv";

  # Miscellaneous
  system.defaults.LaunchServices.LSQuarantine = false;
  system.defaults.screencapture.location =
    "~/Library/Mobile Documents/com~apple~CloudDocs/ScreenCap";
  system.defaults.screencapture.disable-shadow = true;
  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = false;

}

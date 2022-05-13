# vim: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
{ config, pkgs, lib, ... }:

{
  home.stateVersion = "22.05";

  # https://github.com/malob/nixpkgs/blob/master/home/default.nix

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.file.".zshenv".source = config.lib.file.mkOutOfStoreSymlink ./.zshenv;
  home.file.".zshenv".target = ".zshenv";

  home.packages = with pkgs;
    [
      # Some basics
      coreutils
      diffutils
      curl
      wget
      kopia
      lsd

      # Dev stuff
      # (agda.withPackages (p: [ p.standard-library ]))
      #google-cloud-sdk
      #haskellPackages.cabal-install
      #haskellPackages.hoogle
      #haskellPackages.hpack
      #haskellPackages.implicit-hie
      #haskellPackages.stack
      #idris2
      jq
      #nodePackages.typescript
      #nodejs
      #purescript

      # Useful nix related tools
      cachix # adding/managing alternative binary caches hosted by Cachix
      comma # run software from without installing it
      niv # easy dependency management for nix projects
      nodePackages.node2nix

    ] ++ lib.optionals stdenv.isDarwin [
      cocoapods
      m-cli # useful macOS CLI commands
    ];
}

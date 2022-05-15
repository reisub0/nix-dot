# vim: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
{
  description = "Govind's Darwin system";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Other sources
    #comma = { url = github:Shopify/comma; flake = false; };
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
    let

      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs-unstable.lib)
        attrValues makeOverridable optionalAttrs singleton;

      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays ++ singleton (
          # Sub in x86 version of packages that don't build on Apple Silicon yet
          final: prev:
          (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            inherit (final.pkgs-x86)
            #nix-index
            #idris2
            #niv
              purescript;
          }));
      };
    in {
      # My `nix-darwin` configs

      darwinConfigurations = rec {
        abc = darwinSystem {
          system = "aarch64-darwin";
          modules = attrValues self.darwinModules ++ [
            # Main `nix-darwin` config
            ./darwin.nix
            # `home-manager` module
            home-manager.darwinModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              # `home-manager` config
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.g = import ./home.nix;
            }
          ];
        };
      };

      # Overlays --------------------------------------------------------------- {{{

      overlays = {
        # Overlays to add various packages into package set
        #comma = final: prev: {
        #  comma = import inputs.comma { inherit (prev) pkgs; };
        #};  

        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev:
          optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs-unstable {
              system = "x86_64-darwin";
              inherit (nixpkgsConfig) config;
            };
          };
      };

      # My `nix-darwin` modules that are pending upstream, or patched versions waiting on upstream
      # fixes.
      darwinModules = {
        security-pam =
          # Upstream PR: https://github.com/LnL7/nix-darwin/pull/228
          { config, lib, pkgs, ... }:

          with lib;

          let
            cfg = config.security.pam;

            # Implementation Notes
            #
            # We don't use `environment.etc` because this would require that the user manually delete
            # `/etc/pam.d/sudo` which seems unwise given that applying the nix-darwin configuration requires
            # sudo. We also can't use `system.patchs` since it only runs once, and so won't patch in the
            # changes again after OS updates (which remove modifications to this file).
            #
            # As such, we resort to line addition/deletion in place using `sed`. We add a comment to the
            # added line that includes the name of the option, to make it easier to identify the line that
            # should be deleted when the option is disabled.
            mkSudoTouchIdAuthScript = isEnabled:
              let
                file = "/etc/pam.d/sudo";
                option = "security.pam.enableSudoTouchIdAuth";
                patchScript = ''
                  --- ${file}
                  +++ ${file}
                  @@ -1,4 +1,6 @@
                   # sudo: auth account password session
                  +auth       optional       /opt/homebrew/lib/pam/pam_reattach.so
                  +auth       sufficient     pam_tid.so
                   auth       sufficient     pam_smartcard.so
                   auth       required       pam_opendirectory.so
                   account    required       pam_permit.so
                '';
              in ''
                patchFile="$(mktemp)"
                cat <<EOF > "$patchFile"
                ${patchScript}
                EOF
                ${if isEnabled then ''
                  # Enable sudo Touch ID authentication, if not already enabled
                  if ! [ -f /opt/homebrew/lib/pam/pam_reattach.so ]; then
                      echo "Ensure that pam_reattach is installed from Homebrew"
                      return
                  fi
                  # If patch has not already been applied, apply it
                  if ! patch -R --dry-run -sfp0 -d/ <"$patchFile" >/dev/null 2>&1; then
                    echo "Applying tid, pam_reattach patches to ${file}"
                    patch -p0 -d/ <"$patchFile"
                  fi
                '' else ''
                  # If patch has not already been reversed, reverse it
                  if ! patch --dry-run -sfp0 -d/ <"$patchFile" >/dev/null 2>&1; then
                    echo "Reversing tid, pam_reattach patches to ${file}"
                    patch -R -p0 -d/ <"$patchFile"
                  fi
                ''}
              '';

          in {
            options = {
              security.pam.enableSudoTouchIdAuth = mkEnableOption ''
                Enable sudo authentication with Touch ID
                When enabled, this option adds the following line to /etc/pam.d/sudo:
                    auth       sufficient     pam_tid.so
                (Note that macOS resets this file when doing a system update. As such, sudo
                authentication with Touch ID won't work after a system update until the nix-darwin
                configuration is reapplied.)
              '';
            };

            config = {
              system.activationScripts.extraActivation.text = ''
                # PAM settings
                echo >&2 "setting up pam..."
                ${mkSudoTouchIdAuthScript cfg.enableSudoTouchIdAuth}
              '';
            };
          };
      };
    };
}

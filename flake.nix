{
  description = "Flake to manage Catppuccin grub themes";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    with nixpkgs.lib;
    {
      nixosModule = { config, ... }:
        let
          cfg = config.boot.loader.grub.catppuccin-theme;

          catppuccin-grub-theme = pkgs.stdenv.mkDerivation {
            name = "catppuccin-grub-theme";
            src = ./.;
            installPhase = ''
              mkdir -p $out/grub/theme/
              cp -r src/catppuccin-${cfg.style}-grub-theme/* $out/grub/themes/
            '';
          };
        in
        {
          options = {
            boot.loader.grub.catppuccin-theme = {
              enable = mkOption {
                type = types.bool;
                default = false;
                example = true;
                description = ''
                  Enable Catppuccin grub theme
                '';
              };
              style = mkOption {
                type = types.enum [
                  "latte"
                  "frappe"
                  "machiatto"
                  "mocha"
                ];
                example = "machiatto";
                description = ''
                  The flavor to use for grub
                '';
              };
            };
          };

          config = mkIf cfg.enable (mkMerge [{
            environment.systemPackages = [ catppuccin-grub-theme ];
            boot.loader.grub = {
              theme = "${catppuccin-grub-theme}/grub/theme";
            };
          }]);
        };
    };
}


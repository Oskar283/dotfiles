{
  description = "Dotfiles — portable Home Manager modules";

  inputs = {
    nixpkgs.url      = "github:nixos/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }: {
    # Consumed by the homelab flake (and any other NixOS/HM setup):
    #
    #   inputs.dotfiles.url = "github:Oskar283/dotfiles";
    #   inputs.dotfiles.inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.dotfiles.inputs.home-manager.follows = "home-manager";
    #
    # Then in home.nix:
    #   imports = [ inputs.dotfiles.homeManagerModules.default ];
    homeManagerModules.default = import ./home-manager/default.nix;

    homeConfigurations."default" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
      modules = [
        ./home-manager/default.nix
        {
          home.username = builtins.getEnv "USER";
          home.homeDirectory = builtins.getEnv "HOME";
          home.stateVersion = "25.11";
          programs.home-manager.enable = true;
        }
      ];
    };
  };
}

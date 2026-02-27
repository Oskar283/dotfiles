{
  description = "Dotfiles — portable Home Manager modules";

  inputs = {
    nixpkgs.url      = "github:nixos/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Intentionally no nixpkgs.follows — nixvim docs warn that overriding
    # its nixpkgs breaks CI guarantees. Remove the follows line if eval fails.
    nixvim.url       = "github:nix-community/nixvim/nixos-25.11";
  };

  outputs = { nixpkgs, home-manager, nixvim, ... }: {
    # Consumed by the homelab flake (and any other NixOS/HM setup):
    #
    #   inputs.dotfiles.url = "github:Oskar283/dotfiles";
    #   inputs.dotfiles.inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.dotfiles.inputs.home-manager.follows = "home-manager";
    #
    # Then in home.nix:
    #   imports = [ inputs.dotfiles.homeManagerModules.default ];
    #
    # nixvim is bundled here so consumers don't need to know about it,
    # and nvim.nix never has to reference `inputs` inside `imports`
    # (which causes infinite recursion in the module system).
    homeManagerModules.default = {
      imports = [
        nixvim.homeModules.nixvim
        ./home-manager/default.nix
      ];
    };

    homeConfigurations."default" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
      modules = [
        nixvim.homeModules.nixvim
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

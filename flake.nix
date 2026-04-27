{
  description = "Dotfiles — portable Home Manager modules";

  inputs = {
    nixpkgs.url      = "github:nixos/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url       = "github:nix-community/nixvim/nixos-25.11";
    nixgl.url        = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, nixvim, nixgl, ... }: {
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
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit nixgl; };
      modules = [
        nixvim.homeModules.nixvim
        ./home-manager/default.nix
        ({ config, ... }: {
          home.username = "s3000080";
          home.homeDirectory = "/home/s3000080";
          home.stateVersion = "25.11";
          programs.home-manager.enable = true;
        })
      ];
    };
  };
}

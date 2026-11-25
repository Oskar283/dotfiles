{
  description = "Dotfiles — portable Home Manager modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Neovim runs on latest, independent of the release the system follows:
    # nixvim main, with Neovim, plugins, LSPs and formatters from unstable.
    nixvim.url = "github:nix-community/nixvim";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixvim,
      nixpkgs-unstable,
      nixgl,
      ...
    }:
    let
      nixvimModule = {
        imports = [ nixvim.homeModules.nixvim ];
        programs.nixvim.nixpkgs.source = nixpkgs-unstable;
      };
    in
    {
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
          nixvimModule
          ./home-manager/default.nix
        ];
      };

      homeManagerModules.desktop = {
        imports = [
          ./home-manager/desktop.nix
        ];
      };

      # Headless server profile. Like default it bundles nixvim so consumers
      # don't have to know about it, but server.nix pulls in only the subset
      # we actually want on a box without a desktop.
      homeManagerModules.server = {
        imports = [
          nixvimModule
          ./home-manager/server.nix
        ];
      };

      homeConfigurations."default" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit nixgl; };
        modules = [
          nixvimModule
          ./home-manager/default.nix
          ./home-manager/desktop.nix
          ({ ... }: {
            home.username = builtins.getEnv "USER";
            home.homeDirectory = builtins.getEnv "HOME";
            home.stateVersion = "25.11";
            programs.home-manager.enable = true;
          })
        ];
      };
    };
}

{ lib, ... }:
{
  options.dotfiles.wsl = lib.mkOption {
    type = lib.types.bool;
    default = builtins.getEnv "WSL_DISTRO_NAME" != "";
    description = "Whether this machine runs under WSL.";
  };
}

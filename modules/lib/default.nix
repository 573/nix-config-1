{ lib, ... } @ args:

let
  callPackage = lib.callPackageWith args;

  fileList = callPackage ./file-list.nix { };
in

{
  inherit (fileList) getFileList getRecursiveFileList;

  containerApp = callPackage ./container-app.nix { };

  path = {
    modules = ../.;
    config = ../config;
    files = ../files;
    hardwareConfiguration = ../hardware-configuration;
    homeFiles = ../../home-manager-configurations/home-files;
    overlays = ../overlays;
    secrets = toString ../secrets;
  };
}

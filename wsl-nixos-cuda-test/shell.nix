{ pkgs ? import <nixpkgs>
    {
      config =
        {
          allowUnfree = true;
          cudaSupport = true;
        };
    }
}:

pkgs.mkShell {
  buildInputs =
    [
      pkgs.python310
      #pkgs.python38Packages.pytorch
      pkgs.python310Packages.pytorch-bin
    ];

  shellHook = ''
    export LD_LIBRARY_PATH=/usr/lib/wsl/lib
  '';
}

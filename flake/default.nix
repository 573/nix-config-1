{
  inputs,
  rootPath,
  forEachSystem,
}:

let
  pkgsFor = forEachSystem (system: import ./nixpkgs.nix { inherit inputs rootPath system; });

  ghcpkgsFor = forEachSystem (
    system:
    import ./nixpkgs.nix {
      inherit inputs rootPath system;
      pkgsSet = inputs.ghc-nixpkgs-unstable;
    }
  );

  pkgsInsecFor = forEachSystem (
    system:
    import ./nixpkgs.nix {
      inherit inputs rootPath system;
      config.permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    }
  );

  pkgsCudaFor = forEachSystem (
    system:
    import ./nixpkgs.nix {
      inherit inputs rootPath system;
      config = {
        cudnnSupport = true;
        cudaVersion = "12";
        # https://discourse.nixos.org/t/laggy-mouse-when-use-nvidia-driver/38410
        nvidia.acceptLicense = true;
        cudaSupport = true;
        # https://discourse.nixos.org/t/too-dumb-to-use-allowunfreepredicate/39956/17
        allowUnfreePredicate =
          pkg:
          builtins.elem (inputs.nixpkgs.lib.getName pkg) [
            "torch"
            "cuda_nvtx"
            "cuda_cudart"
            "cuda_cupti"
            "cuda_nvrtc"
            "cudnn"
            "libcublas"
            "libcufft"
            "libcurand"
            "libcusolver"
            "libnvjitlink"
            "libcusparse"
            "cuda_nvcc"
            "cuda_cccl"
            "triton"
          ];
      };
    }
  );

  pkgsNixOnDroidFor = forEachSystem (
    system:
    import ./nixpkgs.nix {
      inherit inputs rootPath system;
      nixOnDroid = true;
    }
  );

  customLibFor = forEachSystem (
    system:
    import "${rootPath}/lib" {
      pkgs = pkgsFor.${system};
    }
  );

  homeModulesFor = forEachSystem (
    system:
    [
      {
        _file = ./default.nix;
        lib.custom = customLibFor.${system};
      }
    ]
    ++ customLibFor.${system}.listNixFilesRecursive "${rootPath}/home"
  );

  /**
    # Example

    ```nix
    mkApp = wrapper ./builders/mkApp.nix
    ```

    A function (i. e. `mkApp` or `mkHome`) declared like that might be called like:

    ```nix
    mkHome "x86_64-linux" "dani@maiziedemacchiato"
    ```

    # Arguments

    - [builder] Path of a nix file
    - [system] String describing the system to build attribute set for (i. e. `"aarch64-linux"`)
    - [name] String to name the config for example i. e. `dani@maiziedemacchiato`, see `homeConfigurations` in flake.nix
    - [args] Attribute set of further arguments
  */
  wrapper =
    builder: system: name: args:
    inputs.nixpkgs.lib.nameValuePair name (
      import builder {
        inherit
          inputs
          rootPath
          system
          ghcpkgsFor
          pkgsFor
          pkgsCudaFor
          pkgsInsecFor
          pkgsNixOnDroidFor
          customLibFor
          homeModulesFor
          name
          args
          ;
      }
    );

  /**
    wraps `wrapper` simplified in a manner that `wrapper`'s parameter `args` is an empty attribute set (`{}`)
  */
  simpleWrapper =
    builder: system: name:
    wrapper builder system name { };

in

{
  mkHome = simpleWrapper ./builders/mkHome.nix;
  mkNixOnDroid = simpleWrapper ./builders/mkNixOnDroid.nix;
  mkNixos = simpleWrapper ./builders/mkNixos.nix;

  mkApp = wrapper ./builders/mkApp.nix;
  mkDevShellJdk = wrapper ./builders/mkDevShellJdk.nix;
  mkDevenvJvmLang = wrapper ./builders/mkDevenvJvmLang.nix;
  mkDevenvDeno = wrapper ./builders/mkDevenvDeno.nix;
  mkDevenvFlutter = wrapper ./builders/mkDevenvFlutter.nix;
  mkDevenvRuby = wrapper ./builders/mkDevenvRuby.nix;
  mkDevenvRubyNix = wrapper ./builders/mkDevenvRubyNix.nix;
  mkDevenvRubyVar3 = wrapper ./builders/mkDevenvRubyVar3.nix;
  mkDevenvHaskell = wrapper ./builders/mkDevenvHaskell.nix;
  mkDevenvOcaml = wrapper ./builders/mkDevenvOcaml.nix;
  mkDevenvRust = wrapper ./builders/mkDevenvRust.nix;
  mkDevenvRustWasm32 = wrapper ./builders/mkDevenvRustWasm32.nix;
  mkDevenvJulia = wrapper ./builders/mkDevenvJulia.nix;
  mkDevenvJupyenv = wrapper ./builders/mkDevenvJupyenv.nix;
  mkDevShellOcaml = wrapper ./builders/mkDevShellOcaml.nix;
  mkDevenvRust2 = wrapper ./builders/mkDevenvRust2.nix;
  mkDevShellPython = wrapper ./builders/mkDevShellPython.nix;
  mkDevShellCudaWsl = wrapper ./builders/mkDevShellCudaWsl.nix;
  mkDevShellAgda = wrapper ./builders/mkDevShellAgda.nix;
  mkDevShellCommonLisp = wrapper ./builders/mkDevShellCommonLisp.nix;
  mkDevenvPlaywright = wrapper ./builders/mkDevenvPlaywright.nix;
  mkDevenvPlaywright2 = wrapper ./builders/mkDevenvPlaywright2.nix;
  mkDevShellGhcwasm = wrapper ./builders/mkDevShellGhcwasm.nix;
  mkDevenvHaskell2 = wrapper ./builders/mkDevenvHaskell2.nix;
}

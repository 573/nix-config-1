{
  system,
  pkgsFor,
  inputs,
  args,
  ...
}:
let
  inherit (args) mkShell;
  pkgs = pkgsFor.${system};
in
mkShell {
  inherit inputs pkgs;
  modules = [
    (
      { pkgs, ... }:
      {
        packages = builtins.attrValues {
          inherit (pkgs)
            nodejs
            playwright-test
            ;

          inherit (pkgs.playwright-driver)
            browsers
            ;
        };
        env.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
        env.PLAYWRIGHT_NODEJS_PATH = "${pkgs.nodejs}/bin/node";
        env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = 1;
        # https://discourse.nixos.org/t/running-playwright-tests/25655/41
        env.PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
        enterShell = ''
          	    # Remove playwright from node_modules, so it will be taken from playwright-test
                    rm node_modules/@playwright/ -R
               	  '';
      }
    )
  ];
}

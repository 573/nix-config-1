{ system, pkgsFor, inputs, name, args, ... }:
# TODO integrate sample files as in https://discourse.nixos.org/t/running-playwright-tests/25655/35 or in https://discourse.nixos.org/t/running-playwright-tests/25655/33
let
  inherit (args) mkShell;
  pkgs = pkgsFor.${system};
in
mkShell {
  inherit inputs pkgs;
  modules =
    let
      playwright-driver = pkgs.playwright-driver;
      playwright-driver-browsers = pkgs.playwright-driver.browsers;

      playright-file = builtins.readFile "${playwright-driver}/package/browsers.json";
      playright-json = builtins.fromJSON playright-file;
      playwright-chromium-entry = builtins.elemAt
        (builtins.filter
          (
            browser: browser.name == "chromium"
          )
          playright-json.browsers) 0;
      playwright-chromium-revision = playwright-chromium-entry.revision;
    in
    [
      {
        env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH = "${playwright-driver-browsers}/chromium-${playwright-chromium-revision}/chrome-linux/chrome";
        # This is used by npx playwright --{ui,debug,...}
        env.PLAYWRIGHT_BROWSERS_PATH = "${playwright-driver-browsers}";
        languages = {
          javascript = {
            enable = true;
            npm.enable = true;
          };
        };
      }
    ];
}

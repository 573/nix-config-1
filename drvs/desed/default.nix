# in overlay: desed = final.callPackage "${rootPath}/drvs/desed" { };
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "desed";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "SoptikHa2";
    repo = "desed";
    rev = "v${version}";
    hash = "sha256-/kJE5Mb6Xm4gL8bXFHQKJ6vICWstrGZ6PmravyJjLm0=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = with lib; {
    description = "Debugger for Sed: demystify and debug your sed scripts, from comfort of your terminal";
    homepage = "https://github.com/SoptikHa2/desed";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}

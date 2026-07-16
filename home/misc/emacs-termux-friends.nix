{
  pkgs ? import <nixpkgs> { },
}: # test: nix-build emacs-termux-friends.nix --builders ''
let
  emacsapk = pkgs.stdenv.mkDerivation {

    # name of our derivation
    name = "emacsapk";

    # sources that will be used for our derivation.
    src = pkgs.fetchurl {
      url = "mirror://sourceforge/android-ports-for-gnu-emacs/emacs-32.0.50-35-arm64-v8a.apk";
      sha512 = "sha512-Cf8K24RZyuitvj7ntIV5SSdqbSgJbpnGzyRzPLWQS80W1mse1hyUJJhh7aZNHo6T5AAJmchUgfS8nYLLKw4Zhw=="; # pkgs.lib.fakeSha512;
    };

    # Disable automatic unpacking
    unpackPhase = ":";

    # see https://nixos.org/nixpkgs/manual/#ssec-install-phase
    # $src is defined as the location of our `src` attribute above
    installPhase = ''
                # $out is an automatically generated filepath by nix,
                # but it's up to you to make it what you need. We'll create a directory at
                # that filepath, then copy our sources into it.
                mkdir $out
      	  ls -la $src
      	  ls -la $out
                cp -v $src $out
    '';
  };

  termuxapk = pkgs.stdenv.mkDerivation {

    # name of our derivation
    name = "termuxapk";

    # sources that will be used for our derivation.
    src = pkgs.fetchurl {
      url = "https://f-droid.org/repo/com.termux_1022.apk";
      sha512 = "sha512-qut6HpzeCvGVrZgnMiklyVTYUkljhFRDmkXUEzAIBNf8cTM1UPAZBXIiYBvopSBQvwLyKsQmoy6W4lEMbWMH2A=="; # pkgs.lib.fakeSha512;
    };

    # Disable automatic unpacking
    unpackPhase = ":";

    # see https://nixos.org/nixpkgs/manual/#ssec-install-phase
    # $src is defined as the location of our `src` attribute above
    installPhase = ''
                # $out is an automatically generated filepath by nix,
                # but it's up to you to make it what you need. We'll create a directory at
                # that filepath, then copy our sources into it.
                mkdir $out
      	  ls -la $src
      	  ls -la $out
                cp -v $src $out
    '';
  }; 
in
pkgs.runCommand "my-package-test"
  {
    nativeBuildInputs = builtins.attrValues {
      inherit (pkgs.javaPackages.compiler)
        openjdk17-bootstrap
        ;
      inherit (pkgs)
        apktool
        apksigner
	which
        ;
    };
  }
  ''
    mkdir $out
    cp -rv ${emacsapk}/*emacs-32.0.50-35-arm64-v8a.apk $out/emacs.apk
    cp -rv ${termuxapk}/*com.termux_1022.apk $out/termux.apk
    which keytool
    echo $'\e[0;93m'"Run the next command manually pls, using defaults and store the password somewhere safe, i.e., by default in that nix file here sops-nix is used (/run/secrets/pwfile)"$'\e[0m'
    echo $'\e[0;93m'"$(which keytool) -genkey -v -keystore /tmp/debug.keystore -alias emacsandroid -keyalg RSA -keysize 2048 -validity 10000"$'\e[0m'
    pushd $out
    # to only interact on the last question keytool poses, provide -dname
    echo yes| keytool -genkey -dname "CN=Example, OU=IT, O=Company, L=City, S=State, C=Country" -noprompt -v -storepass signemacsnow -keypass signemacsnow -keystore debug.keystore -alias emacsandroid -keyalg RSA -keysize 2048 -validity 10000
    apktool d emacs.apk 
    # not working /run/secrets/emacsAndroid owned by group nixbld not found
    #apksigner sign --ks-pass file:/run/secrets/emacsAndroid --ks /tmp/debug.keystore ./emacs.apk
    apksigner sign --ks-pass pass:signemacsnow --ks debug.keystore ./emacs.apk
    rm debug.keystore
    pwd
    ls -la
  ''

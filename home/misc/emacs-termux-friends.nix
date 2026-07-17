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
  #em = pkgs.substitute {
  #  src = null;
  # replacements = [
  #   "--replace-warn"
  # <string name="shared_user_label">Termux user</string>
  #   ];
  #}
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
        echo $'\e[0;93m'"Put that in /data/data/org.gnu.emacs/files/.emacs.d/early-init.el (can use installed termux):"$'\e[0m'
        echo $'\e[0;93m'"(setq touch-screen-display-keyboard t)"$'\e[0m'
        echo $'\e[0;93m'"(when (string-equal system-type "android")"$'\e[0m'
        echo $'\e[0;93m'"  ;; Add Termux binaries to PATH environment"$'\e[0m'
        echo $'\e[0;93m'"  (let ((termuxpath "/data/data/com.termux/files/usr/bin"))"$'\e[0m'
        echo $'\e[0;93m'"    (setenv "PATH" (concat termuxpath ":" (getenv "PATH")))"$'\e[0m'
        echo $'\e[0;93m'"    (setq exec-path (append (list termuxpath) exec-path))))"$'\e[0m'
        pushd $out
        # to only interact on the last question keytool poses, provide -dname
        echo yes| keytool -genkey -dname "CN=Example, OU=IT, O=Company, L=City, S=State, C=Country" -noprompt -v -storepass signemacsnow -keypass signemacsnow -keystore debug.keystore -alias emacsandroid -keyalg RSA -keysize 2048 -validity 10000
        apktool d emacs.apk 
        apktool d termux.apk 

    #https://github.com/adept/full-fledged-hledger/compare/master...573:full-fledged-hledger:pushhere#diff-16cddcd6b987528aee0e3d6930f04e9413e1e349c66d385fdc93290af456800dR70
        # funny thing emacs version above already contains <string name="shared_user_name">Emacs shared user</string> and
        # android:sharedUserId="com.termux" android:sharedUserLabel="@string/shared_user_name as well and seems to work ootb like that
        #a=$(cat ./termux/res/values/strings.xml | grep shared_user_label)
        #echo $a
        #substituteInPlace "./emacs/res/values/strings.xml" --replace-warn '</resources>' "$a</resources>"

        cat ./emacs/AndroidManifest.xml | grep 'android:sharedUserId="com.termux" android:sharedUserLabel="@string/shared_user_name"'
        cat ./termux/res/values/strings.xml | grep shared_user_label
        # <string name="shared_user_label">Termux user</string>
        cat ./emacs/res/values/strings.xml | grep shared_user_name
        #<string name="shared_user_name">Emacs shared user</string>

        # not working /run/secrets/emacsAndroid owned by group nixbld not found
        #apksigner sign --ks-pass file:/run/secrets/emacsAndroid --ks /tmp/debug.keystore ./emacs.apk
        apktool b emacs -o ./emacs-4-termux.apk
        apktool b termux -o ./termux-4-emacs.apk
        apksigner sign --ks-pass pass:signemacsnow --ks debug.keystore ./emacs-4-termux.apk
        apksigner sign --ks-pass pass:signemacsnow --ks debug.keystore ./termux-4-emacs.apk
        rm debug.keystore
        pwd
        ls -la
  ''

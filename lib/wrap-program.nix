{ lib, pkgs }:

{
  wrapProgram =
    let
      inherit (lib) stringLength;
    in
    {
      name,
      desktopFileName ? name,
      source,
      path,
      packages ? [ ],
      editor ? "",
      flags ? [ ],
      fixGL ? false,
    }:
    if packages == [ ] && flags == [ ] && !fixGL && stringLength editor == 0 then
      source
    else
      pkgs.symlinkJoin {
        name = "${name}-wrapped";
        paths = [ source ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild =
          let
            inherit (lib)
              concatMapStringsSep
              escapeShellArg
              filter
              hasPrefix
              splitString
              stringLength
              readFile
              ;

            desktopEntryPath = "/share/applications/${desktopFileName}.desktop";
            out = placeholder "out";

            # TODO test https://github.com/soupglasses/nix-system-graphics
            content = readFile "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel";
            lines = splitString "\n" content;

            filteredLines = filter (line: !(hasPrefix "#!/" line) && !(hasPrefix "exec " line)) lines;
            wrapProgramArgsForFixGL = concatMapStringsSep " " (
              line: "--run ${escapeShellArg line}"
            ) filteredLines;
          in
          ''
                                    # desktop entry
                                    if [[ -L "${out}/share/applications" ]]; then
                                      rm "${out}/share/applications"
                                      mkdir "${out}/share/applications"
                                    else
                                      if [[ -f "${out + desktopEntryPath}" ]]; then
                                        rm "${out + desktopEntryPath}"
                        	      fi
                                    fi

                                      if [[ -f "${source + desktopEntryPath}" ]]; then
                                    sed -e "s|Exec=${source + path}|Exec=${out + path}|" \
                                      "${source + desktopEntryPath}" \
                                      > "${out + desktopEntryPath}"
                        	      fi

                                    wrapProgram "${out + path}" \
                                      ${lib.optionalString fixGL wrapProgramArgsForFixGL} \
                                      ${
                                        lib.optionalString (packages != [ ]) ''--prefix PATH : "${lib.makeBinPath packages}"''
                                      } \
            			  ${lib.optionalString (stringLength editor != 0) ''--prefix EDITOR : "${editor}"''} \
                                      ${lib.optionalString (flags != [ ]) ''--add-flags "${toString flags}"''}
          '';
      };
}

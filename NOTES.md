Regarding garbage collection - redling list

* https://ianthehenry.com/posts/how-to-learn-nix/saving-your-shell/ - the hands-on part that is very enlightening starts basically with the `$ ln -s /nix/store/4n40rm31n58ga0xl62nanq13a34axwwx-nix-shell.drv /nix/var/nix/gcroots/per-user/ian/nix-shell-test` statements
* https://www.reddit.com/r/NixOS/comments/1as7dp3/protect_flake_shell_used_with_nix_develop_from/ (https://www.reddit.com/r/NixOS/comments/1as7dp3/comment/kqoukxp/) - `nix-add-root-devshell` function explains the case of flakes here
* https://github.com/nix-community/nix-direnv/tree/master?tab=readme-ov-file#flakes-support - often suggested
* https://github.com/NixOS/nix/issues/3995#issuecomment-1537108310 - talks about inputs that might still be gc'd and provides a workaround in form of a `collectFlakeInputs` function, even links to
* https://github.com/ruuda/dotfiles/blob/1a28049980c61f22706b2d5d3e8f8951527403a3/zsh/.zshrc#L142-L158 - a shell function that uses `nix flake archive` to persist inputs as well, tested `ln -s` approach for now only, seems insufficient as when I change text in resume.typ there, typst-packages >500M get redownloaded again on next build
* https://medium.com/@ejpcmac/about-using-nix-in-my-development-workflow-12422a1f2f4c - it seems we either need `keep-outputs = true    keep-derivations = true` or the nix-store--gc arguments `--option keep-derivations true --option keep-outputs true `still to keep our roots from being collected 

Regarding deployment:

* https://github.com/nix-community/nix-on-droid/issues/94
* https://github.com/search?q=repo%3Ageoffreygarrett%2F.dotfiles+deploy&type=code
* https://github.com/bbigras/nix-config/blob/7d7eb023bee13c9bfcd7f87444d2b15c7884cab8/nix/deploy.nix
* https://github.com/bbigras/nix-config/blob/9d1c904/nix/deploy.nix
* https://github.com/bbigras/nix-config/blob/9d1c9048bb967ed186f3dd0793113e1f8dea4cca/README.md#deploy-one-host
* https://github.com/bbigras/nix-config/blob/master/flake.nix#L224
* https://github.com/bbigras/nix-config/blob/master/hosts/pixel6/default.nix
* https://github.com/bbigras/nix-config/blob/master/nix/nix-on-droid.nix

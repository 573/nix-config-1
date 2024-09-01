@command@

echo

nvd diff @activeLinkPath@ ./result
# shellcheck disable=SC2050
if [[ "@name@" != "nod-build" ]]; then
  rm result
else
  ./result/activate
fi

mode="${1}"

_usage() {
  echo "$0 <debug|dev|boot|build|test|switch>"
}

args=(--flake "@nixConfigDir@")
case "${mode}" in
debug) args+=(test --fast --show-trace) ;;
dev) args+=(test --fast) ;;
boot) args+=(boot) ;;
build)
  "@buildCmd@"
  exit
  ;;
test) args+=(test) ;;
switch) args+=(switch) ;;
*)
  _usage
  exit 1
  ;;
esac

before_date=$(date +"%Y-%m-%d %H:%M:%S")

sudo nixos-rebuild "${args[@]}"
result=$?

for user in root nixos; do
  echo
  journalctl --identifier "hm-activate-${user}" --since "${before_date}" --output cat |
    ccze --raw-ansi
done

exit "${result}"

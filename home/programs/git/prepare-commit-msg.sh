FILE="${1}"

REPLACE=
if [[ "$(git branch-name)" =~ ^feature/(CTMSATOC-[0-9]*).*$ ]]; then
    REPLACE="${BASH_REMATCH[1]} "
fi

sed -i -e "s#PREFIX#${REPLACE}#" "${FILE}"

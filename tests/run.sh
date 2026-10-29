#!/usr/bin/env bash
# Runs check.sh on every fixture and asserts exit code and output.
set -u
HERE=$(cd "${BASH_SOURCE[0]%/*}" && pwd)
CHECK="$HERE/../check.sh"
FIX="$HERE/fixtures"

# name | fixture | extra arg | expected exit | expected output pattern
CASES=(
  "good|good||0|^check: pass"
  "bad-nav|bad-nav||1|^FAIL shared "
  "bad-link|bad-link||1|^FAIL link "
  "bad-pre|bad-pre||1|^FAIL pre "
  "bad-svg-title|bad-svg-title||1|^FAIL svg "
  "bad-svg-hex|bad-svg-hex||1|^FAIL svg-color "
  "bad-chain|bad-chain||1|^FAIL chain "
  "bad-js|bad-js||1|^FAIL script "
  "verify-marker-release|verify-marker|--release|1|^FAIL verify "
  "verify-marker-plain|verify-marker||0|^INFO verify "
  "info-romaji|info-romaji||0|^INFO romaji "
  "bad-template|bad-template||1|^FAIL template "
  "bad-cue|bad-cue||1|^FAIL cue stages/02-b.html"
  "bad-toplevel|bad-toplevel||1|^FAIL link tools.html"
  "bad-nested|bad-nested||1|^FAIL nested stages/02-b.html"
  "bad-front|bad-front||1|^FAIL front index.html"
)

fails=0
for row in "${CASES[@]}"; do
  IFS='|' read -r name fixture arg want pattern <<<"$row"
  args=()
  [[ -n $arg ]] && args+=("$arg")
  args+=("$FIX/$fixture")
  out=$(bash "$CHECK" "${args[@]}" 2>&1)
  got=$?
  if [[ $got -eq $want ]] && grep -Eq -- "$pattern" <<<"$out"; then
    echo "ok $name"
  else
    echo "FAIL $name (exit $got, want $want; pattern $pattern)"
    sed 's/^/    /' <<<"$out"
    fails=$((fails + 1))
  fi
done

[[ $fails -eq 0 ]]

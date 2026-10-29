#!/usr/bin/env bash
# Quality gate for the static site. Uses bash, grep, sed, and diff only.
# Usage: check.sh [--release] [ROOT]
#   ROOT defaults to the directory that holds this script.
#   Exit 0 on pass, 1 on any failure, 2 on a usage error.
set -u
export LC_ALL=C

usage() {
  echo "usage: check.sh [--release] [ROOT]" >&2
  exit 2
}

RELEASE=0
ROOT=""
for arg in "$@"; do
  case $arg in
    --release) RELEASE=1 ;;
    -*) usage ;;
    *)
      [[ -z $ROOT ]] || usage
      ROOT=$arg
      ;;
  esac
done
if [[ -z $ROOT ]]; then
  ROOT=${BASH_SOURCE[0]%/*}
  [[ $ROOT == "${BASH_SOURCE[0]}" ]] && ROOT=.
fi
ROOT=$(cd "$ROOT" 2>/dev/null && pwd) || {
  echo "check.sh: ROOT is not a directory" >&2
  exit 2
}

FAILS=0

# fail CHECK FILE DETAIL: print one failure line and count it.
fail() {
  echo "FAIL $1 $2: $3"
  FAILS=$((FAILS + 1))
}

# load FILE: set FLAT to the file text on one line.
load() {
  FLAT=$(<"$ROOT/$1")
  FLAT=${FLAT//$'\r'/ }
  FLAT=${FLAT//$'\n'/ }
  FLAT=${FLAT//$'\t'/ }
}

# ---- Page list --------------------------------------------------------

PAGES=()
STAGES=()
if [[ ! -f $ROOT/index.html ]]; then
  fail structure index.html "missing"
fi
for f in "$ROOT/index.html" "$ROOT/404.html" "$ROOT/tools.html" "$ROOT/faq.html" "$ROOT"/stages/*.html; do
  [[ -f $f ]] || continue
  rel=${f#"$ROOT"/}
  PAGES+=("$rel")
  [[ $rel == stages/* ]] && STAGES+=("$rel")
done

# ---- Check: shared blocks --------------------------------------------
# Stage pages use a ../ prefix. Strip it, then compare with index.html.

block() {
  sed -n "/<!-- $2:start -->/,/<!-- $2:end -->/p" "$ROOT/$1"
}

for name in nav footer; do
  good=()
  for p in "${PAGES[@]}"; do
    s=$(grep -c -- "<!-- $name:start -->" "$ROOT/$p")
    e=$(grep -c -- "<!-- $name:end -->" "$ROOT/$p")
    if [[ $s -ne 1 || $e -ne 1 ]]; then
      fail shared "$p" "$name markers: $s start, $e end, expected 1 each"
    else
      good+=("$p")
    fi
  done
  [[ -f $ROOT/index.html && -s $ROOT/index.html ]] || continue
  [[ " ${good[*]:-} " == *" index.html "* ]] || continue
  ref=$(block index.html "$name")
  for p in "${good[@]}"; do
    [[ $p == index.html ]] && continue
    cur=$(block "$p" "$name")
    [[ $p == stages/* ]] && cur=$(sed 's#\.\./##g' <<<"$cur")
    if [[ $cur != "$ref" ]]; then
      d=$(diff <(printf '%s\n' "$ref") <(printf '%s\n' "$cur") | grep -m1 '^[<>]')
      fail shared "$p" "$name block differs from index.html ($d)"
    fi
  done
done

# ---- Check: local links ----------------------------------------------

LINK_RE='(^|[[:space:]:])(href|src)[[:space:]]*=[[:space:]]*("[^"]*"|'"'"'[^'"'"']*'"'"')'

for p in "${PAGES[@]}"; do
  dir=${p%/*}
  [[ $dir == "$p" ]] && dir=.
  load "$p"
  while IFS= read -r m; do
    [[ -n $m ]] || continue
    v=${m#*=}
    v=${v#"${v%%[![:space:]]*}"}
    v=${v:1:${#v}-2}
    [[ $v =~ ^[A-Za-z][A-Za-z0-9+.-]*: ]] && continue
    [[ $v == //* ]] && continue
    v=${v%%#*}
    v=${v%%\?*}
    [[ -n $v ]] || continue
    if [[ $v == /* ]]; then
      fail link "$p" "absolute path $v"
      continue
    fi
    t="$ROOT/$dir/$v"
    if [[ -f $t ]] || [[ -d $t && -f $t/index.html ]]; then
      continue
    fi
    fail link "$p" "missing target $v"
  done < <(printf '%s\n' "$FLAT" | grep -oiE "$LINK_RE")
done

# ---- Check: no <pre> -------------------------------------------------

for p in "${PAGES[@]}"; do
  hit=$(grep -n -m1 -iE '<pre([[:space:]>]|$)' "$ROOT/$p")
  [[ -n $hit ]] && fail pre "$p" "pre element at line ${hit%%:*}"
done

# ---- Check: no JavaScript --------------------------------------------

for p in "${PAGES[@]}"; do
  hit=$(grep -n -m1 -iE '<script([[:space:]>/]|$)' "$ROOT/$p")
  [[ -n $hit ]] && fail script "$p" "script element at line ${hit%%:*}"
  load "$p"
  if printf '%s\n' "$FLAT" | grep -qiE '<[^<>]*[[:space:]]on[a-z]+[[:space:]]*=[[:space:]]*["'"'"']'; then
    fail script "$p" "inline event handler attribute"
  fi
  if printf '%s\n' "$FLAT" | grep -qiE 'javascript:'; then
    fail script "$p" "javascript: URL"
  fi
done
for f in "$ROOT"/*.js "$ROOT"/assets/*.js "$ROOT"/stages/*.js; do
  [[ -f $f ]] && fail script "${f#"$ROOT"/}" "JavaScript file"
done

# ---- Check: leaked template code -------------------------------------
# A generator placeholder like {J("x")} must never reach a page.

for p in "${PAGES[@]}"; do
  hit=$(grep -n -m1 -E '\{[A-Za-z_]+(\(|\[)' "$ROOT/$p")
  [[ -n $hit ]] && fail template "$p" "placeholder at line ${hit%%:*}"
done

# ---- Check: tag inside a tag -----------------------------------------
# A "<" between "<tag" and its ">" means a tag leaked into an attribute.

for p in "${PAGES[@]}"; do
  load "$p"
  if printf '%s\n' "$FLAT" | grep -qE '<[A-Za-z][^<>]*<'; then
    fail nested "$p" "a tag opens inside another tag"
  fi
done

# ---- Check: SVG accessibility and colors -----------------------------

ROLE_RE='role[[:space:]]*=[[:space:]]*["'"'"']img["'"'"']'
TITLE_RE='<title[^>]*>[^<]*[^[:space:]<][^<]*</title>'
HEX_RE='(fill|stroke|color|stop-color|flood-color|lighting-color)[[:space:]]*[=:][[:space:]]*["'"'"']?[[:space:]]*#[0-9a-f]+'

for p in "${PAGES[@]}"; do
  load "$p"
  low=${FLAT,,}
  n=0
  while [[ $low == *"<svg"* ]]; do
    n=$((n + 1))
    rest=${low#*<svg}
    if [[ $rest != *"</svg>"* ]]; then
      fail svg "$p" "svg $n has no closing tag"
      break
    fi
    open=${rest%%>*}
    body=${rest%%</svg>*}
    low=${rest#*</svg>}
    [[ $open =~ $ROLE_RE ]] || fail svg "$p" "svg $n lacks role=\"img\""
    [[ $body =~ $TITLE_RE ]] || fail svg "$p" "svg $n lacks a non-empty <title>"
    if [[ $body =~ $HEX_RE ]]; then
      fail svg-color "$p" "svg $n uses a hex color (${BASH_REMATCH[0]})"
    fi
  done
done

# ---- Check: prev/next chain over stages/*.html -----------------------
# Stages sort by filename. Stage i links prev to i-1 and next to i+1.

count=${#STAGES[@]}
for ((i = 0; i < count; i++)); do
  p=${STAGES[i]}
  load "$p"
  for dir in prev next; do
    exp=""
    if [[ $dir == prev && $i -gt 0 ]]; then
      exp=${STAGES[i - 1]##*/}
    elif [[ $dir == next && $i -lt $((count - 1)) ]]; then
      exp=${STAGES[i + 1]##*/}
    fi
    tags=()
    while IFS= read -r t; do
      [[ -n $t ]] && tags+=("$t")
    done < <(printf '%s\n' "$FLAT" |
      grep -oiE '<a[[:space:]][^<>]*rel[[:space:]]*=[[:space:]]*"'"$dir"'"[^<>]*>')
    if [[ -z $exp ]]; then
      [[ ${#tags[@]} -eq 0 ]] || fail chain "$p" "unexpected rel=\"$dir\" link at chain end"
      continue
    fi
    if [[ ${#tags[@]} -ne 1 ]]; then
      fail chain "$p" "expected one rel=\"$dir\" link to $exp, found ${#tags[@]}"
      continue
    fi
    h=""
    if [[ ${tags[0]} =~ href[[:space:]]*=[[:space:]]*\"([^\"]*)\" ]]; then
      h=${BASH_REMATCH[1]#./}
    fi
    [[ $h == "$exp" ]] || fail chain "$p" "rel=\"$dir\" points to '$h', expected $exp"
  done
done

# ---- Check: front page links the top-level pages ---------------------
# tools.html and faq.html must be reachable from the front page body,
# not only from the shared nav.

if [[ -f $ROOT/index.html ]]; then
  body=$(sed -n '/<main/,/<\/main>/p' "$ROOT/index.html")
  for extra in tools.html faq.html; do
    [[ -f $ROOT/$extra ]] || continue
    grep -qE "href=\"$extra\"" <<<"$body" || fail front index.html "main does not link $extra"
  done
fi

# ---- Check: move-on cue on every stage page --------------------------
# Each stage tells the reader when to move on, in a class="go" block.

for p in "${STAGES[@]}"; do
  grep -qE 'class="go"' "$ROOT/$p" || fail cue "$p" "no class=\"go\" move-on block"
done

# ---- Check: VERIFY markers -------------------------------------------
# Listed always. Failure only with --release.

for p in "${PAGES[@]}"; do
  while IFS= read -r m; do
    [[ -n $m ]] || continue
    if [[ $RELEASE -eq 1 ]]; then
      fail verify "$p" "line ${m%%:*}: ${m#*:}"
    else
      echo "INFO verify $p: line ${m%%:*}: ${m#*:}"
    fi
  done < <(grep -noE '<!--[[:space:]]*VERIFY[^>]*>?' "$ROOT/$p")
done

# ---- Report: romaji inside lang="ja" elements (informational) --------

JA_RE='<([A-Za-z0-9]+)[^<>]*lang=["'"'"']ja(-[A-Za-z]+)?["'"'"'][^<>]*>(.*)$'

for p in "${PAGES[@]}"; do
  load "$p"
  rest=$FLAT
  declare -A seen=()
  words=""
  while [[ $rest =~ $JA_RE ]]; do
    tag=${BASH_REMATCH[1]}
    rest=${BASH_REMATCH[3]}
    inner=${rest%%"</$tag>"*}
    inner=$(sed -e 's/<[^>]*>/ /g' -e 's/&[A-Za-z#0-9]*;/ /g' <<<"$inner")
    while IFS= read -r w; do
      [[ -n $w && -z ${seen[$w]:-} ]] || continue
      seen[$w]=1
      words+="${words:+ }$w"
    done < <(grep -oE '[A-Za-z]+' <<<"$inner")
  done
  unset seen
  [[ -n $words ]] && echo "INFO romaji $p: $words"
done

# ---- Check: HTML validator -------------------------------------------

if command -v vnu >/dev/null 2>&1; then
  abs=()
  for p in "${PAGES[@]}"; do abs+=("$ROOT/$p"); done
  if [[ ${#abs[@]} -gt 0 ]]; then
    out=$(vnu --errors-only "${abs[@]}" 2>&1)
    if [[ $? -ne 0 ]]; then
      first=$(grep -m1 . <<<"$out")
      fail html-validate vnu "$first"
    fi
  fi
elif command -v tidy >/dev/null 2>&1; then
  for p in "${PAGES[@]}"; do
    out=$(tidy -q -e "$ROOT/$p" 2>&1)
    if [[ $? -ge 2 ]]; then
      first=$(grep -m1 -i 'error' <<<"$out")
      fail html-validate "$p" "$first"
    fi
  done
else
  echo "SKIP html-validate: neither vnu nor tidy is on PATH"
fi

# ---- Result ----------------------------------------------------------

if [[ $FAILS -gt 0 ]]; then
  echo "check: $FAILS failure(s)"
  exit 1
fi
echo "check: pass"
exit 0

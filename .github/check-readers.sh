#!/bin/bash
# Refuse to publish textbook content (25 Nov 2026). The read-aloud readers carry Mankiw & Taylor's text,
# figures and audio, so they live only on the UB-login reader (intro-econ-reader Worker). On this open
# site a reader folder may hold nothing but one-page redirects to it.
#
#   .github/check-readers.sh <site root>     exit 1 and list the offending files if anything else is there
#
# Run by deploy.sh before every snapshot and by the Pages workflow before every deploy.
set -euo pipefail
ROOT="${1:-.}"
bad=0
while IFS= read -r -d '' f; do
  rel="${f#"$ROOT"/}"
  case "$rel" in
    teaching/*/reader*/ch[0-9][0-9]/index.html)
      size=$(wc -c < "$f")
      if [ "$size" -le 8192 ] && grep -q 'location.replace("https://intro-econ-reader\.' "$f"; then continue; fi
      echo "  not a redirect stub: $rel ($size bytes)";;
    *) echo "  not allowed in a reader folder: $rel";;
  esac
  bad=1
done < <(find "$ROOT/teaching" -path '*/reader*' -type f -print0 2>/dev/null)
# Book audio has no other home on this site.
while IFS= read -r -d '' f; do echo "  audio under teaching/: ${f#"$ROOT"/}"; bad=1; done \
  < <(find "$ROOT/teaching" -type f \( -name '*.mp3' -o -name '*.m4a' -o -name '*.ogg' -o -name '*.wav' \) -print0 2>/dev/null)
if [ $bad = 1 ]; then
  echo "check-readers: textbook reader content found (see above). Readers go to the UB-login Worker only;" >&2
  echo "replace each folder with a redirect stub like teaching/intro-economics/reader/ch03/index.html." >&2
  exit 1
fi
echo "check-readers: reader folders hold only redirect stubs."

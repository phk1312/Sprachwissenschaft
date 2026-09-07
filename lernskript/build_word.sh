#!/usr/bin/env bash
# Erzeugt das Word-Dokument mechanisch aus den Markdown-Dateien.
# Die Musterlösungen zu den Mock-Klausuren werden dabei automatisch
# an das ENDE des Dokuments verschoben (echter Anhang).
set -euo pipefail
cd "$(dirname "$0")"

PV=3.6.4
TOOLS="${TOOLS:-$HOME/.local/pandoc}"
PANDOC="${PANDOC:-$TOOLS/pandoc-$PV/bin/pandoc}"

# Pandoc bei Bedarf einmalig holen (benötigt Internetzugang)
if [ ! -x "$PANDOC" ]; then
  if command -v pandoc >/dev/null 2>&1; then
    PANDOC="$(command -v pandoc)"
  else
    echo "Pandoc wird einmalig nach $TOOLS geladen ..."
    mkdir -p "$TOOLS"
    curl -sL -o "$TOOLS/pandoc.tar.gz" \
      "https://github.com/jgm/pandoc/releases/download/$PV/pandoc-$PV-linux-amd64.tar.gz"
    tar xzf "$TOOLS/pandoc.tar.gz" -C "$TOOLS"
    rm -f "$TOOLS/pandoc.tar.gz"
  fi
fi
echo "Verwende: $("$PANDOC" --version | head -1)"

BUILD=".build"
rm -rf "$BUILD" && mkdir -p "$BUILD"

# Mock-Klausuren aufteilen: Fragen (Kap. 13) vs. Lösungsanhang
csplit -sz -f "$BUILD/mock" -b "%d.md" \
  lernskript_08_mock-klausuren.md '/^# ANHANG — Musterlösungen/'
# -> $BUILD/mock0.md = Fragen, $BUILD/mock1.md = Lösungen

cat > "$BUILD/titel.md" <<'EOF'
---
title: "Lernskript · Historia de la lengua española"
subtitle: "VO Heidinger, Universität Graz — Vorbereitung auf die Schlussklausur"
lang: de-AT
---
EOF

"$PANDOC" \
  --from=markdown+pipe_tables+backtick_code_blocks \
  --to=docx \
  --toc --toc-depth=2 \
  --standalone \
  --output="Lernskript_Historia_de_la_lengua_espanola.docx" \
  "$BUILD/titel.md" \
  lernskript_INHALT.md \
  lernskript_00_grundbegriffe.md \
  lernskript_01_vulgaerlatein-romanisierung.md \
  lernskript_02_altspanisch.md \
  lernskript_03_mittelspanisch.md \
  lernskript_04_modernes-spanisch.md \
  lernskript_05_grammatische-phaenomene.md \
  lernskript_06_werkzeuge.md \
  lernskript_07_wiederholungsplan.md \
  "$BUILD/mock0.md" \
  lernskript_09_kompaktzettel.md \
  "$BUILD/mock1.md"

rm -rf "$BUILD"
ls -lh Lernskript_Historia_de_la_lengua_espanola.docx

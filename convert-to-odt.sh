#!/bin/bash

# Stop on an unhandled command failure (-e), reject unset variables (-u), and
# propagate failures from pipelines (pipefail). These settings prevent the
# script from continuing after a failed preparation or conversion step.
set -euo pipefail

# Portable defaults: the filter, optional template, and output folder live
# beside this script. Advanced users can override the three settings shown
# below without editing the rest of the script.
#
# dirname "$0" finds the folder containing the launched script. cd + pwd turns
# it into an absolute path, so later paths still work no matter which folder
# Terminal was in when the user started the converter.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# The ${NAME:-default} form means “use NAME if the caller supplied it;
# otherwise use default.” This keeps the shared script portable while allowing
# a particular Mac or project to override a location for one run.
FILTER="${ZOTERO_FILTER:-$SCRIPT_DIR/zotero.lua}"
OUTPUT_DIR="${ODT_OUTPUT_DIR:-$SCRIPT_DIR/converted}"
OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-}"
REFERENCE_DOC="${REFERENCE_DOC:-$SCRIPT_DIR/reference.odt}"

# command -v asks the shell whether it can locate Pandoc. Redirecting to
# /dev/null hides the technical lookup output; the user sees a plain error.
if ! command -v pandoc >/dev/null 2>&1; then
    echo "ERROR: Pandoc is not installed or is not available to Terminal."
    echo "Install it from https://pandoc.org/installing.html"
    exit 1
fi

# -s means that the filter must exist and contain data. This catches a missing
# file as well as a failed download that produced an empty file.
if [[ ! -s "$FILTER" ]]; then
    echo "ERROR: The Zotero filter was not found or is empty:"
    echo "  $FILTER"
    exit 1
fi

# Create the output folder when it does not yet exist. -p is harmless when the
# folder already exists.
mkdir -p "$OUTPUT_DIR"

echo "Keep Zotero open with Better BibTeX enabled."
echo "Drag one Markdown (.md) manuscript into this Terminal window,"
echo "then press Return:"

# Deliberately omit read -r: macOS Terminal normally inserts backslash-escaped
# spaces when a file is dragged in, and read should remove those escapes.
IFS= read INPUT_FILE
INPUT_FILE="${INPUT_FILE% }"

# Some terminals paste a dragged path inside quotes rather than escaping spaces.
case "$INPUT_FILE" in
    \"*\") INPUT_FILE="${INPUT_FILE#\"}"; INPUT_FILE="${INPUT_FILE%\"}" ;;
    \'*\') INPUT_FILE="${INPUT_FILE#\'}"; INPUT_FILE="${INPUT_FILE%\'}" ;;
esac

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "ERROR: File not found: $INPUT_FILE"
    exit 1
fi

# Test the text after the final dot. Both the usual lower-case extensions and
# their upper-case equivalents are accepted; unrelated files are rejected.
case "${INPUT_FILE##*.}" in
    md|MD|markdown|MARKDOWN) ;;
    *)
        echo "ERROR: Choose a Markdown file ending in .md or .markdown."
        exit 1
        ;;
esac

# Resolve the manuscript folder to an absolute path, then remove only the final
# filename extension to construct a matching .odt name.
INPUT_DIR="$(cd "$(dirname "$INPUT_FILE")" && pwd)"
BASE_NAME="$(basename "$INPUT_FILE")"
BASE_NAME="${BASE_NAME%.*}"
OUTPUT_FILE="$OUTPUT_DIR/$BASE_NAME.odt"

# Refuse to replace an existing document silently. Pressing Return chooses the
# safe default (No). This matters because a previous ODT may contain edits that
# were never copied back into the Markdown source.
if [[ -e "$OUTPUT_FILE" ]]; then
    echo "An output file already exists:"
    echo "  $OUTPUT_FILE"
    printf "Overwrite it? [y/N]: "
    IFS= read ANSWER
    case "$ANSWER" in
        y|Y|yes|YES) ;;
        *)
            echo "Cancelled. The existing ODT was not changed."
            exit 0
            ;;
    esac
fi

# mktemp creates a unique working folder in macOS's temporary area. The random
# XXXXXX suffix prevents two conversions from using the same temporary file.
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/obsidian-odt.XXXXXX")"
TEMP_FILE="$TEMP_DIR/manuscript.md"

# Register cleanup before creating the working copy. The guard ensures that
# only the specific nonempty directory returned by mktemp can be removed.
cleanup() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf -- "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Remove only a YAML block that begins on the first line. The source file is
# never edited. Exit with an error if an opening delimiter has no closing one.
#
# awk reads the manuscript line by line:
#   • line 1 == "---" turns on in_yaml and is not printed;
#   • a later standalone "---" or "..." turns it off and is not printed;
#   • all lines outside the YAML block are printed to the temporary file;
#   • exit 42 signals an opening delimiter that never closed.
if ! awk '
    NR == 1 && $0 == "---" { in_yaml = 1; next }
    in_yaml && ($0 == "---" || $0 == "...") {
        in_yaml = 0
        closed = 1
        next
    }
    !in_yaml { print }
    END { if (in_yaml && !closed) exit 42 }
' "$INPUT_FILE" > "$TEMP_FILE"; then
    echo "ERROR: YAML frontmatter opens on line 1 but has no closing delimiter."
    exit 1
fi

# Pandoc first searches beside the manuscript for images and other resources.
# A configured vault root is appended using the macOS/Unix colon separator.
RESOURCE_PATH="$INPUT_DIR"
if [[ -n "$OBSIDIAN_VAULT" ]]; then
    RESOURCE_PATH="$RESOURCE_PATH:$OBSIDIAN_VAULT"
fi

# Store options as a Bash array so every path remains one argument even when it
# contains spaces. The reader expression is intentionally restrictive:
#   markdown              = start with Pandoc Markdown
#   -yaml_metadata_block  = YAML was already removed from the temporary copy
#   -simple_tables        = disable simple tables
#   -multiline_tables     = disable multiline tables
#   -grid_tables          = disable grid tables
#   +pipe_tables          = retain Obsidian-style pipe tables
#
# No --citeproc option appears here. zotero.lua must receive the citation
# objects so it can create live Zotero fields instead of rendered plain text.
PANDOC_OPTIONS=(
    --standalone
    --from=markdown-yaml_metadata_block-simple_tables-multiline_tables-grid_tables+pipe_tables
    --to=odt
    "--lua-filter=$FILTER"
    "--resource-path=$RESOURCE_PATH"
    "--output=$OUTPUT_FILE"
)

# A reference document is optional. When present, it supplies Writer styles,
# margins, fonts, and related layout defaults. Its absence is not an error.
if [[ -f "$REFERENCE_DOC" ]]; then
    PANDOC_OPTIONS+=("--reference-doc=$REFERENCE_DOC")
fi

# Pass the temporary manuscript first, then expand the options array. Under
# set -e, a Pandoc failure stops the script and triggers temporary-file cleanup.
echo "Converting…"
pandoc "$TEMP_FILE" "${PANDOC_OPTIONS[@]}"

echo "Created:"
echo "  $OUTPUT_FILE"
printf "Open it in LibreOffice now? [y/N]: "
IFS= read OPEN_ANSWER
# macOS's open command launches the completed file in the named application.
# Any answer other than an explicit yes leaves the ODT saved but unopened.
case "$OPEN_ANSWER" in
    y|Y|yes|YES) open -a "LibreOffice" "$OUTPUT_FILE" ;;
esac


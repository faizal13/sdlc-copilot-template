#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  utils.sh — Shared bash utilities
#
#  Sourced by install.sh before any plugin lib is loaded.
#  Never run directly.
#
#  Provides:
#    copy_file <src> <dest>        — copy if not already present, print status
#    copy_executable <src> <dest>  — copy + chmod +x
#    print_section <label>         — visual separator for install output
# ═══════════════════════════════════════════════════════════════════════════════

# Copy a file from template to target.
# Skips if already exists. Creates parent directories automatically.
# TEMPLATE_ROOT and TARGET_DIR must be set by the caller (install.sh).
copy_file() {
  local src="$1"
  local dest="$2"
  local rel_path="${dest#${TARGET_DIR}/}"

  mkdir -p "$(dirname "$dest")"

  if [ -f "$dest" ]; then
    echo "  [skip] $rel_path"
  elif [ ! -f "$src" ]; then
    echo "  [miss] $rel_path (source not found in template — skipping)"
  else
    cp "$src" "$dest"
    echo "  [add]  $rel_path"
  fi
}

# Copy a file and mark it executable (for shell scripts and git hooks).
copy_executable() {
  local src="$1"
  local dest="$2"
  copy_file "$src" "$dest"
  chmod +x "$dest" 2>/dev/null || true
}

# Print a section header in the install output.
print_section() {
  echo "── $1"
}

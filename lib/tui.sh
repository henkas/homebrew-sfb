#!/usr/bin/env bash

sfb_human_bytes() {
  local bytes="$1"
  local units=(B KB MB GB TB)
  local unit_index=0
  local value="$bytes"

  while [ "$value" -ge 1024 ] && [ "$unit_index" -lt 4 ]; do
    value=$((value / 1024))
    unit_index=$((unit_index + 1))
  done

  printf '%s%s' "$value" "${units[$unit_index]}"
}

sfb_tui_pick_entry() {
  local entries_file="$1"
  local prompt="$2"

  awk -F'\t' '{printf "%12s\t%-4s\t%-6s\t%s\n", $1, $2, $3, $5}' "$entries_file" | \
    fzf --ansi --no-hscroll --prompt "$prompt > " --height=90% --layout=reverse --border
}

sfb_tui() {
  local root="$1"
  local depth="2"
  local top_n="40"

  if ! command -v fzf >/dev/null 2>&1; then
    printf 'fzf is required for TUI mode. Run: sfb doctor --install-deps\n' >&2
    return 4
  fi

  while true; do
    local action
    action="$(printf '%s\n' \
      "Largest directories" \
      "Largest files" \
      "Trash path" \
      "Change root" \
      "Refresh" \
      "Quit" | \
      fzf --prompt "sfb ($root) > " --height=70% --layout=reverse --border)"

    [ -z "$action" ] && return 0

    case "$action" in
      "Largest directories")
        local entries_file selection selected_path
        entries_file="$(mktemp)"
        sfb_scan_directories "$root" "$depth" "$top_n" "$entries_file"
        selection="$(sfb_tui_pick_entry "$entries_file" "dirs")"
        selected_path="$(printf '%s' "$selection" | awk -F'\t' '{print $4}')"
        if [ -n "$selected_path" ] && [ -d "$selected_path" ]; then
          root="$selected_path"
        fi
        rm -f "$entries_file"
        ;;
      "Largest files")
        local file_entries file_selection
        file_entries="$(mktemp)"
        sfb_scan_largest_files "$root" "$top_n" "$file_entries"
        file_selection="$(sfb_tui_pick_entry "$file_entries" "files")"
        if [ -n "$file_selection" ]; then
          printf 'Selected: %s\n' "$(printf '%s' "$file_selection" | awk -F'\t' '{print $4}')"
          printf 'Press Enter to continue...'
          read -r _
        fi
        rm -f "$file_entries"
        ;;
      "Trash path")
        printf 'Path to trash (absolute or relative): '
        local target
        read -r target
        [ -z "$target" ] && continue
        sfb_trash_paths "tui" 0 "" "$target"
        printf 'Press Enter to continue...'
        read -r _
        ;;
      "Change root")
        printf 'New root path: '
        local new_root
        read -r new_root
        [ -z "$new_root" ] && continue
        if [ -d "$new_root" ]; then
          root="$(sfb_abspath "$new_root")"
        else
          printf 'Not a directory: %s\n' "$new_root"
          sleep 1
        fi
        ;;
      "Refresh")
        ;;
      "Quit")
        return 0
        ;;
    esac
  done
}

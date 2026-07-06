# iterm-project-badges
# Automatically sets an iTerm2 badge, tab color, and window title
# based on the git repository you're in.
#
# https://github.com/tstambulsky/iterm-project-badges
# MIT License

# Only run inside iTerm2, and not inside tmux (escape sequences would
# need passthrough wrapping there).
[[ "$TERM_PROGRAM" == "iTerm.app" && -z "$TMUX" ]] || return 0

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# User overrides live here. Define PROJECT_NAMES / PROJECT_COLORS entries
# and IPB_* options in this file — see the example config in the README.
typeset -g IPB_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/iterm-project-badges/config.zsh"

# repo folder name -> display name shown in the badge/title
typeset -gA PROJECT_NAMES
# repo folder name -> "R,G,B" tab color. Repos not listed get a
# deterministic auto-generated color.
typeset -gA PROJECT_COLORS

# Badge text color as hex (no #). Special value "auto" uses the project color.
typeset -g IPB_BADGE_COLOR="${IPB_BADGE_COLOR:-00ff41}"
# Set to 0 to disable individual features.
typeset -g IPB_SET_BADGE="${IPB_SET_BADGE:-1}"
typeset -g IPB_SET_TAB_COLOR="${IPB_SET_TAB_COLOR:-1}"
typeset -g IPB_SET_TITLE="${IPB_SET_TITLE:-1}"

[[ -r "$IPB_CONFIG" ]] && source "$IPB_CONFIG"

# ---------------------------------------------------------------------------
# iTerm2 escape sequences
# ---------------------------------------------------------------------------

_ipb_badge() {
  [[ "$IPB_SET_BADGE" == 1 ]] || return 0
  printf '\033]1337;SetBadgeFormat=%s\a' "$(printf '%s' "$1" | base64)"
}

_ipb_badge_color() {
  [[ "$IPB_SET_BADGE" == 1 ]] || return 0
  printf '\033]1337;SetColors=badge=%s\a' "$1"
}

_ipb_tab_color() {
  [[ "$IPB_SET_TAB_COLOR" == 1 ]] || return 0
  printf '\033]6;1;bg;red;brightness;%d\a' "$1"
  printf '\033]6;1;bg;green;brightness;%d\a' "$2"
  printf '\033]6;1;bg;blue;brightness;%d\a' "$3"
}

_ipb_tab_color_reset() {
  [[ "$IPB_SET_TAB_COLOR" == 1 ]] || return 0
  printf '\033]6;1;bg;*;default\a'
}

_ipb_title() {
  [[ "$IPB_SET_TITLE" == 1 ]] || return 0
  printf '\033]0;%s\a' "$1"
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Deterministic "R,G,B" color from a string, with a minimum brightness
# so it stays visible on dark tabs.
_ipb_auto_color() {
  local hash r g b
  hash=$(printf '%s' "$1" | md5 2>/dev/null || printf '%s' "$1" | md5sum)
  hash="${hash%% *}"
  r=$((16#${hash:0:2}))
  g=$((16#${hash:2:2}))
  b=$((16#${hash:4:2}))
  r=$(( r < 60 ? r + 60 : r ))
  g=$(( g < 60 ? g + 60 : g ))
  b=$(( b < 60 ? b + 60 : b ))
  printf '%d,%d,%d' "$r" "$g" "$b"
}

# Walk up from $PWD looking for a project: a .git entry (dir or file, so
# plain repos, worktrees and submodules all work), or a folder explicitly
# listed in PROJECT_NAMES/PROJECT_COLORS (lets non-git folders be projects).
# Prints the project folder name.
_ipb_find_repo() {
  local dir="$PWD" name
  while [[ "$dir" != "/" && -n "$dir" ]]; do
    name="${dir##*/}"
    if [[ -e "$dir/.git" || -n "${PROJECT_NAMES[$name]}${PROJECT_COLORS[$name]}" ]]; then
      printf '%s' "$name"
      return 0
    fi
    dir="${dir%/*}"
  done
  return 1
}

# ---------------------------------------------------------------------------
# Main hook
# ---------------------------------------------------------------------------

_ipb_apply() {
  local project_name display_name color r g b rest badge_hex

  project_name=$(_ipb_find_repo)

  if [[ -z "$project_name" ]]; then
    # Not in a repo — reset everything we manage.
    _ipb_tab_color_reset
    _ipb_badge ""
    _ipb_title "Terminal"
    return 0
  fi

  display_name="${PROJECT_NAMES[$project_name]:-$project_name}"

  color="${PROJECT_COLORS[$project_name]:-$(_ipb_auto_color "$project_name")}"
  r="${color%%,*}"
  rest="${color#*,}"
  g="${rest%%,*}"
  b="${rest#*,}"

  if [[ "$IPB_BADGE_COLOR" == "auto" ]]; then
    badge_hex=$(printf '%02x%02x%02x' "$r" "$g" "$b")
  else
    badge_hex="$IPB_BADGE_COLOR"
  fi

  _ipb_tab_color "$r" "$g" "$b"
  _ipb_badge "$display_name"
  _ipb_badge_color "$badge_hex"
  _ipb_title "$display_name"
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _ipb_apply

# Apply on shell startup too.
_ipb_apply

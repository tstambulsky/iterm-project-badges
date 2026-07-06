# iterm-project-badges

Automatic per-project **badges**, **tab colors**, and **window titles** for iTerm2.

`cd` into any git repository and iTerm2 instantly shows the project name as a big badge in the corner, colors the tab with a per-project color, and sets the window title. Leave the repo and everything resets. Zero configuration required.

<!-- TODO: add a screenshot at docs/screenshot.png and uncomment:
![screenshot](docs/screenshot.png)
-->

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/tstambulsky/iterm-project-badges/main/install.sh | zsh
```

Then restart your terminal (or `source ~/.zshrc`). That's it — `cd` into any git repo and watch the badge appear.

<details>
<summary>Manual install</summary>

```sh
mkdir -p ~/.config/iterm-project-badges
curl -fsSL https://raw.githubusercontent.com/tstambulsky/iterm-project-badges/main/iterm-project-badges.zsh \
  -o ~/.config/iterm-project-badges/iterm-project-badges.zsh
echo 'source ~/.config/iterm-project-badges/iterm-project-badges.zsh' >> ~/.zshrc
```

</details>

## Configuration (optional)

Everything works out of the box: the badge shows the repo folder name and each repo gets a deterministic auto-generated tab color. To customize, edit `~/.config/iterm-project-badges/config.zsh` (the installer creates a commented example):

```zsh
# Friendly display names (default: repo folder name)
PROJECT_NAMES[acme-billing-service]="Billing"
PROJECT_NAMES[acme-marketing-site]="Website"

# Tab colors as "R,G,B" (default: auto-generated per repo)
PROJECT_COLORS[acme-billing-service]="52,199,89"
PROJECT_COLORS[acme-marketing-site]="0,122,255"

# Badge text color as hex without '#'. Default is matrix green.
# Use "auto" to match each project's tab color.
IPB_BADGE_COLOR="00ff41"

# Disable individual features (1 = on, 0 = off)
IPB_SET_BADGE=1
IPB_SET_TAB_COLOR=1
IPB_SET_TITLE=1
```

Folders listed in `PROJECT_NAMES` or `PROJECT_COLORS` are treated as projects even if they're not git repositories — handy for scratch folders or grouped workspaces.

Badge size, position, and opacity are controlled by iTerm2 itself: **Settings → Profiles → Session → Edit badge appearance…** (font, position, max width/height).

## How it works

iTerm2 accepts [proprietary escape sequences](https://iterm2.com/documentation-escape-codes.html) that any program can print. The badge is just:

```sh
printf '\033]1337;SetBadgeFormat=%s\a' "$(printf '%s' "Hello" | base64)"
```

This plugin hooks zsh's `chpwd` (runs on every `cd`), walks up from the current directory to find the git repo root, and prints the badge, tab-color, and title sequences. Pure zsh, no external processes on the hot path — `cd` stays instant.

## Uninstall

Remove the `# iterm-project-badges` lines from your `~/.zshrc` and delete the config directory:

```sh
rm -rf ~/.config/iterm-project-badges
```

## Limitations

- **iTerm2 only.** The badge escape sequence is an iTerm2 extension — Terminal.app, Ghostty, Alacritty, etc. ignore it. The plugin no-ops in other terminals.
- **No tmux support.** Escape sequences would need passthrough wrapping inside tmux; the plugin detects tmux and stays quiet.
- **macOS-first.** Uses `md5` for auto-colors (falls back to `md5sum` if present). Since iTerm2 is macOS-only, this is rarely an issue.

## License

[MIT](LICENSE)

# Bisaikō

Bisaikō is a small Omarchy bar plugin that opens `btop` in Omarchy's standard
floating terminal presentation. It keeps the terminal and btop lifecycle
independent from the shell, so closing btop cleanly closes only its own window.

## Requirements

- Omarchy with the user-plugin system
- `btop` available on `PATH`
- Omarchy's `omarchy-launch-floating-terminal-with-presentation` helper

## Install locally

Copy `plugin/` to `~/.config/omarchy/plugins/<your-id>.bisaiko/`, add the matching
`{ "id": "<your-id>.bisaiko" }`
to the desired bar section in `~/.config/omarchy/shell.json`, then reload the
shell with `omarchy restart shell` if it does not hot-reload automatically.

The recommended placement is the right section, beside the other system
indicators. The bar entry is intentionally separate from the plugin files so
users can choose their own placement.

## Usage

Click the Bisaikō icon to open btop. Quit btop normally (`q`) to close the
floating terminal. Right-click and middle-click are intentionally no-ops.

## Uninstall

Remove the Bisaikō bar entry and your `~/.config/omarchy/plugins/<your-id>.bisaiko/`
directory, then reload the Omarchy shell.

## Design notes

The first release deliberately uses Omarchy's supported floating-terminal
launcher rather than embedding a TUI inside Quickshell. This preserves btop's
normal terminal behavior and avoids a plugin-owned background process.

# Bisaikō

Bisaikō is an Omarchy bar plugin that previews `btop` in an 80×24 terminal
anchored beneath its icon. Hover to preview it, click to pin it, and click again
to close it.

## Requirements

- Omarchy with the user-plugin system
- `btop` available on `PATH`
- `foot`, `jq`, `flock`, and `hyprctl`

For faster repeat openings, Bisaikō automatically uses Foot's socket-activated
server when `footclient` and `$XDG_RUNTIME_DIR/foot.sock` are available. It
falls back to launching Foot normally otherwise.

## Install locally

Copy `plugin/` to `~/.config/omarchy/plugins/<your-id>.bisaiko/`, make the
`bisaiko` helper executable, and add the matching `{ "id": "<your-id>.bisaiko" }`
to the desired bar section in `~/.config/omarchy/shell.json`.

Add the rule from `hyprland.lua` to the personal overrides at the bottom of
`~/.config/hypr/hyprland.lua`. Reload Hyprland and verify that
`hyprctl configerrors` is empty.

The recommended placement is the right section, beside the other system
indicators. The bar entry is intentionally separate from the plugin files so
users can choose their own placement.

## Usage

- Hover over the icon to preview btop.
- Move into the btop window to interact with it.
- Move away from both the icon and window to close an unpinned preview.
- Click the icon to pin the preview; click again to close it.
- Changing workspaces or opening a special/scratchpad workspace closes it.

The helper serializes state changes so rapid hover/click events cannot create
multiple btop windows.

## Uninstall

Close Bisaikō, remove its bar entry and plugin directory, then remove the
Bisaikō rule from `~/.config/hypr/hyprland.lua`.

## Design notes

The popup is a real Foot terminal rather than an imitation of btop. Its watcher
exists only while the popup is open and exits when the terminal closes.

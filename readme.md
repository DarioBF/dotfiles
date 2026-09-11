## Welcome to my dotfiles

There are some things I need to clarify:

- I'm currently using [Omarchy](https://omarchy.org/), an Arch Linux based distro by [@dhh](https://x.com/dhh).
- Each folder is a [GNU Stow](https://www.gnu.org/software/stow/) package, layered on top of Omarchy's defaults. Link one into `$HOME` from this directory:
  - `stow desktop`: Hyprland settings (monitors, clamshell workspaces, keybindings, input, window rules).
  - `stow shell`: my bash aliases and functions.
- `omarchy/shell.json` is a copy of Omarchy's shell config (`~/.config/omarchy/shell.json`: bar layout, widgets, idle timers). Omarchy replaces that file on every save, which would break a symlink, so the `dotfiles-shell-json` systemd user units (in the `desktop` package) copy it here whenever it changes. Enable them once after `stow desktop`:

  ```bash
  systemctl --user daemon-reload
  systemctl --user enable --now dotfiles-shell-json.path
  ```

  To restore the bar on a new machine, install the bar plugins it uses, then copy the file back (the shell picks it up immediately):

  ```bash
  omarchy plugin add https://github.com/DarioBF/per-display-workspaces
  omarchy plugin add https://github.com/tymurbogach/omarchy-any-monitor
  cp ~/.dariobf/omarchy/shell.json ~/.config/omarchy/shell.json
  ```

Feel free to use it in your setup or ask me anything.

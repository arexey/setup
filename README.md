# setup

Cross-platform dev-environment bootstrap for **Windows**, **WSL**, **Linux**, and **macOS**.
One script, same shell everywhere.

## Philosophy

- **The shell should feel identical on every platform.** Whether you're on a MacBook,
  a Linux desktop, WSL under Windows, or Windows PowerShell itself, the prompt,
  aliases, key bindings, and tool set should be the same.
- **Setup is scripted, not documented.** If it isn't in a script, it doesn't exist.
  Documentation rots; scripts are executable truth.
- **Re-running is idempotent.** Every install is guarded so running the script
  a second time is a no-op (or a safe upgrade). You can clone this on a new box
  and run it, or re-run it after a system update, without thinking about it.

## Layout

| File | Purpose |
|---|---|
| `setup.sh` | Unix bootstrap — macOS, Linux, WSL. Installs Homebrew, Zsh, Oh My Zsh, Powerlevel10k, Nerd Fonts, and a curated CLI tool set (fzf, bat, fd, git-delta, eza, zoxide, tldr, thefuck, nvm). |
| `setuplocalbox.ps1` | Windows bootstrap. Installs Oh My Posh, Nerd Fonts, Terminal-Icons, wires the PowerShell profile, sets the Windows Terminal font, and (via `winget`) installs a set of desktop tools. |
| `shell.rc` | Shared zsh rc — sourced from `~/.zshrc`. Aliases, functions, plugin list, fzf/eza/zoxide/thefuck wiring, Powerlevel10k. |
| `.p10k.zsh` | Powerlevel10k prompt configuration. |
| `prompt.omp.json` | Oh My Posh theme (used on Windows / PowerShell). |
| `Powershell/Microsoft.PowerShell_profile.ps1` | PowerShell profile — functions, aliases, prompt wiring. |
| `Powershell/Invoke-CmdScript.ps1`, `linqshell.ps1` | Helper PowerShell scripts. |
| `profiles.json` | Windows Terminal (legacy) profiles. |
| `wsl2net.ps1` | Forward WSL2 network ports through the Windows firewall. |
| `.vscode/settings.json` | VS Code workspace settings for this repo. |

## Usage

### Unix (macOS, Linux, WSL)

```sh
git clone https://github.com/<you>/setup.git ~/git/setup
cd ~/git/setup
./setup.sh
```

The script:

1. Detects platform (mac vs. Linux/WSL, apt vs. Homebrew).
2. Installs Homebrew if missing.
3. Installs Zsh and switches your shell to it.
4. Installs Oh My Zsh, Powerlevel10k, `zsh-autosuggestions`, `zsh-syntax-highlighting`.
5. Clones and installs the Meslo Nerd Font family.
6. Installs the CLI tool set (fzf, bat, fd, git-delta, eza, zoxide, tldr, thefuck, python3, nvm).
7. Appends `source <repo>/shell.rc` to `~/.zshrc` (idempotently — removes any prior line first).

Re-run it any time — every step guards against re-installation.

### Windows

```powershell
git clone https://github.com/<you>/setup.git C:\src\setup
cd C:\src\setup
.\setuplocalbox.ps1
```

The script:

1. Installs the `MSTerminalSettings`, `Terminal-Icons` PowerShell modules and Oh My Posh.
2. Installs Meslo Nerd Font (via `oh-my-posh font install` + a full `nerd-fonts` clone).
3. Uses `winget` to install a set of desktop tools (Cmder, Process Explorer, Procmon,
   HWiNFO, ScreenToGif, VLC, GIMP, Paint.NET, WinDirStat, WinMerge).
4. Wires `Microsoft.PowerShell_profile.ps1` into your `$PROFILE` (idempotent).
5. Sets the Windows Terminal default font to `MesloLGM NF`.

Recommended: run PowerShell as Administrator so `winget` and font installs don't
prompt per package.

## Customizing

- **Git identity** is not committed. Configure yours locally:
  ```sh
  git config --global user.name  "Your Name"
  git config --global user.email "you@example.com"
  ```
- **Prompt theme** — edit `.p10k.zsh` (zsh) or `prompt.omp.json` (PowerShell).
- **Aliases / functions** — edit `shell.rc` (zsh) or `Powershell/Microsoft.PowerShell_profile.ps1`.

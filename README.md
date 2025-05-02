# Dotfiles Bootstrap & Installation Scripts

This directory contains all installation, bootstrap, and system setup scripts for your dotfiles. It is designed to be **separate from your actual dotfiles/configs** for clarity, maintainability, and reusability.

## Structure

- `setup-chezmoi.ps1` — Windows setup and bootstrap script
- `setup-chezmoi.sh` — macOS/Linux setup and bootstrap script
- `setup-chezmoi-arch.sh` — Arch Linux-specific setup script
- `dot_Brewfile` — Homebrew bundle file (macOS)
- `.macos/` — macOS system and app configuration scripts
- `scripts/` — Helper scripts for all platforms
  - `windows/` — Windows-specific install and healer scripts
  - `unix/` — macOS/Linux/Unix install, healer, and theme scripts

## Usage

### 1. **Clone the Repository**

```sh
git clone https://github.com/fishingpvalues/dotfiles.git
cd dotfiles
```

### 2. **Run the Setup Script for Your Platform**

#### **Windows**

```powershell
bootstrap/setup-chezmoi.ps1
```

#### **macOS/Linux**

```bash
chmod +x bootstrap/setup-chezmoi.sh
./bootstrap/setup-chezmoi.sh
```

#### **Arch Linux**

```bash
chmod +x bootstrap/setup-chezmoi-arch.sh
./bootstrap/setup-chezmoi-arch.sh
```

### 3. **Install All Tools and Fonts**

- The setup script will call the appropriate install script for your OS:
  - Windows: `bootstrap/scripts/windows/install.ps1`
  - macOS/Linux: `bootstrap/scripts/unix/install.sh`

### 4. **Heal/Fix Common Issues**

- If you encounter issues, run the healer script for your OS:
  - Windows: `bootstrap/scripts/windows/healer.ps1`
  - macOS/Linux: `bootstrap/scripts/unix/healer.sh`

### 5. **macOS System Tweaks**

- Run or edit scripts in `.macos/` for system and app configuration.
- Edit `dot_Brewfile` to manage Homebrew packages.

## Best Practices

- **Keep this directory focused on installation and bootstrap logic.**
- **Do not store secrets or machine-specific config here.** Use chezmoi's secret management for sensitive data.
- **Update this README** if you add new scripts or change the bootstrap process.
- **Test scripts in a clean environment** before using on production systems.

## Troubleshooting

- If a script fails, check permissions and ensure all prerequisites (e.g., Homebrew, Xcode CLT, PowerShell) are installed.
- For platform-specific issues, see the main repo's README or the OS-specific guides.

## Contributing

- When adding new install logic, place it in the appropriate subdirectory and update this README.
- Keep scripts idempotent and safe to re-run.

---

For more details, see the main [README.md](../README.md) and OS-specific guides.

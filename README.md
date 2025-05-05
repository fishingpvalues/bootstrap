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

## CI/CD & Docker-Based Testing

This repo uses advanced CI/CD automation to ensure reliability and cross-platform compatibility:

- **GitHub Actions** automatically lint and test all bootstrap scripts on every push and pull request.
- **Docker-based matrix testing** runs the main setup script in clean containers for:
  - Ubuntu (latest)
  - Fedora (latest)
  - Alpine (latest)
- **Idempotency check:** The main install script is run twice in a row to ensure it is safe to re-run.
- **Shell linting:** All `.sh` scripts are checked with `shellcheck`.
- **PowerShell linting:** `.ps1` scripts are checked on Windows runners.

This ensures your bootstrap logic works in real-world, clean environments and is safe for all contributors and users.

## Advanced CI/CD Features

- **Secrets Integration:**
  - CI workflows can securely use secrets (e.g., API keys, tokens) via GitHub Actions secrets. Example: `MY_SECRET` is available to scripts as an environment variable.
- **Deployment Automation:**
  - On every push to `main`, an automated GitHub Release is created with the latest scripts. This can be extended to publish artifacts or documentation.
- **Advanced Test Scenarios:**
  - CI checks for expected files and output after running bootstrap scripts.
  - Idempotency is tested by running install scripts twice in a row.
  - Output is validated for success messages.

These enhancements ensure your bootstrap logic is secure, robust, and ready for real-world use and collaboration.

## Cloning as a Submodule

If you cloned the main dotfiles repository without submodules, run:

```sh
git submodule update --init --recursive
```

## Automated Testing Framework

This repository includes a robust, cross-platform testing framework to ensure all setup scripts, dotfiles, and functions work as expected on all supported platforms (Linux, macOS, Windows).

### How It Works

- **Docker-based matrix testing** for Ubuntu, Fedora, Arch, and Alpine Linux using Dockerfiles in `test/`.
- **GitHub Actions CI** runs all tests on every push and pull request, including:
  - All Linux Docker containers
  - macOS runner
  - Windows runner
- **Test scripts** (`test/test.sh`, `test/test.ps1`) source all shell profiles and run all key functions/aliases, checking for errors and expected output.
- **Idempotency**: Install scripts are run multiple times to ensure re-runs are safe.

### Running Tests Locally

#### Linux (Docker required)

```sh
./test/run-all.sh
```

#### macOS

```sh
./test/test.sh
```

#### Windows (PowerShell)

```powershell
./test/test.ps1
```

### In CI

- All tests run automatically via `.github/workflows/test-dotfiles.yml`.

### Refreshing All READMEs

To keep documentation up to date after changes, scan the root directory for all `README*.md` files and update them with any new features, scripts, or test instructions. You can automate this with a script or manually review and update each README as needed.

---

For more details, see the main [README.md](../README.md) and OS-specific guides.

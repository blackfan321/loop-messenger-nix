# loop-messenger-nix

Nix flake for [Loop Messenger](https://loop.ru/).
Repackages the official Linux and macOS builds.

[![linux](https://img.shields.io/badge/linux-6.0.3-informational)](./loop-desktop.nix)
[![macOS](https://img.shields.io/badge/macOS-6.0.3-informational)](./loop-desktop.nix)
[![CI](https://img.shields.io/github/actions/workflow/status/blackfan321/loop-messenger-nix/update.yml?label=CI)](https://github.com/blackfan321/loop-messenger-nix/actions/workflows/update.yml)

## Quick Start

**Try it without installing:**
```bash
nix run github:blackfan321/loop-messenger-nix
```

**Install into your profile:**
```bash
nix profile install github:blackfan321/loop-messenger-nix
```

## Installation

### NixOS Flake

```nix
{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    loop-messenger = {
      url = "github:blackfan321/loop-messenger-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, loop-messenger, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [{ pkgs, ... }: {
        environment.systemPackages = [
          loop-messenger.packages.${pkgs.stdenv.hostPlatform.system}.loop-desktop
        ];
      }];
    };
  };
}
```

### Home Manager

```nix
{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.loop-messenger.packages.${pkgs.stdenv.hostPlatform.system}.loop-desktop
  ];
}
```

## Platforms

- `x86_64-linux`
- `aarch64-linux`
- `aarch64-darwin`

## Just

Set the default arch (`x86_64` or `arm64`) at the top of `justfile`.

### Linux
| Command | Description |
|---|---|
| `just get-latest-appimage-version` | Prints the latest AppImage version |
| `just pull-appimage <version> [arch]` | Downloads an AppImage for a given version; prints its sha256 |
| `just pull-latest-appimage [arch]` | Downloads the latest AppImage; prints its sha256 |

### macOS
| Command | Description |
|---|---|
| `just get-latest-dmg-version` | Prints the latest Apple Silicon disk image version |
| `just pull-dmg <version>` | Downloads a disk image for a given version; prints its sha256 |
| `just pull-latest-dmg` | Downloads the latest disk image; prints its sha256 |

### Maintenance
| Command | Description |
|---|---|
| `just update-application` | Updates the package to the latest release for each platform |
| `just cleanup` | Removes downloaded application artifacts from the repo root |

### Pre-commit (prek)
| Command | Description |
|---|---|
| `just prek-install` | Installs the pre-commit hook |
| `just prek-uninstall` | Removes the pre-commit hook |
| `just prek-run` | Runs all checks against all repo files |

## Devshell

Allow [direnv](https://direnv.net/) to activate flake devshell:

```bash
direnv allow
```

You also need [nix-direnv](https://github.com/nix-community/nix-direnv). The shell provides `just`, `rg`, `sed`, `wget2`, and the pre-commit packages.

Or enter the shell directly:

```bash
nix develop
```

## Pre-commit

TBD

## Automated Updates

TBD

# loop-messenger-nix

Nix flake for [Loop Messenger](https://loop.ru/).
Repackages the official Linux and macOS builds.

[![linux](https://img.shields.io/badge/linux-6.0.4-informational)](./_sources/generated.nix)
[![macOS](https://img.shields.io/badge/macOS-6.0.4-informational)](./_sources/generated.nix)
[![CI](https://img.shields.io/github/actions/workflow/status/blackfan321/loop-messenger-nix/auto-updates.yml?label=CI)](https://github.com/blackfan321/loop-messenger-nix/actions/workflows/auto-updates.yml)

## Quick Start

**Try without installing:**
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

## Devshell

Allow [direnv](https://direnv.net/) to activate the flake devshell:

```bash
direnv allow
```

You'll also likely need [nix-direnv](https://github.com/nix-community/nix-direnv). The shell provides `just`, `jq`, `nvfetcher`, `sed`, and the pre-commit packages.

Or enter the shell directly:

```bash
nix develop
```

## Just

[just](https://github.com/casey/just) is a command runner (like `make`, but simpler). Included in the devshell.

| Command | Description |
|---|---|
| [`just update-application`](justfile#L34) | Runs `nvfetcher` and refreshes README version badges |
| [`just update-sources`](justfile#L18) | Runs `nvfetcher` |
| [`just update-badges`](justfile#L23) | Refreshes README version badges from [`_sources/generated.json`](_sources/generated.json) |

## Pre-commit

- [nixfmt](https://github.com/NixOS/nixfmt)
- [deadnix](https://github.com/astro/deadnix)
- [statix](https://github.com/nerdypepper/statix)

Pre-commit hooks are installed automatically when you enter the devshell via [git-hooks.nix](https://github.com/cachix/git-hooks.nix) / [prek](https://github.com/j178/prek).

## Upstream

**Version source:**
- [Loop download page](https://loop.ru/download/)

**Source artifacts:**
- Linux x86_64: `https://artifacts.wilix.dev/repository/loop-files/loop-{version}/loop-desktop-{version}-linux-x86_64.AppImage`
- Linux aarch64: `https://artifacts.wilix.dev/repository/loop-files/loop-{version}/loop-desktop-{version}-linux-arm64.AppImage`
- macOS: `https://artifacts.wilix.dev/repository/loop-files/loop-{version}/loop-desktop-{version}-mac-arm64.dmg`

The aarch64 AppImage is not listed on the download page, but is published alongside the x86_64 build — its URL is derived from the tracked version.

Versions and source hashes are managed with [nvfetcher](https://github.com/berberman/nvfetcher), which generates Nix expressions to [`_sources/generated.nix`](_sources/generated.nix). Source metadata is stored in [`_sources/generated.json`](_sources/generated.json).

## Automated Updates

### [`auto-updates.yml`](.github/workflows/auto-updates.yml)

**Schedule:** daily at 06:00 UTC

**What it does:**
- Updates sources using `nvfetcher`
- Refreshes README version badges
- Opens a PR on `chore/update-loop` when versions change

Example PR title / commit message:

```
chore: update Loop Messenger (6.0.3 → 6.0.4)
```

PR body is the `nvfetcher` changelog.

### [`release.yml`](.github/workflows/release.yml)

**Trigger:** push to `main` when `_sources/generated.json` changes

**What it does:**
- Creates a GitHub Release `X.Y.Z`

Example release:

- **Tag:** `6.0.4`
- **Name:** `6.0.4`
- **Notes:** `Loop Messenger 6.0.4`

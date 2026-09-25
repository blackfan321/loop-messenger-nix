{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  ...
}:

let
  pname = "loop-desktop";

  linuxSources = {
    version = "6.0.3";
    x86_64-linux = {
      suffix = "x86_64";
      hash = "sha256-zGWKlY6XwuL0e2mDpB/1t0UnW73bhCPcg6XkBJBCEFY=";
    };
    aarch64-linux = {
      suffix = "arm64";
      hash = "sha256-7EfTWiWsIoaUJDqumRplkK4LmWZkUb/Q/Tz8Hj7PHrw=";
    };
  };

  darwinSources = {
    version = "6.0.3";
    aarch64-darwin = {
      hash = "sha256-4MxWBLplF4sQZHaebXLTjVlEv0b7qH6BA0Q4c7LYzkk=";
    };
  };

  system = stdenv.hostPlatform.system;

  platformNames =
    sources: lib.filter (name: lib.isAttrs sources.${name}) (builtins.attrNames sources);

  meta = with lib; {
    description = "Loop client";
    longDescription = ''
      Desktop client for Loop Messenger
    '';
    mainProgram = pname;
    homepage = "https://loop.ru";
    downloadPage = "https://loop.ru/download/";
    license = licenses.unfree;
    maintainers = with maintainers; [ blackfan321 ];
    platforms = platformNames linuxSources ++ platformNames darwinSources;
  };
in
if stdenv.hostPlatform.isLinux then
  let
    source = linuxSources.${system} or (throw "Unsupported system: ${system}");
    inherit (linuxSources) version;
    src = fetchurl {
      url = "https://artifacts.wilix.dev/repository/loop-files/loop-${version}/loop-desktop-${version}-linux-${source.suffix}.AppImage";
      inherit (source) hash;
    };
    appimageContents = appimageTools.extract {
      inherit pname src version;
    };
    mkDesktop = import ./desktop-helper.nix;
  in
  appimageTools.wrapType2 {
    inherit
      pname
      src
      meta
      version
      ;

    extraInstallCommands = mkDesktop {
      inherit pname appimageContents;
    };
  }
else if stdenv.hostPlatform.isDarwin then
  let
    source = darwinSources.${system} or (throw "Unsupported system: ${system}");
    inherit (darwinSources) version;
  in
  stdenv.mkDerivation {
    inherit pname meta version;

    src = fetchurl {
      url = "https://artifacts.wilix.dev/repository/loop-files/loop-${version}/loop-desktop-${version}-mac-arm64.dmg";
      inherit (source) hash;
    };

    # hdiutil lives outside the Nix sandbox.
    __noChroot = true;

    dontBuild = true;
    dontFixup = true;

    sourceRoot = "LOOP.app";

    unpackPhase = ''
      runHook preUnpack

      tmp=$(mktemp -d)
      /usr/bin/hdiutil attach "$src" -mountpoint "$tmp" -nobrowse -quiet
      app=$(find "$tmp" -maxdepth 2 -name 'LOOP.app' -type d | head -n1)
      cp -R "$app" ./LOOP.app
      /usr/bin/hdiutil detach "$tmp" -quiet
      rm -rf "$tmp"

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications/LOOP.app"
      cp -R Contents "$out/Applications/LOOP.app/"

      runHook postInstall
    '';
  }
else
  throw "Unsupported system: ${system}"

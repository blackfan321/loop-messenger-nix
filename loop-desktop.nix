{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  fetchgit,
  fetchFromGitHub,
  dockerTools,
  ...
}:

let
  inherit (import ./flake/systems.nix) systems;

  system = stdenv.hostPlatform.system;

  sources = import ./_sources/generated.nix {
    inherit
      fetchgit
      fetchurl
      fetchFromGitHub
      dockerTools
      ;
  };

  pname = "loop-desktop";

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
    platforms = systems;
  };
in
if !(lib.elem system systems) then
  throw "Unsupported system: ${system}"
else if stdenv.hostPlatform.isLinux then
  let
    source =
      if stdenv.hostPlatform.isx86_64 then sources.loop-linux-x86_64 else sources.loop-linux-aarch64;
    inherit (source) version src;
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
else
  let
    inherit (sources.loop-darwin) version src;
  in
  stdenv.mkDerivation {
    inherit
      pname
      meta
      version
      src
      ;

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

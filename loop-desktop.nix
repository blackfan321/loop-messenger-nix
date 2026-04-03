{
  lib,
  appimageTools,
  fetchurl,
  ...
}:

let
  pname = "loop-desktop";
  version = "6.0.3";

  src = fetchurl {
    url = "https://artifacts.wilix.dev/repository/loop-files/loop-${version}/loop-desktop-${version}-linux-x86_64.AppImage";
    hash = "sha256-zGWKlY6XwuL0e2mDpB/1t0UnW73bhCPcg6XkBJBCEFY=";
  };

  appimageContents = appimageTools.extractType1 { inherit pname version src; };
  mkDesktop = import ./desktop-helper.nix;
in appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = mkDesktop {inherit pname; inherit appimageContents;};

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
    platforms = [ "x86_64-linux" ];
  };
}

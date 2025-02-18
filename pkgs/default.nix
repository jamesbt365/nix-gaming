{
  inputs,
  pkgs,
}: let
  inherit (pkgs) callPackage;

  wineBuilder = wine: build: extra:
    (import ./wine ({
        inherit inputs build pkgs;
        inherit (pkgs) callPackage fetchFromGitHub fetchurl lib moltenvk pkgsCross pkgsi686Linux stdenv_32bit;
        supportFlags = (import ./wine/supportFlags.nix).${build};
      }
      // extra))
    .${wine};

  packages = rec {
    dxvk = callPackage ./dxvk {};
    dxvk-w32 = pkgs.pkgsCross.mingw32.callPackage ./dxvk {};
    dxvk-w64 = pkgs.pkgsCross.mingwW64.callPackage ./dxvk {};

    osu-lazer-bin = callPackage ./osu-lazer-bin {};

    osu-stable = callPackage ./osu-stable {
      wine = wine-osu;
      wine-discord-ipc-bridge = wine-discord-ipc-bridge.override {wine = wine-osu;};
    };

    roblox-player = callPackage ./roblox-player {
      wine = wine-tkg;
      inherit wine-discord-ipc-bridge;
    };

    technic-launcher = callPackage ./technic-launcher {};

    vkd3d-proton = callPackage ./vkd3d-proton {};
    vkd3d-proton-w32 = pkgs.pkgsCross.mingw32.callPackage ./vkd3d-proton {};
    vkd3d-proton-w64 = pkgs.pkgsCross.mingwW64.callPackage ./vkd3d-proton {};

    wine-discord-ipc-bridge = callPackage ./wine-discord-ipc-bridge {wine = wine-tkg;};

    # broken
    #winestreamproxy = callPackage ./winestreamproxy { wine = wine-tkg; };

    wine-ge = wineBuilder "wine-ge" "full" {};

    wine-osu = wineBuilder "wine-osu" "base" {};

    wine-tkg = wineBuilder "wine-tkg" "full" {};

    wineprefix-preparer = callPackage ./wineprefix-preparer {inherit dxvk-w32 vkd3d-proton-w32 dxvk-w64 vkd3d-proton-w64;};
  };
in
  packages

let

  # Pkgs
  pkgs = import <nixpkgs> {};

  # SDK Manager
  SDKManager = pkgs.buildGoModule rec {

    # Info
    pname = "connect-iq-sdk-manager-cli";
    version = "0.8.4";

    # Source
    src = pkgs.fetchFromGitHub {
      owner = "lindell";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-NEzy+lvBAvrapR6lq7k8b/3N4Os3Q7Wx4Vfv5qcjJiU=";
    };

    # Disable Tests
    doCheck = false;

    # Vendor
    proxyVendor = true;
    vendorHash = "sha256-mr/i4lTLUn8VBHHdyNntPQBgAfcMLlFjL6qhh2r2a7k=";

  };

  fontbm = pkgs.stdenv.mkDerivation rec {
    pname = "fontbm";
    version = "0.6.1";

    src = pkgs.fetchFromGitHub {
      owner = "vladimirgamalyan";
      repo = "fontbm";
      rev = "v${version}";
      hash = "sha256-hkIxwDMrxsZAaBAdCug0kNia/2NHSnAECQItuut+xac=";
    };

    nativeBuildInputs = [
      pkgs.cmake
      pkgs.pkg-config
    ];

    buildInputs = [
      pkgs.freetype
    ];

    cmakeFlags = [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp fontbm $out/bin/
      runHook postInstall
    '';
  };

  oldPkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
  }) {};

in pkgs.mkShell {

  packages = [

    # Java
    pkgs.openjdk

    # SDK Manager
    SDKManager

    # Font
    fontbm

  ];

  # Needed Libraries
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [

    # Needed
    libusb1
    zlib
    webkitgtk_4_1
    xorg.libXxf86vm
    libjpeg8
    libpng

    # Networking
    glib-networking

    # Extra
    libsecret
    expat
    udev

    # Visual
    fontconfig
    freetype
    libsoup_2_4
    gdk-pixbuf
    pango
    cairo
    gtk3
    atk

    # Xorg
    xorg.libXext
    xorg.libX11
    xorg.libSM
    libxkbcommon

    # Default
    glib.out
    stdenv.cc.cc.lib

  ]);

  shellHook = ''
    export GIO_MODULE_DIR=${pkgs.glib-networking}/lib/gio/modules/
  '';

}

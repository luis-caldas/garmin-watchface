let

  # Pkgs
  real = import <nixpkgs> {
    config.allowInsecurePredicate = _: true;
  };

  pkgs = import (builtins.fetchTarball "https://channels.nixos.org/nixos-24.11/nixexprs.tar.xz") {
    system = builtins.currentSystem;
    config.allowInsecurePredicate = _: true;
  };

  # SDK Manager
  SDKManager = real.buildGoModule rec {

    # Info
    pname = "connect-iq-sdk-manager-cli";
    version = "0.8.4";

    # Source
    src = real.fetchFromGitHub {
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

  fontbm = real.stdenv.mkDerivation rec {
    pname = "fontbm";
    version = "0.6.1";

    src = real.fetchFromGitHub {
      owner = "vladimirgamalyan";
      repo = "fontbm";
      rev = "v${version}";
      hash = "sha256-hkIxwDMrxsZAaBAdCug0kNia/2NHSnAECQItuut+xac=";
    };

    nativeBuildInputs = [
      real.cmake
      real.pkg-config
    ];

    buildInputs = [
      real.freetype
    ];

    cmakeFlags = [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    ];

    postPatch = ''
      sed -i '/#include <sstream>/a #include <cstdint>' src/FontInfo.h
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp fontbm $out/bin/
      runHook postInstall
    '';
  };

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
    webkitgtk_4_0
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
    real.libsoup_2_4
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

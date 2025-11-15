let

  # Pkgs
  pkgs = import <nixpkgs> {};

  # SDK Manager
  SDKManager = pkgs.buildGoModule rec {

    # Info
    pname = "connect-iq-sdk-manager-cli";
    version = "0.7.1";

    # Source
    src = pkgs.fetchFromGitHub {
      owner = "lindell";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-igiqccFPCqt/OWdCejcAKCp/Jlkf4PWde1OoBrsvq1E=";
    };

    # Disable Tests
    doCheck = false;

    # Vendor
    proxyVendor = true;
    vendorHash = "sha256-mr/i4lTLUn8VBHHdyNntPQBgAfcMLlFjL6qhh2r2a7k=";

  };

in pkgs.mkShell {

  packages = [

    # Java
    pkgs.openjdk

    # SDK Manager
    SDKManager

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

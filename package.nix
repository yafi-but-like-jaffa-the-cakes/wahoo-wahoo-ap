{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchpatch,
  autoPatchelfHook,
  python3,
  pkg-config,
  git,
  openssl,
  cmake,
  jsoncpp,
  audiofile,
  SDL2,
  libGL,
  hexdump,
  region ? "us",
  runCommand,
  zlib,
  _60fps ? true,
  moveset ? true,
  nonstop ? true,
}: let
  file = fetchurl {
    url = "https://github.com/Revolution641/rom-archive/raw/3ed88d7be055672f4a67179b23c51c7d0ac799de/Super%20Mario%2064%20(USA).z64";
    hash = "sha256-F84Hc0PGEz+Mny1tbZpKtiyM0qpXxArqH0kLTIuyHZE=";
  };
  result = runCommand "baserom-${region}-safety-dir" {} ''
    mkdir $out
    cp ${file} $out/baserom.${region}.z64
  '';
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "sm64ex-ap";
    rev' = "9289288f241cd03c3287306c715eca0755333075";
    version = "v1.0.0+${finalAttrs.rev'}";

    baseRom = "${result.outPath}/baserom.${region}.z64";

    src = fetchFromGitHub {
      owner = "N00byKing";
      repo = "sm64ex";
      rev = finalAttrs.rev';
      hash = "sha256-ev1YQK3AODXXmNJL7Eq6dKBkIp5cQSxetOElwenWm1w=";
      # hash = lib.fakeHash;

      # leaveDotGit = true;
      deepClone = true;
      fetchSubmodules = true;
      forceFetchGit = true;
    };

    patches =
      lib.optionals
      _60fps
      [
        (fetchpatch {
          name = "60fps_ex.patch";
          url = "file://${finalAttrs.src}/enhancements/60fps_ex.patch";
          hash = "sha256-2V7WcZ8zG8Ef0bHmXVz2iaR48XRRDjTvynC4RPxMkcA=";
        })
      ]
      ++ lib.optionals
      moveset
      [
        (fetchpatch {
          name = "Extended.Moveset.v1.03b.sm64ex_archipelago.patch";
          url = "file://${finalAttrs.src}/enhancements/Extended.Moveset.v1.03b.sm64ex_archipelago.patch";
          hash = "sha256-kvsVZu5sXRJpya2BcnJOA+sgORBL3jK6YiZf/Gt3LlA=";
        })
      ]
      ++ lib.optionals
      nonstop
      [
        (fetchpatch {
          name = "nonstop_mode_always_enabled.patch";
          url = "file://${finalAttrs.src}/enhancements/nonstop_mode_always_enabled.patch";
          hash = "sha256-s9V8UeIcjNyczfNPmgawgCmKJUkdCItSEr1cQ3ZyX/Q=";
        })
      ];

    nativeBuildInputs = [
      autoPatchelfHook
      python3
      pkg-config
      hexdump
      git
      cmake
      openssl.dev
    ];

    buildInputs = [
      audiofile
      SDL2
      libGL
      zlib
      jsoncpp
    ];

    enableParallelBuilding = true;
    dontUseCmakeConfigure = true;

    makeFlags =
      [
        "VERSION=${region}"
        "BETTERCAMERA=1"
        "TEXTURE_FIX=1"
        "DISCORDRPC=1"
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        "OSX_BUILD=1"
      ];

    preConfigure = ''
      echo $out
    '';

    preBuild = ''
      patchShebangs extract_assets.py
      ln -s ${finalAttrs.baseRom} ./baserom.${region}.z64
    '';

    installPhase =
      ''
        runHook preInstall

        mkdir -p $out/bin
        cp build/${region}_pc/sm64.${region}.f3dex2e $out/bin/sm64ex-ap
        cp build/${region}_pc/libAPCpp.so $out/bin/libAPCpp.so
      ''
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        cp lib/discord/libdiscord-rpc.dylib $out/bin/libdiscord-rpc.dylib
      ''
      + lib.optionalString stdenv.hostPlatform.isLinux ''
        cp lib/discord/libdiscord-rpc.so $out/bin/libdiscord-rpc.so
      ''
      + ''
        runHook postInstall
      '';

    meta = {
      homepage = "https://github.com/N00byKing/sm64ex";
      description = "Fork of https://github.com/sm64-port/sm64-port with additional features.";
      mainProgram = "sm64ex-ap";
      # license = lib.licenses.unfree;
      maintainers = [];
      platforms = lib.platforms.unix;
    };
  })

{ perl
, autoconf
, automake
, python3
, gcc
, cabal-install
, runCommand
, lib
, stdenv

, ghc
, happy
, alex

, ghcjsSrc
, version
}:

runCommand "configured-ghcjs-src" {
  nativeBuildInputs = [
    perl
    autoconf
    automake
    python3
    ghc
    happy
    alex
    cabal-install
  ] ++ lib.optionals stdenv.isDarwin [
    gcc # https://github.com/ghcjs/ghcjs/issues/663
  ];
  inherit ghcjsSrc;
} ''
  export HOME=$(pwd)
  mkdir $HOME/.cabal
  touch $HOME/.cabal/config
  cp -r "$ghcjsSrc" "$out"
  chmod -R +w "$out"
  cd "$out"

  # TODO: Find a better way to avoid impure version numbers
  sed -i 's/RELEASE=NO/RELEASE=YES/' ghc/configure.ac

  # These files are needed by ghc-boot package, and these are generated by the
  # make/hadrian build system when compiling ghc. Since we dont have access to
  # the generated code of the ghc while it got built, here is a little hack to
  # generate these again.
  runhaskell ${./generate_host_version.hs}
  mkdir -p utils/pkg-cache/ghc/libraries/ghc-boot/dist-install/build/GHC/Platform
  mv Host.hs utils/pkg-cache/ghc/libraries/ghc-boot/dist-install/build/GHC/Platform/Host.hs
  mv Version.hs utils/pkg-cache/ghc/libraries/ghc-boot/dist-install/build/GHC/Version.hs

  # The ghcjs has the following hardcoded paths of lib dir in its code. Patching
  # these to match the path expected by the nixpkgs's generic-builder, etc.
  sed -i 's/libSubDir = "lib"/libSubDir = "lib\/ghcjs-${version}"/' src-bin/Boot.hs
  sed -i 's@let libDir = takeDirectory haddockPath </> ".." </> "lib"@let libDir = takeDirectory haddockPath </> ".." </> "lib/ghcjs-${version}"@' src-bin/HaddockDriver.hs

  patchShebangs .
  ./utils/makePackages.sh copy
''

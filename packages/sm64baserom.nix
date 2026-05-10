{
  fetchurl,
  runCommand,
  region ? "us",
  url ? null,
  hash ? null,
}: let
  _url =
    if url == null
    then builtins.readFile ../url.txt
    else url;
  _hash =
    if hash == null
    then builtins.readFile ../hash.txt
    else hash;
in let
  file = fetchurl {
    url = "${_url}";
    hash = "${_hash}";
  };
  result = runCommand "baserom-${region}-safety-dir" {} ''
    mkdir $out
    cp ${file} $out/baserom.${region}.z64
  '';
in
  result
  // {
    romPath = "${result.outPath}/baserom.${region}.z64";
  }

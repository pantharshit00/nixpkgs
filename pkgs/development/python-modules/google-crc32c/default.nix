{ lib, buildPythonPackage, fetchFromGitHub, cffi, crc32c, pytestCheckHook }:

buildPythonPackage rec {
  pname = "google-crc32c";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "python-crc32c";
    rev = "v${version}";
    sha256 = "0snpqmj2avgqvfd7w26g03w78s6phwd8h55bvpjwm4lwj8hm8id7";
  };

  buildInputs = [ crc32c ];

  propagatedBuildInputs = [ cffi ];

  LDFLAGS = "-L${crc32c}/lib";
  CFLAGS = "-I${crc32c}/include";

  checkInputs = [ pytestCheckHook crc32c ];

  pythonImportsCheck = [ "google_crc32c" ];

  meta = with lib; {
    homepage = "https://github.com/googleapis/python-crc32c";
    description = "Wrapper the google/crc32c hardware-based implementation of the CRC32C hashing algorithm";
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ freezeboy SuperSandro2000 ];
  };
}

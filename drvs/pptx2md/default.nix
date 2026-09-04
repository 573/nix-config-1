# in overlay: desed = final.callPackage "${rootPath}/drvs/desed" { };
{
  lib,
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pptx2md";
  version = "2.0.6";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-KtwFLZ+14DGwdgiH7qkx58eMIIt7JECxBGijwodLTkQ=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    setuptools
    pillow
    numpy
    pydantic
    python-pptx
    rapidfuzz
    scipy
    tqdm
  ];

  nativeBuildInputs = with python3Packages; [ poetry-core ];

  meta = with lib; {
    description = "A tool to convert Powerpoint pptx file into markdown.";
    homepage = "https://github.com/ssine/pptx2md";
    license = licenses.asl20;
    maintainers = [ ];
  };
})

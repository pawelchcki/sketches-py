{
  description = "ddsketch-py";
  nixConfig.bash-prompt-prefix = "\[ddsketch-py\] ";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        python = pkgs.python312;

        pythonDevEnv = python;

        treefmt = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

        finalPkg = python.pkgs.buildPythonPackage rec {
          name = "ddsketch";
          version = "3.0.1";
          src = ./.;

          propagatedBuildInputs = with python.pkgs; [
            six
            protobuf
	    setuptools
          ];
          nativeBuildInputs = with python.pkgs; [ setuptools_scm ];
          checkInputs = with python.pkgs; [
            pytest
            numpy
          ];
          env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

          pythonImportsCheck = [ "ddsketch" ];

          postPatch = ''
            patchShebangs setup.py
            echo version=\"${version}\" > ddsketch/__version.py
          '';
        };

        devEnv = pkgs.buildEnv {
          name = "root";
          paths = [ pkgs.bashInteractive ];
          pathsToLink = [ "/bin" ];
        };
      in
      {
        packages = {
          python = python;
        };

        packages.default = finalPkg;
        formatter = treefmt.config.build.wrapper;

        checks = {
          python = finalPkg;
        };

        devShells.default = pkgs.mkShell {
          venvDir = "./.venv";
          nativeBuildInputs = [
            finalPkg.nativeBuildInputs
            python.pkgs.venvShellHook
            python.pkgs.six
            python.pkgs.protobuf
            python.pkgs.numpy
          ];
          propagatedBuildInputs = [ treefmt.config.build.wrapper ];
          packages = [
            python.pkgs.pytest
            treefmt.config.build.wrapper
          ];
        };
      }
    );
}

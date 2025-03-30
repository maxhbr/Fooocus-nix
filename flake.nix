{
  description = "Development environment for Fooocus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import nixpkgs { 
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git gitRepo gnupg autoconf curl
            procps gnumake util-linux m4 gperf unzip
            cudatoolkit linuxPackages.nvidia_x11
            libGLU libGL
            xorg.libXi xorg.libXmu freeglut
            xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib 
            ncurses5 stdenv.cc binutils
          ];

          packages = with pkgs; [
            python311
            python311Packages.pip
            #python311Packages.venv

            # Build dependencies that may be needed
            pkg-config
            cmake
            ninja
            gcc

            # System libraries needed for OpenCV and other dependencies
            zlib
            stdenv.cc.cc.lib  # Provides libstdc++
            opencv

            # Add these to your packages list if you have an NVIDIA GPU
            cudaPackages.cuda_cudart
            # cudaPackages.cuda_runtime
            cudaPackages.cudatoolkit
          ];

          shellHook = ''
            export CUDA_PATH=${pkgs.cudatoolkit}
            export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
            export EXTRA_CCFLAGS="-I/usr/include"

            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc.lib
              pkgs.zlib
              pkgs.opencv
              pkgs.linuxPackages.nvidia_x11
              pkgs.ncurses5
            ]}:$LD_LIBRARY_PATH

            # Create venv if it doesn't exist
            if [ ! -d "fooocus_env" ]; then
              python3 -m venv fooocus_env
              (
                source fooocus_env/bin/activate
                set -x
                pip install -r requirements_versions.txt
                # see https://github.com/lllyasviel/Fooocus/issues/3862
                pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128
              )
            fi
            
            # Activate venv
            source fooocus_env/bin/activate

            # Show Python version and location
            echo "Python version: $(python --version)"
            echo "Python location: $(which python)"
            echo ""
            echo "To install dependencies, run:"
            echo "pip install -r requirements_versions.txt"
            echo "To run the project, run:"
            echo "python entry_with_update.py --listen --preset realistic"
          '';
        };
      }
    );
} 
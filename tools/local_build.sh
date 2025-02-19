# Replicate the workflow from posix.yml locally on posix
# This may bitrot, compare it to the original file before using


# Set extra env
if [ "uname -m" == "x86_64" ]; then
    export TRAVIS_OS_NAME=ubuntu-latest
    export PLAT=x86_64
    # export PLAT=i86
    DOCKER_TEST_IMAGE=multibuild/xenial_${PLAT}
else
    export TRAVIS_OS_NAME=osx
    export LDFLAGS="-L/Library/Developer/CommandLineTools/SDKs/MacOSX12.1.sdk/usr/lib"
    export LIBRARY_PATH="-L/Library/Developer/CommandLineTools/SDKs/MacOSX12.1.sdk/usr/lib"
    export PLAT=x86_64
    # export PLAT=arm64
    export SUFFIX=gf_c469a42
    
fi
export REPO_DIR=OpenBLAS
export OPENBLAS_COMMIT="c2f4bdb"

# export MB_ML_LIBC=musllinux
# export MB_ML_VER=_1_1
# export MB_ML_VER=2014
export INTERFACE64=1

function install_virtualenv {
    # Install VirtualEnv
    python3 -m pip install --upgrade pip
    pip install virtualenv
}

function build_openblas {
    # Build OpenBLAS
    set -xeo pipefail
    if [ "$PLAT" == "arm64" ]; then
      sudo xcode-select -switch /Applications/Xcode_12.5.1.app
      export SDKROOT=/Applications/Xcode_12.5.1.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.3.sdk
      clang --version
    fi
    source tools/build_steps.sh
    echo "------ BEFORE BUILD ---------"
    before_build
    if [[ "$NIGHTLY" = "true" ]]; then
      echo "------ CLEAN CODE --------"
      clean_code $REPO_DIR develop
      echo "------ BUILD LIB --------"
      build_lib "$PLAT" "$INTERFACE64" "1"
    else
      echo "------ CLEAN CODE --------"
      clean_code $REPO_DIR $OPENBLAS_COMMIT
      echo "------ BUILD LIB --------"
      build_lib "$PLAT" "$INTERFACE64" "0"
    fi
}

# install_virtualenv
# build_openblas

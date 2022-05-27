#!/bin/sh

# Declare constants
readonly WHLSUFFIX=manylinux1_x86_64
readonly C_CLIENT_VERSION=4.5.1

# Check if the file exists with the parameter path passed
check_file_exist() {
    local file_path=$1
    if [ ! -f "$file_path" ]; then
        echo "$file_path not found!"
    fi
}

# Create whl package
build_package() {
    which python3
    python3 --version
    exec "$SHELL"
    which python3
    pyenv --version
    pyenv global 3.6.9
    which python3
    python3 setup.py bdist_wheel -p $WHLSUFFIX
}

# Check information rpm and deb package
check_package() {
    ls dist/*
    # local version=$(cat setup.py | grep "version=" | cut -f 2 -d"'")
    # local package_path=dist/griddb_python-$version-cp36-cp36m-$WHLSUFFIX.whl
    # check_file_exist "$package_path"
    # wheel2json "$package_path"
}

# Install whl package
install_client() {
    local version=$(cat setup.py | grep "version=" | cut -f 2 -d"'")
    local package_path=dist/griddb_python-$version-cp36-cp36m-$WHLSUFFIX.whl
    check_file_exist "$package_path"
    python -m pip install --upgrade --force-reinstall "$package_path"
}

# Run sample of Python Client
# You can refer to https://github.com/griddb/python_client
run_sample() {
    # Run sample
    local host=$1
    local port=$2
    local cluster_name=$3
    local username=$4
    local password=$5

    python sample/sample1.py $host $port $cluster_name $username $password
}

# Uninstall GridDB package
uninstall_package() {
    local package_name=$1
    python -m pip uninstall -y $package_name
}

# Prepare env for MacOS
install_packages_macos() {
    brew install pyenv
    pyenv install 3.6.9
    pyenv global 3.6.9

    echo 'eval "$(pyenv init -)"' > ~/.bash_profile
    source ~/.bash_profile
    python -m pip install --user --upgrade setuptools wheel
    python -m pip install wheel-inspect

    # Install SWIG
    wget https://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz
    tar xvfz swig-3.0.12.tar.gz
    cd swig-3.0.12
    ./configure
    make
    make install
    cd ..
    rm swig-3.0.12.tar.gz
    python -m pip install numpy pandas
    ls -lah $(which python)
    brew install nguyentientungduong/tools/griddb-c-client
    brew install docker docker-machine virtualbox
    brew cleanup

    # # Create virtual machine to run docker
    # mkdir -p ~/.docker/machine/cache/
    # curl -Lo ~/.docker/machine/cache/boot2docker.iso https://github.com/boot2docker/boot2docker/releases/download/v19.03.12/boot2docker.iso
    # docker-machine create --driver virtualbox --virtualbox-boot2docker-url ~/.docker/machine/cache/boot2docker.iso default
    # docker-machine ls
    # docker-machine upgrade default
    # # Forward ports between virtual machine and MacOS machine
    # ports=(10001 10010 10020 10040)
    # for i in "${!ports[@]}"
    # do
    #     VBoxManage controlvm default natpf1 "rule$i,tcp,,${ports[$i]},,${ports[$i]}"
    # done

    # Python Client for MacOS will include C Client
    brew install autoconf automake libtool
    wget https://github.com/griddb/c_client/archive/v$C_CLIENT_VERSION.tar.gz
    tar xvfz v$C_CLIENT_VERSION.tar.gz
    rm v$C_CLIENT_VERSION.tar.gz
 }

build_package_macos() {
    source ~/.bash_profile
    export LIBRARY_PATH=$LIBRARY_PATH:./c_client-$C_CLIENT_VERSION/bin/
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:./c_client-$C_CLIENT_VERSION/bin/
    python setup_macos.py bdist_wheel
}

# Check information rpm and deb package
check_package_macos() {
    ls dist/*
    # local version=$(cat setup.py | grep "version=" | cut -f 2 -d"'")
    # local package_path=dist/griddb_python-$version-cp36-cp36m-macosx_10_15_x86_64.whl
    # check_file_exist "$package_path"
    # wheel2json "$package_path"
}

# Install whl package
install_client_macos() {
    local version=$(cat setup.py | grep "version=" | cut -f 2 -d"'")
    local package_path=dist/griddb_python-$version-cp36-cp36m-macosx_10_15_x86_64.whl
    check_file_exist "$package_path"
    python -m pip install --upgrade --force-reinstall "$package_path"
}


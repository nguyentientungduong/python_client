#!/bin/sh

# Declare constants for OS Ubuntu, CentOS, openSUSE
readonly UBUNTU=Ubuntu
readonly CENTOS=Centos
readonly OPENSUSE=Opensuse
readonly WHLSUFFIX=manylinux1_x86_64

# Check if the file exists with the parameter path passed
check_file_exist() {
    local file_path=$1
    if [ ! -f "$file_path" ]; then
        echo "$file_path not found!"
    fi
}

# Create whl package
build_package() {
    cd python_client/
    python setup.py bdist_wheel -p $WHLSUFFIX
}

# Check information rpm and deb package
check_package() {
    cd python_client/ 
    version=$(cat setup.py | grep "version=" | cut -f 2 -d"'")
    package_path=dist/griddb_python-$version-cp36-cp36m-$WHLSUFFIX.whl
    check_file_exist "$package_path"
    wheel2json "$package_path"
}

# Install whl package
install_client() {
    local package_path=$1
    check_file_exist "$package_path"
    python -m pip install "$package_path"
}


#!/bin/sh

# Declare constants for OS Ubuntu, CentOS, openSUSE
readonly UBUNTU=Ubuntu
readonly CENTOS=Centos
readonly OPENSUSE=Opensuse

# Check if the file exists with the parameter path passed
check_file_exist() {
    local file_path=$1
    if [ ! -f "$file_path" ]; then
        echo "$file_path not found!"
    fi
}

# Build Python Client
build_python_client() {
    cd python_client/
    make
}

# Create whl package
build_package() {
    cd python_client/
    python setup.py bdist_wheel
}

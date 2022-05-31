#!/bin/sh

# Declare constants
readonly WHLSUFFIX=manylinux1_x86_64
readonly C_CLIENT_VERSION=5.0.0

# Check if the file exists with the parameter path passed
check_file_exist() {
    local file_path=$1
    if [ ! -f "$file_path" ]; then
        echo "$file_path not found!"
    fi
}

# Install gcc/g++ and C API
install_dependencies() {
    sudo apt-get update -y
    sudo apt-get install -y gcc-4.8 g++-4.8
    echo 'deb http://download.opensuse.org/repositories/home:/knonomura/xUbuntu_18.04/ /' | sudo tee /etc/apt/sources.list.d/home:knonomura.list
    curl -fsSL https://download.opensuse.org/repositories/home:knonomura/xUbuntu_18.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_knonomura.gpg > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y griddb-c-client
}

# Install python and dependencies of python API
install_pyenv() {
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init --path)"\nfi' >> ~/.bash_profile
    source ~/.bash_profile && pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION
    python3 -m pip install setuptools wheel
    python3 -m pip install wheel-inspect launchpadlib
    python3 -m pip install numpy pandas
}

# Create whl package
build_package() {
    source ~/.bash_profile && python3 setup.py bdist_wheel -p $WHLSUFFIX
}

get_filename_whl() {
    file_path=`ls dist/*.whl`
    filename="$(basename -- $file_path)"
    echo $filename
}

# Check information whl package
check_package() {
    whl_file=`get_filename_whl`
    source ~/.bash_profile
    package_path="dist/$whl_file"
    check_file_exist "$package_path"
    wheel2json "$package_path"
}

# Install whl package
install_client() {
    whl_file=`get_filename_whl`
    package_path="dist/$whl_file"
    check_file_exist "$package_path"
    source ~/.bash_profile
    python3 -m pip install --upgrade --force-reinstall "$package_path"
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
    source ~/.bash_profile
    python3 sample/sample1.py $host $port $cluster_name $username $password
}

# Uninstall GridDB package
uninstall_package() {
    local package_name=$1
    source ~/.bash_profile
    python3 -m pip uninstall -y $package_name
}

# Prepare env for MacOS
install_packages_macos() {
    # Install docker for start GridDB server
    brew install docker docker-machine
    mkdir -p ~/.docker/machine/cache/
    curl -Lo ~/.docker/machine/cache/boot2docker.iso https://github.com/boot2docker/boot2docker/releases/download/v19.03.12/boot2docker.iso
    docker-machine rm default

    # On Mac OS X, VM VirtualBox will only allow IP addresses in the 192.168.56.0/21 range to be assigned to host-only adapters.
    # That range corresponds to 192.168.56.1 - 192.168.63.255.
    docker-machine create -d virtualbox --virtualbox-hostonly-cidr "192.168.63.1/24" default
    eval "$(docker-machine env default)"
    docker-machine ls
    docker ps
    # Forward ports between virtual machine and MacOS machine
    ports=(10001 10010 10020 10040)
    for i in "${!ports[@]}"
    do
        VBoxManage controlvm default natpf1 "rule$i,tcp,,${ports[$i]},,${ports[$i]}"
    done

    # Install pyenv and python
    brew install pyenv
    pyenv install $PYTHON_VERSION
    pyenv global $PYTHON_VERSION
    echo 'eval "$(pyenv init -)"' > ~/.bash_profile
    source ~/.bash_profile
    python -m pip install --user --upgrade setuptools wheel
    python -m pip install wheel-inspect
    python -m pip install numpy pandas

    # Install SWIG
    brew install autoconf
    brew install automake
    brew install libtool
    wget https://github.com/swig/swig/archive/refs/tags/v4.0.2.tar.gz
    tar xvfz v4.0.2.tar.gz
    cd swig-4.0.2
    ./autogen.sh
    ./configure
    make
    sudo make install
    cd ..
    rm v4.0.2.tar.gz

    # Install C API
    # brew install nguyentientungduong/tools/griddb-c-client

    # Python Client for MacOS will include C Client
    wget https://github.com/griddb/c_client/archive/v$C_CLIENT_VERSION.tar.gz
    tar xvfz v$C_CLIENT_VERSION.tar.gz
    mkdir griddb-c-client
    mv c_client-$C_CLIENT_VERSION griddb-c-client/$C_CLIENT_VERSION

    # Build C API
    cd griddb-c-client/$C_CLIENT_VERSION
    ./bootstrap.sh
    ./configure
    make
    sudo make install
    rm v$C_CLIENT_VERSION.tar.gz
 }

build_package_macos() {
    source ~/.bash_profile
    export LIBRARY_PATH=$LIBRARY_PATH:./c_client-$C_CLIENT_VERSION/bin/
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:./c_client-$C_CLIENT_VERSION/bin/
    python setup_macos.py bdist_wheel
}

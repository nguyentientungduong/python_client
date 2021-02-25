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
    python setup.py bdist_wheel -p $WHLSUFFIX
}

# Check information rpm and deb package
check_package() {
    local version=$(cat setup.py | grep "version=" | cut -f 2 -d"'")
    local package_path=dist/griddb_python-$version-cp36-cp36m-$WHLSUFFIX.whl
    check_file_exist "$package_path"
    wheel2json "$package_path"
}

# Install whl package
install_client() {
    local version=$(cat setup.py | grep "version=" | cut -f 2 -d"'")
    local package_path=dist/griddb_python-$version-cp36-cp36m-$WHLSUFFIX.whl
    check_file_exist "$package_path"
    python -m pip install "$package_path"
}

# Config password and clustername for griddb server
config_griddb() {
    local username=$1
    local password=$2
    local cluster_name=$3
    su -l gsadm -c "gs_passwd $username -p $password"
    su -l gsadm -c "sed -i 's/\"clusterName\":\"\"/\"clusterName\":\"$cluster_name\"/g' /var/lib/gridstore/conf/gs_cluster.json"
}

# Start and run griddb server
start_griddb() {
    local username=$1
    local password=$2
    local cluster_name=$3
    su -l gsadm -c "gs_startnode -w -u $username/$password"
    su -l gsadm -c "gs_joincluster -c $cluster_name -u $username/$password -w"
}

# Run sample of Java Client
# You can refer to https://github.com/griddb/python_client
run_sample() {
    # Run sample
    local notification_host=$1
    local notification_port=$2
    local cluster_name=$3
    local username=$4
    local password=$5
    echo "list all module installed by pip"
    python -m pip list
    echo "finish list all module installed by pip"
    python --version
    locate griddb_python.py
    python -m site
    python sample/sample1.py $notification_host $notification_port \
       $cluster_name $username $password
}

# Stop GridDB server
stop_griddb() {
    local username=$1
    local password=$2
    su -l gsadm -c "gs_stopcluster -u  $username/$password -w"
    su -l gsadm -c "gs_stopnode -u  $username/$password -w"
}

# Uninstall GridDB package
uninstall_package() {
    python -m pip uninstall -y griddb_python
}

# Prepare env for MacOS
install_packages_macos() {
    brew install pyenv
    pyenv install 3.6.9
    pyenv global 3.6.9
    #touch /root/.bash_profile
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
    brew install griddb/griddb-c-client/griddb-c-client
    brew install docker docker-machine virtualbox
    brew cleanup
    #docker-machine create default
    mkdir -p ~/.docker/machine/cache/
    curl -Lo ~/.docker/machine/cache/boot2docker.iso https://github.com/boot2docker/boot2docker/releases/download/v18.09.1-rc1/boot2docker.iso
    docker-machine create --driver virtualbox --virtualbox-boot2docker-url ~/.docker/machine/cache/boot2docker.iso default
    rm ~/.docker/machine/cache/boot2docker.iso
    eval "$(docker-machine env default)"
}

build_package_macos() {
    source ~/.bash_profile
    python setup.py bdist_wheel
}

# Check information rpm and deb package
check_package_macos() {
    local version=$(cat setup.py | grep "version=" | cut -f 2 -d"'")
    local package_path=dist/griddb_python-$version-cp36-cp36m-macosx_10_15_x86_64.whl
    check_file_exist "$package_path"
    wheel2json "$package_path"
}

# Install whl package
install_client_macos() {
    local version=$(cat setup.py | grep "version=" | cut -f 2 -d"'")
    local package_path=dist/griddb_python-$version-cp36-cp36m-macosx_10_15_x86_64.whl
    check_file_exist "$package_path"
    python -m pip install "$package_path"
}




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

    cd python_client/
    export PYTHON_PATH=`pwd`
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


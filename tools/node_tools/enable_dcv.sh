#!/bin/bash
source /etc/os-release

# https://www.ni-sp.com/support/
# https://www.ni-sp.com/support/how-to-install-nice-dcv-on-redhat-centos-7-x-and-8-x/
# https://www.ni-sp.com/support/how-to-install-nice-dcv-on-ubuntu-18-04/
# https://www.ni-sp.com/nice-dcv-in-containers/
# https://github.com/NISP-GmbH
# https://github.com/NISP-GmbH/Overview-of-NI-SP-Solutions
# https://github.com/NISP-GmbH/DCV-Installer

echo "--- ID = ${ID}"
echo "--- VERSION_ID = ${VERSION_ID}"


generate_password (){
    NEW_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)
    echo ${NEW_PASSWORD} > /tmp/password.user

}

execute_dcv_installer (){
    DCV_INSTALLER="DCV_Installer.sh"
    DCV_INSTALLER_URL="https://raw.githubusercontent.com/NISP-GmbH/DCV-Installer/main/${DCV_INSTALLER}"
    wget -q ${DCV_INSTALLER_URL} && /bin/bash ${DCV_INSTALLER} --without-interaction --dcv_server_install=true --force
}

case ${ID} in
  rocky)
    VERSION_M=$(echo ${VERSION_ID}|cut -d. -f1)
    SERVICE_USER="rocky"
    execute_dcv_installer
    generate_password
    sudo usermod --password $(cat /tmp/password.user | openssl passwd -1 -stdin) ${SERVICE_USER}
    sudo dcv close-session console
    sudo dcv create-session --type console --owner ${SERVICE_USER} console
  ;;

  ubuntu)
    VERSION_M=$(echo ${VERSION_ID}|cut -d. -f1)
    SERVICE_USER="ubuntu"
    execute_dcv_installer
    generate_password
    sudo usermod --password $(cat /tmp/password.user | openssl passwd -1 -stdin) ${SERVICE_USER}
  ;;

  *)
    echo "DCV is not supported"
  ;;

esac

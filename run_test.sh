#!/bin/bash

vagrant halt

echo "Testing the CoprHD + ScaleIO communication/build"
echo "Here are the proxy settings: "
env | grep -i proxy

PROXYCONF_INSTALLED=`vagrant plugin list | grep proxyconf`
# If not installed - install ProxyConf
if [[ -z $PROXYCONF_INSTALLED ]]; then
  echo "Installing vagrant-proxyconf"
  vagrant plugin install vagrant-proxyconf
else
  echo "vagrant-proxyconf installed already"
fi

CACHIER_INSTALLED=`vagrant plugin list | grep cachier`
if [[ -z $CACHIER_INSTALLED ]]; then
  echo "Installing vagrant-cachier"
  vagrant plugin install vagrant-cachier
else
  echo "vagrant-cachier installed already"
fi

# Clean out any coprhd VM instance
vagrant destroy -f coprhd

# Bring up CoprHD, which includes building the latest master branch
vagrant up coprhd

# Now that CoprHD is up and running - check out version tag versus commit tag in git repo - should match
rm ./cookiefile

OUTPUT=`vagrant ssh coprhd -c "cd /tmp/coprhd-controller; git log --pretty=oneline --abbrev-commit -n 1 | awk '{print $1}'"`
COMMIT_TAG=`echo $OUTPUT | awk '{print $1}'`
echo "COMMIT: ${COMMIT_TAG}"

# Login and check the Version
COPRHD_IP=https://192.168.100.11:4443
curl --insecure -G --anyauth $COPRHD_IP/login?using-cookies=true -u 'root:ChangeMe' -c ./cookiefile -v
VERSION=`curl -k $COPRHD_IP/upgrade/target-version -b ./cookiefile`
echo "VERSION is: ${VERSION}"
echo "COMMIT_TAG is: ${COMMIT_TAG}"
if [[ $VERSION == *${COMMIT_TAG}* ]]
then
    echo "VERSION MATCHES GIT TAG"
else
    echo "VERSION MISMATCH: COMMIT_TAG from REPO: ${COMMIT_TAG}, CoprHD Version:${VERSION}"
    exit 1
fi

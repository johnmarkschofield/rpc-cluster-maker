#!/bin/bash

set -e
set -o pipefail
set -u
source cloudenv
set -x

echo "[infrahosts]" > $ANSIBLE_INVENTORY

echo "Create networks..."
nova network-create $MGMT_NETWORK_NAME 10.51.50.0/24
export MGMT_NETWORK_ID=`nova network-list | grep $MGMT_NETWORK_NAME | awk '{print $2}'`
sed -i .bak "s|export MGMT_NETWORK_ID=.*|export MGMT_NETWORK_ID=$MGMT_NETWORK_ID|g" ./cloudenv
rm cloudenv.bak

nova network-create $VMNET_NETWORK_NAME 192.168.20.0/24
export VMNET_NETWORK_ID=`nova network-list | grep $VMNET_NETWORK_NAME | awk '{print $2}'`
sed -i .bak "s|export VMNET_NETWORK_ID=.*|export VMNET_NETWORK_ID=$VMNET_NETWORK_ID|g" ./cloudenv
rm cloudenv.bak



echo "Create instances..."
nova boot \
	--flavor $HOST_FLAVOR \
	--image $BOOTIMAGE \
    --nic net-id=$MGMT_NETWORK_ID \
    --nic net-id=$VMNET_NETWORK_ID \
	--key-name $KEYPAIR_NAME \
	--poll \
	$INFRA1_HOST
export INFRA1_PUBLIC_IP=`nova show $INFRA1_HOST | grep "public network" | grep -oh -E "\b(?:\d{1,3}\.){3}\d{1,3}\b"`
sed -i .bak "s|export INFRA1_PUBLIC_IP=.*|export INFRA1_PUBLIC_IP=$INFRA1_PUBLIC_IP|g" ./cloudenv
rm cloudenv.bak
echo $INFRA1_PUBLIC_IP >> $ANSIBLE_INVENTORY

nova boot \
    --flavor $HOST_FLAVOR \
    --image $BOOTIMAGE \
    --nic net-id=$MGMT_NETWORK_ID \
    --nic net-id=$VMNET_NETWORK_ID \
    --key-name $KEYPAIR_NAME \
    --poll \
    $INFRA2_HOST
export INFRA2_PUBLIC_IP=`nova show $INFRA2_HOST | grep "public network" | grep -oh -E "\b(?:\d{1,3}\.){3}\d{1,3}\b"`
sed -i .bak "s|export INFRA2_PUBLIC_IP=.*|export INFRA2_PUBLIC_IP=$INFRA2_PUBLIC_IP|g" ./cloudenv
rm cloudenv.bak
echo $INFRA2_PUBLIC_IP >> $ANSIBLE_INVENTORY

nova boot \
    --flavor $HOST_FLAVOR \
    --image $BOOTIMAGE \
    --nic net-id=$MGMT_NETWORK_ID \
    --nic net-id=$VMNET_NETWORK_ID \
    --key-name $KEYPAIR_NAME \
    --poll \
    $INFRA3_HOST
export INFRA3_PUBLIC_IP=`nova show $INFRA3_HOST | grep "public network" | grep -oh -E "\b(?:\d{1,3}\.){3}\d{1,3}\b"`
sed -i .bak "s|export INFRA3_PUBLIC_IP=.*|export INFRA3_PUBLIC_IP=$INFRA3_PUBLIC_IP|g" ./cloudenv
rm cloudenv.bak
echo $INFRA3_PUBLIC_IP >> $ANSIBLE_INVENTORY

echo >> $ANSIBLE_INVENTORY
echo "[computehosts]" >> $ANSIBLE_INVENTORY

nova boot \
    --flavor $HOST_FLAVOR \
    --image $BOOTIMAGE \
    --nic net-id=$MGMT_NETWORK_ID \
    --nic net-id=$VMNET_NETWORK_ID \
    --key-name $KEYPAIR_NAME \
    --poll \
    $COMPUTE01_HOST
export COMPUTE01_PUBLIC_IP=`nova show $COMPUTE01_HOST | grep "public network" | grep -oh -E "\b(?:\d{1,3}\.){3}\d{1,3}\b"`
sed -i .bak "s|export COMPUTE01_PUBLIC_IP=.*|export COMPUTE01_PUBLIC_IP=$COMPUTE01_PUBLIC_IP|g" ./cloudenv
rm cloudenv.bak
echo $COMPUTE01_PUBLIC_IP >> $ANSIBLE_INVENTORY

echo >> $ANSIBLE_INVENTORY
echo "[storagehosts]" >> $ANSIBLE_INVENTORY

nova boot \
    --flavor $HOST_FLAVOR \
    --image $BOOTIMAGE \
    --nic net-id=$MGMT_NETWORK_ID \
    --nic net-id=$VMNET_NETWORK_ID \
    --key-name $KEYPAIR_NAME \
    --poll \
    $STORAGE01_HOST
export STORAGE01_PUBLIC_IP=`nova show $STORAGE01_HOST | grep "public network" | grep -oh -E "\b(?:\d{1,3}\.){3}\d{1,3}\b"`
sed -i .bak "s|export STORAGE01_PUBLIC_IP=.*|export STORAGE01_PUBLIC_IP=$STORAGE01_PUBLIC_IP|g" ./cloudenv
rm cloudenv.bak
echo $STORAGE01_PUBLIC_IP >> $ANSIBLE_INVENTORY


echo >> $ANSIBLE_INVENTORY
echo "[logginghosts]" >> $ANSIBLE_INVENTORY

nova boot \
    --flavor $HOST_FLAVOR \
    --image $BOOTIMAGE \
    --nic net-id=$MGMT_NETWORK_ID \
    --nic net-id=$VMNET_NETWORK_ID \
    --key-name $KEYPAIR_NAME \
    --poll \
    $LOGGING1_HOST
export LOGGING1_PUBLIC_IP=`nova show $LOGGING1_HOST | grep "public network" | grep -oh -E "\b(?:\d{1,3}\.){3}\d{1,3}\b"`
sed -i .bak "s|export LOGGING1_PUBLIC_IP=.*|export LOGGING1_PUBLIC_IP=$LOGGING1_PUBLIC_IP|g" ./cloudenv
rm cloudenv.bak
echo $LOGGING1_PUBLIC_IP >> $ANSIBLE_INVENTORY

echo >> $ANSIBLE_INVENTORY
echo "[haproxyhosts]" >> $ANSIBLE_INVENTORY

nova boot \
    --flavor $HOST_FLAVOR \
    --image $BOOTIMAGE \
    --nic net-id=$MGMT_NETWORK_ID \
    --nic net-id=$VMNET_NETWORK_ID \
    --key-name $KEYPAIR_NAME \
    --poll \
    $HAPROXY_HOST
export HAPROXY_PUBLIC_IP=`nova show $HAPROXY_HOST | grep "public network" | grep -oh -E "\b(?:\d{1,3}\.){3}\d{1,3}\b"`
sed -i .bak "s|export HAPROXY_PUBLIC_IP=.*|export HAPROXY_PUBLIC_IP=$HAPROXY_PUBLIC_IP|g" ./cloudenv
rm cloudenv.bak
echo $HAPROXY_PUBLIC_IP >> $ANSIBLE_INVENTORY


echo "Creating volumes..."

nova volume-create $LVM_VOLUME_GB \
    --volume-type $LVM_VOLUME_TYPE \
    --display-name $INFRA1_LVM_VOLUME_NAME
export INFRA1_LVM_VOLUME_ID=`nova volume-show $INFRA1_LVM_VOLUME_NAME | grep  -E '\| id\W*\|' | awk '{print $4}'`
sed -i .bak "s|export INFRA1_LVM_VOLUME_ID=.*|export INFRA1_LVM_VOLUME_ID=$INFRA1_LVM_VOLUME_ID|g" ./cloudenv
rm cloudenv.bak
nova volume-attach $INFRA1_HOST $INFRA1_LVM_VOLUME_ID

nova volume-create $LVM_VOLUME_GB \
    --volume-type $LVM_VOLUME_TYPE \
    --display-name $INFRA2_LVM_VOLUME_NAME
export INFRA2_LVM_VOLUME_ID=`nova volume-show $INFRA2_LVM_VOLUME_NAME | grep  -E '\| id\W*\|' | awk '{print $4}'`
sed -i .bak "s|export INFRA2_LVM_VOLUME_ID=.*|export INFRA2_LVM_VOLUME_ID=$INFRA2_LVM_VOLUME_ID|g" ./cloudenv
rm cloudenv.bak
nova volume-attach $INFRA2_HOST $INFRA2_LVM_VOLUME_ID

nova volume-create $LVM_VOLUME_GB \
    --volume-type $LVM_VOLUME_TYPE \
    --display-name $INFRA3_LVM_VOLUME_NAME
export INFRA3_LVM_VOLUME_ID=`nova volume-show $INFRA3_LVM_VOLUME_NAME | grep  -E '\| id\W*\|' | awk '{print $4}'`
sed -i .bak "s|export INFRA3_LVM_VOLUME_ID=.*|export INFRA3_LVM_VOLUME_ID=$INFRA3_LVM_VOLUME_ID|g" ./cloudenv
rm cloudenv.bak
nova volume-attach $INFRA3_HOST $INFRA3_LVM_VOLUME_ID

nova volume-create $LVM_VOLUME_GB \
    --volume-type $LVM_VOLUME_TYPE \
    --display-name $COMPUTE01_LVM_VOLUME_NAME
export COMPUTE01_LVM_VOLUME_ID=`nova volume-show $COMPUTE01_LVM_VOLUME_NAME | grep  -E '\| id\W*\|' | awk '{print $4}'`
sed -i .bak "s|export COMPUTE01_LVM_VOLUME_ID=.*|export COMPUTE01_LVM_VOLUME_ID=$COMPUTE01_LVM_VOLUME_ID|g" ./cloudenv
rm cloudenv.bak
nova volume-attach $COMPUTE01_HOST $COMPUTE01_LVM_VOLUME_ID

nova volume-create $LVM_VOLUME_GB \
    --volume-type $LVM_VOLUME_TYPE \
    --display-name $STORAGE01_LVM_VOLUME_NAME
export STORAGE01_LVM_VOLUME_ID=`nova volume-show $STORAGE01_LVM_VOLUME_NAME | grep  -E '\| id\W*\|' | awk '{print $4}'`
sed -i .bak "s|export STORAGE01_LVM_VOLUME_ID=.*|export STORAGE01_LVM_VOLUME_ID=$STORAGE01_LVM_VOLUME_ID|g" ./cloudenv
rm cloudenv.bak
nova volume-attach $STORAGE01_HOST $STORAGE01_LVM_VOLUME_ID

nova volume-create $LVM_VOLUME_GB \
    --volume-type $LVM_VOLUME_TYPE \
    --display-name $LOGGING1_LVM_VOLUME_NAME
export LOGGING1_LVM_VOLUME_ID=`nova volume-show $LOGGING1_LVM_VOLUME_NAME | grep  -E '\| id\W*\|' | awk '{print $4}'`
sed -i .bak "s|export LOGGING1_LVM_VOLUME_ID=.*|export LOGGING1_LVM_VOLUME_ID=$LOGGING1_LVM_VOLUME_ID|g" ./cloudenv
rm cloudenv.bak
nova volume-attach $LOGGING1_HOST $LOGGING1_LVM_VOLUME_ID


echo >> $ANSIBLE_INVENTORY
echo "[containerhosts]" >> $ANSIBLE_INVENTORY
echo $INFRA1_PUBLIC_IP >> $ANSIBLE_INVENTORY
echo $INFRA2_PUBLIC_IP >> $ANSIBLE_INVENTORY
echo $INFRA3_PUBLIC_IP >> $ANSIBLE_INVENTORY
echo $STORAGE01_PUBLIC_IP >> $ANSIBLE_INVENTORY
echo $LOGGING1_PUBLIC_IP >> $ANSIBLE_INVENTORY
echo $COMPUTE01_PUBLIC_IP >> $ANSIBLE_INVENTORY

echo >> $ANSIBLE_INVENTORY
echo "[deployhosts]" >> $ANSIBLE_INVENTORY
echo $HAPROXY_PUBLIC_IP >> $ANSIBLE_INVENTORY

echo "Done provisioning."
#!/bin/bash

set -o pipefail
set -u
source cloudenv
set -x


there_are_things_to_delete(){
    if nova list | grep ${CLUSTER_ID} ; then
        return 0
    fi

    if nova volume-list | grep ${CLUSTER_ID} ; then
        return 0
    fi 

    if nova network-list | grep ${CLUSTER_ID} ; then
        return 0
    fi

    return 1
}



while there_are_things_to_delete ; do
    echo "Removing all elements associated with $CLUSTER_ID"

    if nova list | grep $CLUSTER_ID ; then
        echo "Deleting servers..."
        nova delete $INFRA1_HOST
        nova delete $INFRA2_HOST
        nova delete $INFRA3_HOST
        nova delete $COMPUTE01_HOST
        nova delete $STORAGE01_HOST
        nova delete $LOGGING1_HOST
        nova delete $HAPROXY_HOST
        sleep 10
    fi

    if nova volume-list | grep $CLUSTER_ID ; then        
        echo "Deleting volumes..."
        nova volume-delete $INFRA1_LVM_VOLUME_NAME
        nova volume-delete $INFRA2_LVM_VOLUME_NAME
        nova volume-delete $INFRA3_LVM_VOLUME_NAME
        nova volume-delete $COMPUTE01_LVM_VOLUME_NAME
        nova volume-delete $STORAGE01_LVM_VOLUME_NAME
        nova volume-delete $LOGGING1_LVM_VOLUME_NAME
        sleep 10
    fi

    if nova network-list | grep $CLUSTER_ID ; then
        echo "Deleting networks..."
        nova network-delete $MGMT_NETWORK_ID
        nova network-delete $VMNET_NETWORK_ID
    fi

    rm -rf $ANSIBLE_INVENTORY

done

#!/bin/bash

set -e
set -o pipefail
set -u
source cloudenv
set -x

./provision_everything.bash
# ./config_host_network.bash
# ./prepare_for_openstack.bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --forks=7 -i hosts.txt config_host_packages.yml
./wait_for_reboot.bash
ansible-playbook --forks=7 -i hosts.txt configure-hosts.yml

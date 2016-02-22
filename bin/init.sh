#!/bin/bash
#
# This script is invoked by the vagrant provisioner and runs inside the vagrant instance.
# It provisions the initial environment, the runs the primary ansible playbook.
#
# This script can be run at command line:
# $ vagrant ssh
# $ sudo /bin/bash /vagrant/bin/hgv-init.sh
#
echo "

    ________  _________    __
   / ____/ / / / ____/ |  / /
  / /   / /_/ / / __ | | / /
 / /___/ __  / /_/ / | |/ /
 \____/_/ /_/\____/  |___/

"

set -e

echo
echo "Updating YUM sources."
echo
sudo su -c "yum check-update ; true"
echo
echo "Checking/Installing Ansible."
echo
yum -y install epel-release
yum -y install ansible
ansible_version=`rpm -qa 2>&1 | grep ansible | cut -f2 -d'-'`
echo
echo "Ansible installed ($ansible_version)"

ANS_BIN=`which ansible-playbook`

if [[ -z $ANS_BIN ]]
    then
    echo "Whoops, can't find Ansible anywhere. Aborting run."
    echo
    exit
fi

# echo
# echo "Validating Ansible hostfile permissions."
# echo
# chmod 644 /vagrant/provisioning/hosts
#
# # More continuous scroll of the ansible standard output buffer
export PYTHONUNBUFFERED=1
export ANSIBLE_FORCE_COLOR=true
#
# # If user specified ansible extra variables file is provided, pass that in to the provisioning
# if [ -e "/vagrant/hgv_data/config/provisioning/ansible.yml" ] ; then
#     EXTRA="@/vagrant/hgv_data/config/provisioning/ansible.yml"
# fi
$ANS_BIN /vagrant/provisioning/playbook.yml -i'127.0.0.1,' --extra-vars="$EXTRA"

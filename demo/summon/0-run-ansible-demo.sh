#!/bin/bash
export ANSIBLE_DEPRECATION_WARNINGS=false
clear
echo "Here is the contents of secrets.yml:"
cat secrets.yml
echo
echo "An Ansible playbook can access these secrets as environment vars:"
set -x
summon ansible-playbook -i inventory.yml demoPlaybook.yml

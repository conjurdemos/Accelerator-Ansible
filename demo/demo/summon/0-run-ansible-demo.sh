#!/bin/bash
clear
echo "Here is the contents of secrets.yml:"
cat secrets.yml
echo
echo "Here are the secrets Summon retrieves:"
summon ./secrets_echo.sh
echo
echo "An Ansible playbook can access these secrets as environment vars:"
set -x
summon ansible-playbook -i inventory.yml demoPlaybook.yml

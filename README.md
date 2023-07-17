# Accelerator Ansible

## Goals:
- Demonstrate best-practices for Ansible w/ CyberArk Secrets Management.
- Provide templates for provisioning Ansible access to credentials managed by CyberArk.

### Workflow:
![Ansible Workflow](https://github.com/conjurdemos/Accelerator-Ansible/blob/main/Ansible-Workflow.png?raw=true)
<Edited w/ sequencediagram.org>

## Manual Setup
 - A Safe with a MySQL Account must exist
 - The "Conjur Sync" user must be a member of the Safe
 - The MySQL account is synced to Conjur Cloud
 - Edit demo-vars with correct values for all <<YOUR_VALUE_HERE>> tags

## Start Script
 - Checks for all dependencies:
   - Environment variables are set
   - Safe with MySQL Account and "Conjur Sync" user
 - Creates Conjur workload, grants access to delegation/consumsers group for Safe
 - Provisions Ansible container with Conjur workload identity
 - Provisions MySQL server container w/ username/password
 - Execs into Ansible container

## Use-Case 1 - Ansible plugin
 - Playbook retrieves all DB variables from Conjur Cloud with Conjur workload
 - Creates database and loads test data

## Use-Case 2 - Summon
 - Summon retrieves all DB variables from Conjur Cloud with Conjur workload
 - Playbook creates database and loads test data

## Use-Case 3 - Password rotation
 - Admin manually changes MySQL password in Safe account
 - Privilege Cloud syncs changed password to Conjur Cloud 
 - Admin updates MySQL DB with update-remote-root-password.sh script
 - Retry use-cases 1 and/or 2

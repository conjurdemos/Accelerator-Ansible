# Accelerator Ansible

## MVP Goals:
- Demonstrate best-practices for Ansible w/ CyberArk Secrets Management

### Proposed workflow:
![Ansible MVPv1](https://github.com/conjurdemos/Accelerator-Ansible/blob/main/Ansible-MVPv1.png?raw=true)
<Edited w/ sequencediagram.org>

## General steps:
Assumptions:
 - safe exists, conjur sync user added
 - assume delegation/consumers already exists
 - query for name of safe, check if exists & conjur sync is member
 - document manual password change workflow

1. provision a database with access creds
2. fetch the creds
3. perform an action in the database

### Use-Case 1 - "Summon"
1. provision a database with access creds
2. fetch the creds
3. perform an action in the database

### Use-Case 2 - Ansible plugin
1. provision a database with access creds
2. fetch the creds
3. perform an action in the database

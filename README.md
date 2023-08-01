# Accelerator Ansible

## Goals:
- Demonstrate best-practices for Ansible w/ CyberArk Secrets Management.
- Provide example workflows for provisioning Ansible access to credentials managed by CyberArk.

## Prerequisites
 - Admin access to a NON-PRODUCTION Cyberark Identity tenant
 - Admin access to a NON-PRODUCTION CyberArk Privilege Cloud tenant
 - Admin access to a NON-PRODUCTION CyberArk Conjur Cloud tenant
 - A CyberArk Identity service user & oauth2 confidential client with the Privilege Cloud Users and Conjur Admin roles.
 - A Safe in Privilege Cloud with the above service user as member with Access and Account Management permissions, and the 'Conjur Sync' user as member with Access and Workflow permissions.
 - A demo host - a MacOS or Linux VM environment with Docker or Podman installed
 - There is no need to install Ansible or MySQL. The start.sh script will build two containers, one for Ansible OSS and one for the MySQL DB server.
 - Make sure all scripts are executable. Run: chmod -R +x *.sh

## STEP ONE: Manual Setup
 - A Privilege Cloud admin must create a Safe to hold the MySQL DBA account
 - The "Conjur Sync" user must be a member of the Safe
 - The variables set in the file demo-vars.sh drive the demo for your environment.
 - Update demo-vars.sh with correct values:
   - DOCKER - Set to the appropriate command for Docker or Podman.
   - IDENTITY_TENANT_URL - Paste the URL of your CyberArk Identity tenant.
   - PCLOUD_TENANT_URL - Paste the URL of your CyberArk Privilege Cloud tenant.
   - SAFE_NAME
     - Must be the name of an existing safe.
     - Name is case sensitive and should not contain spaces.
     - The CyberArk admin service user must be a member with at least Access and Account Management permissions.
     - 'Conjur Sync' must be a member with Access and Workflow permissions.

Unless you are experimenting or debugging, do not change anything else in the demo-vars.sh file. Doing so could easily break the demo.

## STEP TWO: Start Script

### NOTE: The start.sh script requires a CyberArk Identity Oauth2 confidential client service user to perform automated admin operations in Privilege Cloud and Conjur Cloud. The service user must be granted Privilege Cloud User and Conjur Cloud Admin roles. The start.sh script will prompt for the name of the user and its password. It will not persist those values.

 - Run the start script with the command: ./start.sh
 - Provide the Admin service users name and password when prompted
 - The script performs the following:
   - Checks all dependencies are met:
     - All environment variables are set
     - A Safe with SAFE_NAME exists and has "Conjur Sync" as a member
   - Creates MYSQL_ACCOUNT_NAME in SAFE_NAME with property values from MYSQL_* vars as described above
   - Creates Conjur workload, grants SAFE_NAME delegation/consumers group role
   - Provisions Ansible container with Conjur workload identity
   - Provisions MySQL server container w/ root username/password
   - Execs into Ansible container

## Use-Case 1 - Ansible plugin
 - From the shell prompt in the Ansible container:
   - cd to the plugin subdirectory
   - Run the demo with the command: ./0-run-ansible-demo.sh
   - Playbook uses Conjur workload to retrieve DB variables from Conjur Cloud 
   - Playbook creates database and loads test data
   - Use this command sequence to view the database that Ansible created:
     - mysql -h \<mysql-server-address\> -P \<mysql-server-port\> -u root -p \
       \<enter current MySQL remote root password at prompt\>
     - Note that address, port and password values can be cut/pasted from Ansible output. Specifying the port is optional if the default 3306 is used.
     - At the mysql prompt enter these commands:
       - show databases;
       - use testdb; (or whatever name you specified for the database in demo-vars.sh)
       - select * from test;

## Use-Case 2 - Summon
 - From the shell prompt in the Ansible container:
   - cd to the plugin subdirectory
   - Run the demo with the command: ./0-run-ansible-demo.sh
   - Summon uses Conjur workload to retrieve DB variables from Conjur Cloud as environment variables, then runs playbook
   - Playbook uses env vars to create database and loads test data
   - Use this command sequence to view the database that Ansible created:
     - mysql -h \<mysql-server-address\> -P \<mysql-server-port\> -u root -p \
       \<enter current MySQL remote root password at prompt\>
     - Note that address, port and password values can be cut/pasted from Ansible output. Specifying the port is optional if the default 3306 is used.
     - At the mysql prompt enter these commands:
       - show databases;
       - use testdb; (or whatever name you specified for the database in demo-vars.sh)
       - select * from test;

## Use-Case 3 - Password rotation
 - Admin manually changes MySQL DBA password in Safe account
 - After 1 minute or less Privilege Cloud syncs changed password to Conjur Cloud
 - Exit Ansible container and run update-remote-root-password.sh script to update MySQL DB
 - Retry use-cases 1 and/or 2

### Sequence Diagram:
![Ansible Workflow](https://github.com/conjurdemos/Accelerator-Ansible/blob/main/Ansible-Workflow.png?raw=true)

## Description of Demo
This accelerator simulates a real-world end-to-end workflow where an Ansible playbook uses DBA credentials that are retrieved from Conjur to provision a test database in the MySQL server.
A Privilege cloud admin must manually create a Safe and add the Conjur Sync user as a member. The Safe will hold the MySQL DBA credentials. The Setup script builds and configures the Ansible and MySQL containers. It exits after execing into the Ansible container where there are two demo subdirectories:
 - plugin - which shows how to use the Ansible Galaxy plugin for Conjur to retrieve the MySQL DBA creds from an Ansible demo playbook.
 - summon - which shows how to use CyberArk Summon (https://cyberark.github.io/summon/) to retrieve the MySQL DBA creds as environment variables accessible to an Ansible playbook.

The Privilege Cloud admin can use the PVWA UI to change the MySQL DBA password and once it is synced to Conjur, a script can update the root password in the MySQL container. The plugin & Summon demos can be rerun to show how Ansible uses the changed password.

## Description of Repo Contents
 - README.md - this file.
 - Ansible-Workflow.png - a sequence diagram graphic (see below).
 - Ansible-seq-diagram.txt - source text for the sequence diagram.
 - build - build directory for the Ansible container.
 - ccloud-cli.sh - a limited admin CLI for Conjur Cloud.
 - demo - demo directory copied into Ansible container.
 - demo-vars.sh - variables that drive demo parameters.
 - exec-into-ansible.sh - script that runs an interactive bash shell in the Ansible container.
 - exec-into-db-server.sh - script that runs an interactive bash shell in the MySQL container.
 - mysql - build directory for the MySQL container.
 - pcloud-cli.sh - a limited admin CLI for Privilege Cloud.
 - start.sh - script to build and run the demo containers.
 - stop.sh - script to stop and remove the demo containers.
 - templates - directory holding file templates for Conjur policies and Summon.
 - update-remote-root-password.sh - script to update the MySQL remote root login password after it has been changed in Privilege Cloud.


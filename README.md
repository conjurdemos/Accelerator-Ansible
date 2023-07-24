# Accelerator Ansible

## Goals:
- Demonstrate best-practices for Ansible w/ CyberArk Secrets Management.
- Provide example workflows for provisioning Ansible access to credentials managed by CyberArk.

## Description:
This accelerator simulates a real-world end-to-end workflow where an Ansible playbook uses DBA credentials that are retrieved from Conjur to provision a test database in MySQL. The accelerator assumes admin access to Privilege Cloud and Conjur Cloud tenants.
There are two containers that are created for the demo:
 - one for Ansible OSS and
 - one for the MySQL DB server.
A Privilege cloud admin must manually create a Safe and add the Conjur Sync user as a member. The Safe will hold the MySQL DBA credentials. The Setup script builds and configures the Ansible and MySQL containers. It exits after execing into the Ansible container where there are two demo subdirectories:
 - plugin - which shows how to use the Ansible Galaxy plugin for Conjur to retrieve the MySQL DBA creds from an Ansible demo playbook.
 - summon - which shows how to use CyberArk Summon (https://cyberark.github.io/summon/) to retrieve the MySQL DBA creds as environment variables accessible to an Ansible playbook.

The Privilege Cloud admin can use the PVWA UI to change the MySQL DBA password and once it is synced to Conjur, a script can update the root password in the MySQL container. The plugin & Summon demos can be rerun to show how Ansible uses the changed password.

## Description of Contents
 - README.md - this file.
 - Ansible-Workflow.png - a sequence diagram graphic (see below).
 - Ansible-seq-diagram.txt - source test for the sequence diagram.
 - build - build directory for the Ansible container.
 - ccloud-cli.sh - a limited admin CLI for Conjur Cloud.
 - demo - demo directory copied into Ansible container.
 - demo-vars.sh - variables that drive demo parameters.
 - exec-into-ansible.sh - script that runs an interactive bash shell in the Ansible container.
 - exec-into-db-server.sh - script that runs an interactive bash shell in the MySQL container.
 - mysql - build directory for the MySQL container.
 - pcloud-cli.sh - a limited admin CLI for Privilege Cloud.
 - start - script to build and run the demo containers.
 - stop - script to stop and remove the demo containers.
 - templates - directory holding file templates for Conjur policies and Summon.
 - update-remote-root-password.sh - script to update the MySQL remote root login password after it has been changed in Privilege Cloud.

## STEP ONE: Manual Setup
 - A Privilege Cloud admin must create a Safe to hold the MySQL DBA account
 - The "Conjur Sync" user must be a member of the Safe
 - The variables set in the file demo-vars.sh drive the demo for your environment.
 - Update demo-vars.sh with correct values:
   - DOCKER - Set to the appropriate command for Docker or Podman.
   - DOCKER_HOSTNAME - This is the DNS resolveable name or IP address for the host running the demo. It is how Ansible connects to the MySQL container.
   - IDENTITY_TENANT_ID - This value is three lower-case letters and four numbers, and is the first value in the URL for your CyberArk Identity tenant. It has the form (for example): https://abc1234.id.cyberark.cloud
   - CYBERARK_SUBDOMAIN_NAME - This value is likely your company or organization name, and is the first value in the Privilege Cloud and Conjur Cloud URLs. It has the form (for example): https://acmecorp.cyberark.cloud
   - SAFE_NAME - This value must be the name of the MySQL DBA safe created manually.
   - MYSQL_ACCOUNT_NAME - The start script will use this name for the MySQL DBA account.
   - MYSQL_SERVER_ADDRESS - This must be the same value as DOCKER_HOSTNAME. It should be the DNS name or IP address of your Docker host where the MySQL container will run.
   - MYSQL_SERVER_PORT - The default port for MySQL is 3306. You only need to change this if there is another process using that port.
   - MYSQL_INITIAL_ROOT_PASSWORD - This will be the initial password for local and remote MySQL root users. It will not change for the local root user (i.e. root login from within in the MySQL container). The remote root login password is what Ansible uses to access MySQL. It can be updated using the update-remote-root-password.sh script. This effects password rotation in the MySQL server.
   - MYSQL_DB_NAME - This is the name of the test database that Ansible will create. You can change it, or not.
   - WORKLOAD_ID - This is the name of the Conjur host identity that will be used by the Ansible plugin and Summon to retrieve the MySQL DBA credentials from Conjur. You can change it, or not.

Unless you are experimenting, do not change anything else in the demo-vars.sh file. Doing so could easily break the demo.

## STEP TWO: Start Script

### NOTE: The start script requires a CyberArk Identity Oauth2 confidential client service user to perform automated admin operations in Privilege Cloud and Conjur Cloud. The service user must be granted Privilege Cloud Admin and Conjur Cloud Admin roles. The start script will prompt for the name of the user and its password. It will not persist those values.

 - Run the start script with the command: ./start
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
     - Note that values in angle brackets can be cut/pasted from Ansible output
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
     - Note that values in angle brackets can be cut/pasted from Ansible output
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

# Edit this file substituting correct values for '<<YOUR_VALUE_HERE>>'

##################################################
# Local container management

# Docker command
export DOCKER="docker"
#export DOCKER="sudo docker"

# for RHEL hosts
#export DOCKER="podman"

##################################################
# CyberArk tenant values

# Your CyberArk tenant subdomain name
#    https://your-subdomain.cyberark.cloud
# this value ^^^^^^^^^^^^^^
export CYBERARK_SUBDOMAIN_NAME='<<YOUR_VALUE_HERE>>'

##################################################
# Demo parameters

# Safe to contain MySQL account - must already exist
# and be synced to Conjur
export SAFE_NAME='<<YOUR_VALUE_HERE>>'

###########################################################
# THERE SHOULD BE NO NEED TO CHANGE ANYTHING BELOW THIS LINE.
# ALL VALUES BELOW ARE DEFAULTS, PRESET, DERIVED FROM ABOVE
# OR PROMPTED FOR.
###########################################################

# Name of MySQL account script will create in SAFE_NAME
export MYSQL_ACCOUNT_NAME=Ansible-DBA-MySQL

# DNS name or IP address of MySQL DB container
export MYSQL_SERVER_ADDRESS=$(hostname)

# MySQL default port is 3306
export MYSQL_SERVER_PORT=3306
export MYSQL_INITIAL_ROOT_PASSWORD=In1t1alR00tPa55w0rd

# name of a database for Ansible to create in MySQL server
export MYSQL_DB_NAME=testdb

# Name of Conjur workload identity to be created.
# Ansible will use it to retrieve secrets managed in
# the specified Safe and Account.
export WORKLOAD_ID=ansible-xlr8r


###########################################################
# Ansible container
export DEMO_IMAGE=ansible-xlr8r
export DEMO_CONTAINER=ansible-xlr8r

###########################################################
# Database container
export MYSQL_IMAGE=mysql-5.7:ansible
export MYSQL_SERVER=mysql-xlr8r
export MYSQL_LOGIN_HOST_ID=data/vault/$SAFE_NAME/$MYSQL_ACCOUNT_NAME/address
export MYSQL_LOGIN_PORT_ID=data/vault/$SAFE_NAME/$MYSQL_ACCOUNT_NAME/Port
export MYSQL_LOGIN_USER_ID=data/vault/$SAFE_NAME/$MYSQL_ACCOUNT_NAME/username
export MYSQL_PASSWORD_ID=data/vault/$SAFE_NAME/$MYSQL_ACCOUNT_NAME/password

# Prompt for admin user name if not already set
if [[ "$CYBERARK_ADMIN_USER" == "" ]]; then
  clear
  echo "A CyberArk admin user is needed for demo setup & initialization."
  echo "The admin user must be a Service user & Oauth2 confidential client" 
  echo "in CyberArk Identity and must be granted the Conjur Admin role"
  echo "and minimally the Privilege Cloud Safe Managers Basic role."
  echo
  echo -n "Please enter the name of the service user: "
  read admin_user
  export CYBERARK_ADMIN_USER=$admin_user
fi

# Prompt for admin password if not already set
if [[ "$CYBERARK_ADMIN_PWD" == "" ]]; then
  echo -n "Please enter password for $CYBERARK_ADMIN_USER: "
  unset password
  while IFS= read -r -s -n1 pass; do
    if [[ -z $pass ]]; then
       echo
       break
    else
       echo -n '*'
       password+=$pass
    fi
  done
  export CYBERARK_ADMIN_PWD=$password
fi

###########################################################
export IDENTITY_TENANT_URL=https://$CYBERARK_SUBDOMAIN_NAME.cyberark.cloud/api/idadmin

export CONJUR_CLOUD_URL=https://$CYBERARK_SUBDOMAIN_NAME.secretsmgr.cyberark.cloud/api
export CONJUR_AUTHN_LOGIN=data/$WORKLOAD_ID
export CONJUR_ADMIN_USER=$CYBERARK_ADMIN_USER
export CONJUR_ADMIN_PWD=$CYBERARK_ADMIN_PWD

export PCLOUD_URL=https://$CYBERARK_SUBDOMAIN_NAME.privilegecloud.cyberark.cloud/PasswordVault/api
export PCLOUD_ADMIN_USER=$CYBERARK_ADMIN_USER
export PCLOUD_ADMIN_PWD=$CYBERARK_ADMIN_PWD

# make sure all scripts are executable
chmod -R +x *.sh

##########################################################
# END

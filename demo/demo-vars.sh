#------------------------------------------------
# add 'sudo' as needed
export DOCKER="docker"
#------------------------------------------------
# FQDN of host running demo
export DOCKER_HOSTNAME=conjur-master-mac
#------------------------------------------------
# ID of your CyberArk ISPSS tenant, e.g. xyz1234
export IDENTITY_TENANT_ID=aao4987
#------------------------------------------------
# Subdomain name for CyberArk tenant
export CYBERARK_SUBDOMAIN_NAME=cybr-secrets
#------------------------------------------------
# Conjur host identity name to be created.
# Ansible will use it to retrieve secrets.
export CONJUR_AUTHN_LOGIN=data/e2etest

###########################################################
# NO NEED TO CHANGE ANYTHING BELOW THIS LINE
###########################################################
export CONJUR_CLOUD_URL=https://$CYBERARK_SUBDOMAIN_NAME.secretsmgr.cyberark.cloud/api

# Prompt for admin user name if not already set
if [[ "$CONJUR_ADMIN_USER" == "" ]]; then
  clear
  echo "A Conjur admin user is needed for demo setup & initialization."
  echo "The admin user must be a Service user & Oauth2 confidential client" 
  echo "in CyberArk Identity and must be granted the Conjur Admin role."
  echo
  echo -n "Please enter the name of the Conjur admin user: "
  read admin_user
  export CONJUR_ADMIN_USER=$admin_user
fi

# Prompt for admin password if not already set
if [[ "$CONJUR_ADMIN_PWD" == "" ]]; then
  echo -n "Please enter password for $CONJUR_ADMIN_USER: "
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
  export CONJUR_ADMIN_PWD=$password
fi

###########################################################
# Ansible container
###########################################################
export DEMO_IMAGE=ansible-xlr8r
export DEMO_CONTAINER=ansible-xlr8r

###########################################################
# Database container
###########################################################
export MYSQL_IMAGE=mysql-5.7.32:ansible
export MYSQL_SERVER=mysql-xlr8r
export MYSQL_ROOT_PASSWORD=Cyberark1
export MYSQL_LOGIN_HOST=$DOCKER_HOSTNAME
export MYSQL_LOGIN_PORT=3307
export MYSQL_DB_NAME=testdb
export MYSQL_LOGIN_USER=root
export MYSQL_ROOT_PASSWORD_ID=data/vault/End2EndFlowsTest/E2E-SSH/password
###########################################################
# END

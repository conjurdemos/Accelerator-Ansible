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
# Conjur cloud subdomain name in tenant
export CONJUR_SUBDOMAIN_NAME=cybr-secrets
#------------------------------------------------
# Conjur host identity name to be created.
# Ansible will use it to retrieve secrets.
export CONJUR_AUTHN_LOGIN=data/e2etest
#------------------------------------------------
# Conjur admin user for demo setup & initialization.
# Must be a Service user & Oauth2 confidential client in ISPSS.
# Must be granted Conjur Admin role.
#export CONJUR_ADMIN_USER=<oauth2-confidential-client-name>
export CONJUR_ADMIN_USER=jody_bot@cyberark.cloud.3357

###########################################################
# NO NEED TO CHANGE ANYTHING BELOW THIS LINE
###########################################################
export CONJUR_CLOUD_URL=https://$CONJUR_SUBDOMAIN_NAME.secretsmgr.cyberark.cloud/api

# Prompt for admin password if not already set
if [[ "$CONJUR_ADMIN_PWD" == "" ]]; then
  echo "Please enter password for $CONJUR_ADMIN_USER: "
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
export MYSQL_IMAGE=mysql:5.7.32
export MYSQL_SERVER=mysql-xlr8r
export MYSQL_ROOT_PASSWORD=Cyberark1
export MYSQL_URL=$DOCKER_HOSTNAME
export MYSQL_PORT=3307
export MYSQL_DBNAME=petclinic
export MYSQL_USERNAME=dbuser1
export MYSQL_USER_PWD=mysqlpwd1%
###########################################################
# END

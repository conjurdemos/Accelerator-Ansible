#!/bin/bash
source ./demo-vars.sh

if [[ "$($DOCKER version | grep Version)" == "" ]]; then
  echo $DOCKER "does not seem to be installed."
  echo "Check the DOCKER variable in demo-vars.sh"
  exit -1
fi

main() {
  if [[ "$($DOCKER ps | grep $DEMO_CONTAINER)" != "" ]]; then
    echo "Stopping and removing demo container..."
    $DOCKER stop $DEMO_CONTAINER && $DOCKER rm $DEMO_CONTAINER
    $DOCKER stop $MYSQL_SERVER && $DOCKER rm $MYSQL_SERVER
  fi
  verify_env_vars
  verify_vault_setup
  create_mysql_account
  load_policy
  generate_identity_files
  build_image
  start_container
  initialize_demo
  # Intialize DB
  export MYSQL_ROOT_PASSWORD=$MYSQL_INITIAL_ROOT_PASSWORD
  export MYSQL_LOGIN_PORT=$MYSQL_SERVER_PORT
  cd mysql
    ./1-mysql-server-start.sh
  cd ..
  $DOCKER exec -it $DEMO_CONTAINER bash
}

##############################
function verify_env_vars() {
  all_deps_good=true

  if [[ "$IDENTITY_TENANT_URL" == '<<YOUR_VALUE_HERE>>' ]]; then
    echo "Env var IDENTITY_TENANT_URL must be set to a proper value in demo-vars.sh."
    all_deps_good=false
  fi
  if [[ "$PCLOUD_TENANT_URL" == '<<YOUR_VALUE_HERE>>' ]]; then
    echo "Env var PCLOUD_TENANT_URL must be set to a proper value in demo-vars.sh."
    all_deps_good=false
  fi
  if [[ "$SAFE_NAME" == "<<YOUR_VALUE_HERE>>" ]]; then
    echo "Env var SAFE_NAME must be set to a proper value in demo-vars.sh."
    all_deps_good=false
  fi
  if [[ "$MYSQL_ACCOUNT_NAME" == "<<YOUR_VALUE_HERE>>" ]]; then
    echo "Env var MYSQL_ACCOUNT_NAME must be set to a proper value in demo-vars.sh."
    all_deps_good=false
  fi
  if [[ "$WORKLOAD_ID" == "<<YOUR_VALUE_HERE>>" ]]; then
    echo "Env var WORKLOAD_ID must be set to a proper value in demo-vars.sh."
    all_deps_good=false
  fi

  if $all_deps_good; then
    if [[ $(./pcloud-cli.sh get_auth_token) == null ]]; then
      echo "Invalid user name or password for $PCLOUD_ADMIN_USER."
      exit -1
    fi
    echo "Verified all env vars are set."
  else
    echo "Please address above issues and retry."
    exit -1
  fi 
}


##############################
function verify_vault_setup() {

# Safe must already exist and be setup to sync to Conjur. MySQL account will be added.
# Steps below verify
# - Safe named $SAFE_NAME exists
# - Safe has 'Conjur Sync' as a member
# - Safe has the admin user $PCLOUD_ADMIN_USER as a member

  all_deps_good=true

  echo "Verifying safe $SAFE_NAME exists..."
  if [[ "$(./pcloud-cli.sh safe_get $SAFE_NAME)" == "" ]]; then
    echo "Safe $SAFE_NAME not found. Make sure $PCLOUD_ADMIN_USER is a member with full permissions."
    all_deps_good=false
  fi

  if $all_deps_good; then
    echo "Verifying safe $SAFE_NAME contains member $PCLOUD_ADMIN_USER..."
    if [[ "$(./pcloud-cli.sh safe_member $SAFE_NAME $PCLOUD_ADMIN_USER)" == "" ]]; then
      echo "Member $PCLOUD_ADMIN_USER not found in Safe $SAFE_NAME."
      all_deps_good=false
    fi
  fi

  if $all_deps_good; then
    echo "Verifying safe $SAFE_NAME contains member 'Conjur Sync'..."
    if [[ "$(./pcloud-cli.sh safe_member $SAFE_NAME 'Conjur Sync')" == "" ]]; then
      echo "Member 'Conjur Sync' not found in Safe $SAFE_NAME."
      all_deps_good=false
    fi
  fi

  if $all_deps_good; then
    echo "Verified all vault dependencies are met."
  else
    echo "Please address above issues and retry."
    exit -1
  fi 
}

##############################
function create_mysql_account() {
  echo "Creating MySQL account with these parameters:"
  echo "       Safe name: $SAFE_NAME"
  echo "    Account name: $MYSQL_ACCOUNT_NAME"
  echo "  Server address: $MYSQL_SERVER_ADDRESS"
  echo "     Server port: $MYSQL_SERVER_PORT"
  echo "        Username: root"
  echo "        Password: $MYSQL_INITIAL_ROOT_PASSWORD"
  echo "   Database name: None - this account is for the root user."

  ./pcloud-cli.sh account_set_mysql 	"$SAFE_NAME" 		\
					"$MYSQL_ACCOUNT_NAME" 	\
					"$MYSQL_SERVER_ADDRESS" \
					"$MYSQL_SERVER_PORT" 	\
					"mysql" 		\
					"root" 			\
					"$MYSQL_INITIAL_ROOT_PASSWORD"
  if [[ $? != 0 ]]; then
    exit -1
  fi
}

##############################
load_policy() {
  # Pre-load delegation-consumers policy for safe - avoids waiting for syncing
  cat templates/delegation-consumers.template	\
  | sed -e "s#{{ SAFE_NAME }}#$SAFE_NAME#g"	\
  > $SAFE_NAME-delegation-consumers-policy.yml
  ./ccloud-cli.sh append data ./$SAFE_NAME-delegation-consumers-policy.yml
  echo

  cat templates/ansible-policy.template		\
  | sed -e "s#{{ WORKLOAD_ID }}#$WORKLOAD_ID#g" \
  | sed -e "s#{{ SAFE_NAME }}#$SAFE_NAME#g"	\
  > ansible-policy.yml
  ./ccloud-cli.sh append data ./ansible-policy.yml
  echo
}

##############################
generate_identity_files() {
  CONJUR_AUTHN_API_KEY=$(./ccloud-cli.sh rotate $CONJUR_AUTHN_LOGIN)

  # create configuration and identity files (AKA conjurize the host)
  echo "Generating identity file..."
  cat <<IDENTITY_EOF > conjur.identity
machine $CONJUR_CLOUD_URL/authn
  login host/$CONJUR_AUTHN_LOGIN
  password $CONJUR_AUTHN_API_KEY
IDENTITY_EOF

  echo "Generating host configuration file..."
  cat <<CONF_EOF > conjur.conf
---
appliance_url: $CONJUR_CLOUD_URL
account: conjur
netrc_path: "/etc/conjur.identity"
cert_file: ""
CONF_EOF
}

##############################
build_image() {
  if [[ "$($DOCKER images -q $DEMO_IMAGE)" == "" ]]; then
    cd build
      ./build.sh
    cd .. 
  fi
}

##############################
start_container() {
    $DOCKER run -d \
    --name $DEMO_CONTAINER \
    -e "MYSQL_DB_NAME=$MYSQL_DB_NAME" \
    -e "MYSQL_LOGIN_HOST_ID=$MYSQL_LOGIN_HOST_ID" \
    -e "MYSQL_LOGIN_PORT_ID=$MYSQL_LOGIN_PORT_ID" \
    -e "MYSQL_LOGIN_USER_ID=$MYSQL_LOGIN_USER_ID" \
    -e "MYSQL_PASSWORD_ID=$MYSQL_PASSWORD_ID" \
    -e "TERM=xterm" \
    --restart always \
    --entrypoint "sh" \
    $DEMO_IMAGE \
    -c "sleep infinity"
}

##############################
initialize_demo() {
  # copy conjur.* files to ansible container
  $DOCKER cp ./conjur.conf $DEMO_CONTAINER:/etc
  $DOCKER cp ./conjur.identity $DEMO_CONTAINER:/etc
  $DOCKER exec $DEMO_CONTAINER chmod 400 /etc/conjur.identity
  rm ./conjur*

  # instantiate Summon secrets.yml file
  create_summon_secrets_yml

  # copy demo directory hierarchy to ansible container
  $DOCKER cp ./demo/. $DEMO_CONTAINER:/demo/
}

##############################
create_summon_secrets_yml() {
  cat templates/secrets.template				\
  | sed -e "s#{{ MYSQL_LOGIN_HOST_ID }}#$MYSQL_LOGIN_HOST_ID#g"	\
  | sed -e "s#{{ MYSQL_LOGIN_PORT_ID }}#$MYSQL_LOGIN_PORT_ID#g"	\
  | sed -e "s#{{ MYSQL_LOGIN_USER_ID }}#$MYSQL_LOGIN_USER_ID#g"	\
  | sed -e "s#{{ MYSQL_PASSWORD_ID }}#$MYSQL_PASSWORD_ID#g"	\
  > ./demo/summon/secrets.yml
}

main $@

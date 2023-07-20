#!/bin/bash

####################################################
# pcloud-cli.sh - a bash script CLI for Privilege Cloud
####################################################

# use 'curl -v' and 'set -x' for verbose debugging 
export CURL="curl -s"
util_defaults="set -u"

showUsage() {
  echo "Usage:"
  echo "      $0 get_auth_token"
  echo "      $0 safes_list"
  echo "      $0 safe_get <safe-name>"
  echo "      $0 safe_member_get <safe-name> <member-name>"
  echo "      $0 account_get <safe-name> <account-name>"
  echo "      $0 account_set_mysql <safe-name> <account-name> <server-address> <server-port> <database-name> <username> <password>"
  exit -1
}

main() {
  checkDependencies

  case $1 in
    get_auth_token)
	command=$1
  	pcloud_authenticate
	echo $jwToken
	exit
	;;
    safes_list)
	command=$1
	;;
    safe_get)
	if [[ $# != 2 ]]; then
	  echo "Incorrect number of arguments."
	  showUsage
	fi
	command=$1
	safeName=$(urlify "$2")
	;;
    safe_member_get)
	if [[ $# != 3 ]]; then
	  echo "Incorrect number of arguments."
	  showUsage
	fi
	command=$1
	safeName=$(urlify "$2")
	memberName=$(urlify "$3")
	;;
    account_get)
	if [[ $# != 3 ]]; then
	  echo "Incorrect number of arguments."
	  showUsage
	fi
	command=$1
	safeName=$(urlify "$2")
	accountName=$(urlify "$3")
	;;
    account_set_mysql)
	if [[ $# != 8 ]]; then
	  echo "Incorrect number of arguments."
	  showUsage
	fi
	command=$1
	safeName=$(urlify "$2")
	accountName=$(urlify "$3")
	dbAddress=$(urlify "$4")
	dbPort=$(urlify "$5")
	dbName=$(urlify "$6")
	dbUsername=$(urlify "$7")
	dbPassword=$(urlify "$8")
	;;
    *)
	echo "Unrecognized command."
	showUsage
	;;
  esac

  pcloud_authenticate	# sets global variable authHeader

  case $command in
    safes_list)
	safes_list
	;;
    safe_get)
	safe_get "$safeName"
	;;
    safe_member_get)
	safe_member_get "$safeName" "$memberName"
	;;
    account_get)
	account_get "$safeName" "$accountName"
	;;
    account_set_mysql)
	account_set_mysql	"$safeName"	\
        			"$accountName"	\
	        		"$dbAddress"	\
       	 			"$dbPort"	\
      		 		"$dbName"	\
        			"$dbUsername"	\
        			"$dbPassword"
	;;
    *)
	showUsage
	;;
  esac
}

#####################################
# sets the global authorization header used in api calls for other methods
function pcloud_authenticate() {
  $util_defaults
  jwToken=$($CURL 					\
        -X POST \
        https://$IDENTITY_TENANT_ID.id.cyberark.cloud/oauth2/platformtoken \
        -H "Content-Type: application/x-www-form-urlencoded"      	\
        --data-urlencode "grant_type"="client_credentials"              \
        --data-urlencode "client_id"="$PCLOUD_ADMIN_USER"               \
        --data-urlencode "client_secret"="$PCLOUD_ADMIN_PWD"		\
	| jq -r .access_token)
  authHeader="Authorization: Bearer $jwToken"
}

#####################################
function safes_list() {
  $util_defaults
  $CURL 				\
	-X GET				\
	-H "$authHeader"		\
	"${PCLOUD_URL}/Safes"
}

#####################################
function safe_get() {
  $util_defaults
  printf -v query '.value[] | select(.safeName=="%s")' $safeName
  echo $(safes_list) | jq "$query"
}

#####################################
function safe_member_get() {
  $util_defaults
  $CURL 				\
	-X GET				\
	-H "$authHeader"		\
	"${PCLOUD_URL}/Safes/${safeName}/members/${memberName}/" | jq .
}

#####################################
function account_get {
  $util_defaults

# search example. but you cant search on account name
#Accounts?limit=1&searchType=StartsWith&search={{ (instance_username + ' ' + instance_ip) | urlencode }}"

  filter=$(urlify "filter=safeName eq ${safeName}")
  printf -v query '.value[] | select(.name=="%s")' $accountName
  $CURL 				\
	-X GET				\
	-H "$authHeader"		\
	"${PCLOUD_URL}/Accounts?$filter" \
	| jq "$query"
}

#####################################
function account_set_mysql {
  $util_defaults

  retCode=$($CURL 					\
	--write-out '%{http_code}'			\
	--output /dev/ull				\
	-X POST						\
        -H 'Content-Type: application/json'		\
	-H "$authHeader"				\
	"${PCLOUD_URL}/Accounts"			\
	-d		"{				\
			  \"platformId\": \"MySQL\",	\
			  \"safeName\": \"$safeName\",	\
			  \"name\": \"$accountName\",	\
			  \"address\": \"$dbAddress\",	\
			  \"platformAccountProperties\": {			\
			    \"Port\": \"$dbPort\",				\
			    \"Database\": \"$dbName\"				\
			  },							\
			  \"userName\": \"$dbUsername\",			\
			  \"secret\": \"$dbPassword\",				\
			  \"secretType\": \"password\",				\
			  \"secretManagement\": {				\
			    \"automaticManagementEnabled\": false,		\
			    \"manualManagementReason\": \"Created for demo\"	\
			  }							\
			}"
	)

  case $retCode in
    201)
        echo "Account created."
       ;;
    409)
        echo "Account already exists. Please confirm values in vault are correct."
        ;;
    403)
        echo "$0:account_set_mysql()"
	echo "  Unable to create account $accountName in safe $safeName."
	echo "  Check user $PCLOUD_ADMIN_USER is a member of the safe and has sufficient permissions."
        exit -1
        ;;
    *)
        echo "$0:account_set_mysql: Unknown return code: $retCode"
        exit -1
        ;;
  esac
}

#####################################
# URLIFY - url encodes input string
# in: $1 - string to encode
# out: encoded string on stdout
function urlify() {
        local str=$1; shift
        str=$(echo $str | sed 's= =%20=g')
        str=$(echo $str | sed 's=/=%2F=g')
        str=$(echo $str | sed 's=:=%3A=g')
        str=$(echo $str | sed 's=+=%2B=g')
        str=$(echo $str | sed 's=&=%26=g')
        str=$(echo $str | sed 's=@=%40=g')
        echo $str
}

#####################################
# verifies jq installed & required environment variables are set
function checkDependencies() {
  all_env_set=true
  if [[ "$(which jq)" == "" ]]; then
    echo
    echo "The JSON query utility jq is required. Please install jq."
    all_env_set=false
  fi
  if [[ "$IDENTITY_TENANT_ID" == "" ]]; then
    echo
    echo "  IDENTITY_TENANT_ID must be set - e.g. 'xyz1234'"
    all_env_set=false
  fi
  if [[ "$PCLOUD_URL" == "" ]]; then
    echo
    echo "  PCLOUD_URL must be set - e.g. 'https://my-secrets.privilegecloud.cyberark.cloud/api'"
    all_env_set=false
  fi
  if [[ "$PCLOUD_ADMIN_USER" == "" ]]; then
    echo
    echo "  PCLOUD_ADMIN_USER must be set - e.g. foo_bar@cyberark.cloud.7890"
    echo "    This MUST be a Service User and Oauth confidential client."
    echo "    This script will not work for human user identities."
    all_env_set=false
  fi
  if [[ "$PCLOUD_ADMIN_PWD" == "" ]]; then
    echo
    echo "  PCLOUD_ADMIN_PWD must be set to the $PCLOUD_ADMIN_USER password."
    all_env_set=false
  fi
  if ! $all_env_set; then
    echo
    exit -1
  fi
}

main "$@"

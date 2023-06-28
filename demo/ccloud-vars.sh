export IDENTITY_TENANT_ID=aao4987
export TENANT_NAME=cybr-secrets
export CONJUR_CLOUD_URL=https://$TENANT_NAME.secretsmgr.cyberark.cloud/api
export CONJUR_ADMIN_USER=jody_bot@cyberark.cloud.3357
export CONJUR_ADMIN_PWD=$(keyring get cybrid jodybotpwd)
#export CONJUR_ADMIN_USER=<oauth2-confidential-client-name>
#export CONJUR_ADMIN_PWD=<oauth2-confidential-client-password>

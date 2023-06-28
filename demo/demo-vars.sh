###########################################################
export DOCKER="docker"
export DOCKER_HOSTNAME=conjur-master-mac
export DEMO_IMAGE=ansible-acclr8r
export DEMO_CONTAINER=ansible-acclr8r
export CONJUR_AUTHN_LOGIN=data/e2etest

###########################################################
# Target database parameters
###########################################################
export MYSQL_IMAGE=mysql:5.7.32
export MYSQL_SERVER=mysql-acclr8r
export MYSQL_ROOT_PASSWORD=Cyberark1
export MYSQL_URL=$DOCKER_HOSTNAME
export MYSQL_PORT=3306

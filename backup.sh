#! /bin/bash

set -x

# color definition
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # Reset

# debug definitions, should be defined in docker-compose or via environment variables during startup
DB_HOST="swim-activiti-h2"
DB_PORT=1521
DB_NAME="/opt/h2-data/actviti"
DB_USER="sa"

# This helps for the image build simply by making sure everything that should be set actually has been
function sanity_check() {
  for var in DB_HOST DB_PORT DB_USER DB_NAME; do
    if [ -z ${var+x} ]; then
      printf "${RED}[!] Failed sanity check of environment${NC} : $var was not set\n"
      exit 1
    fi
  done
}

function h2_driver_present() {
	if [[ ! -f h2*.jar ]]; then
		echo "${RED}[!] Could not find H2 driver locally, downloading...${NC}"
		wget -O h2-1.4.196.jar http://repo2.maven.org/maven2/com/h2database/h2/1.4.196/h2-1.4.196.jar
	fi 
}

function change_to_workdir() {
	cd $LOCATION
}

function create_vars() {
	# Creating default variables
	DATE=$(date '+%Y/%m/%d-%H:%M:%S')
	LOCATION=${LOCATION:-"/data"}
	GITHUB_BRANCH=${GITHUB_BRANCH:-"master"}

	JDBC_URL="jdbc:h2:tcp://${DB_HOST}:${DB_PORT}/${DB_NAME}"
}

function create_backup() {
	echo "${BLUE}[*]${NC} Creating backup for H2 DB with JDBC URL ${JDBC_URL}"
	java -cp h2*.jar org.h2.tools.Script -url ${JDBC_URL} -user ${DB_USER} -script test.zip -options compression zip

	unzip test.zip
}

function git_user_setup() {
	git config --global user.email "dummy@example.com"
	git config --global user.name "Backup Dummy"

}

function git_push() {
	echo "${BLUE}[*]${NC} Changing directories to ${LOCATION}/git"
	mkdir -p ./git

	cd ./git

	echo "${BLUE}[*]${NC} Running ${BLUE}git pull${NC}"
	git pull "https://${GITHUB_USER}:${GITHUB_PASSWORD}@github.com/${GITHUB_ACCOUNT_OR_ORG}/${GITHUB_REPOSITORY}.git" $GITHUB_BRANCH
	if [[ $? -ne 0 ]]; then
		git init
		git remote add origin "https://github.com/${GITHUB_ACCOUNT_OR_ORG}/${GITHUB_REPOSITORY}.git"
		git fetch
		git checkout -t origin/master -f 
		# git pull "https://${GITHUB_USER}:${GITHUB_PASSWORD}@github.com/${GITHUB_ACCOUNT_OR_ORG}/${GITHUB_REPOSITORY}.git" $GITHUB_BRANCH
		#git clone "https://${GITHUB_USER}:${GITHUB_PASSWORD}@github.com/${GITHUB_ACCOUNT_OR_ORG}/${GITHUB_REPOSITORY}.git" -b $GITHUB_BRANCH ./
	fi

	mv -f ../script.sql ./script.sql
	echo "${BLUE}[*]${NC} Adding changes to remote git"
	git add -A
	git commit -m "${DATE}"
	git push https://${GITHUB_USER}:${GITHUB_PASSWORD}@github.com/${GITHUB_ACCOUNT_OR_ORG}/${GITHUB_REPOSITORY}.git $GITHUB_BRANCH
}

function cleanup() {
	echo "${BLUE}[*]${NC} Removing artifacts from directory"

	cd ..
	rm -rf ./git/.git
	rm ./git/script.sql
	rm test.zip
}

sanity_check
create_vars
change_to_workdir
h2_driver_present
git_user_setup
create_backup
git_push
# cleanup
exit 0
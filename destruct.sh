#!/bin/sh
#
# author : E.Yhuellou
# description : deploy a destructive change

# Sample usage ./destruct.sh myusername@dev.fr ./force-app/main/default
# inputs 
TARGET_ENV=$1
SOURCE_PATH=$2

# constants
API_VERSION=47.0 # api version (same as in the sfdx-project.json)
# DEFAULT_TEST_CLASS=MyTestClass # a passing test class

echo "PART 01 : Clean existing destructivePackage folder"
rm -rf deployment/destructivePackage &>/dev/null
mkdir -p deployment/destructivePackage &>/dev/null

echo "PART 02 : Converting Source format to Metadata API format"
sfdx force:source:convert -p ${SOURCE_PATH} -d deployment/destructivePackage

# copy package.xml to desctructiveChanges.xml
cp deployment/destructivePackage/package.xml deployment/destructivePackage/destructiveChanges.xml

echo "PART 03 : Creating package.xml"
# generate an empty (containing only the api version tag) package.xml
cat <<EOT > deployment/destructivePackage/package.xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
  <version>${API_VERSION}</version>
</Package>
EOT

# deploying to the target org
echo "PART 04 : Deploying a destructive change to ${TARGET_ENV}"
echo "In Progress..."
sfdx force:mdapi:deploy -d deployment/destructivePackage -u ${TARGET_ENV} -l NoTestRun -w -1 --loglevel INFO --verbose  #RunSpecifiedTests -r ${DEFAULT_TEST_CLASS}
if [ $? -eq 0 ]; then
    # green color
    echo -e "\e[32m************************** Success **************************"
else
    # red color
    echo -e "\e[31m************************** Error **************************"
fi
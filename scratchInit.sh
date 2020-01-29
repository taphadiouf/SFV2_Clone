# Bash Script used for creating new scratch org 

# Prerequisites :
# Be sure to be placed in a sfdx project folder in order to find the correct config/project-scratch-def.json
# Be sure you authorized DevHub access

YourScratchOrgUsername=$1

echo "Creating New Scratch Org..."

sfdx force:org:create --setdefaultusername -f config/project-scratch-def.json --setalias $YourAlias -d 30

sfdx force:org:list

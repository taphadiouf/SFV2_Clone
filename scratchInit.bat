REM Bash Script used for creating new scratch org 

REM Prerequisites :
REM Be sure to be placed in a sfdx project folder in order to find the correct config/project-scratch-def.json
REM Be sure you authorized DevHub access

YourAlias=$1

echo "Script Version 1.2 : Creating New Scratch Org..."

sfdx force:org:create --setdefaultusername -f config/project-scratch-def.json --setalias $YourAlias -d 30

echo "------> Starting managed package installation..."

echo "----------- CPQ :"
sfdx force:package:install -p 04t4N000000YT2ZQAW -u $YourAlias  -w 25 --noprompt

echo "----------- Billing :"
sfdx force:package:install -p 04t0K00000179KyQAI -u $YourAlias  -w 25

echo "----------- Sparklane :"
sfdx force:package:install -p 04t4I000000gNw8QAE -u $YourAlias  -w 25

echo "----------- Adobe Sign :"
sfdx force:package:install -p 04t0g000000tOItAAM -u $YourAlias  -w 25

REM echo "----------- FA :"
REM sfdx force:package:install -p 04t0M000001SbQHQA0 -u $YourAlias  -w 25

REM echo "----------- Conga :"
REM sfdx force:package:install -p 04tf2000002FhY6AAK -u $YourAlias  -w 25 --noprompt

REM echo "----------- Prodly :"
REM sfdx force:package:install -p 04t0H000000p4jZQAQ -u $YourAlias  -w 25 --noprompt

echo "Finish installing all managed package"

echo "deploy current branch (it should be develop if you just cloned SFDV2 repo)"
sfdx force:source:push

echo "assign LPCR Admin permission set to default scratch org user..."
sfdx force:user:permset:assign -n LPCR_Admin

echo "scratchInit finished"

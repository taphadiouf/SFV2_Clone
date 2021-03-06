rem Bash Script used for creating new scratch org 

rem Prerequisites :
rem Be sure to be placed in a sfdx project folder in order to find the correct config/project-scratch-def.json
rem Be sure you authorized DevHub access

SET YourAlias=%1

echo "Script Version 1.2 : Creating New Scratch Org..."

sfdx force:org:create --setdefaultusername -f config/project-scratch-def.json --setalias %YourAlias -d 10

echo "------> Starting managed package installation..."

echo "----------- CPQ : ( w = 40)"
sfdx force:package:install -p 04t4N000000YTOgQAO -u %YourAlias  -w 40 --noprompt

echo "----------- Billing :"
sfdx force:package:install -p 04t0K000001E2m7QAC -u %YourAlias  -w 40

echo "----------- Salesforce Billing Reporting Add-on :"
sfdx force:package:install -p 04t4P000002icr9QAA -u %YourAlias  -w 40

echo "----------- Sparklane :"
sfdx force:package:install -p 04t4I000000gNw8QAE -u %YourAlias  -w 40

echo "----------- Adobe Sign :"
sfdx force:package:install -p 04t0g000000xaQxAAI -u %YourAlias  -w 40

echo "----------- CPQ - Conga Quotes :"
sfdx force:package:install -p 04t5w000004cdSvAAI -u %YourAlias  -w 40 --noprompt

echo "----------- Conga Invoices Generation :"
sfdx force:package:install -p 04t2M000002mdK2QAI -u %YourAlias  -w 40 --noprompt

rem echo "----------- FA :"
rem sfdx force:package:install -p 04t0M000001SbQHQA0 -u %YourAlias  -w 25

rem echo "----------- Prodly :"
rem sfdx force:package:install -p 04t0H000000p4jZQAQ -u %YourAlias  -w 25 --noprompt

echo "----------- Advanced Approvals :"
sfdx force:package:install -p 04t0L0000001ttYQAQ -u %YourAlias  -w 40 --noprompt

echo "Finish installing all managed package"

echo "scratchInit finished"

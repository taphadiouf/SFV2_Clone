# Bash Script used for creating new scratch org 

# Prerequisites :
# Be sure to be placed in a sfdx project folder in order to find the correct config/project-scratch-def.json
# Be sure you authorized DevHub access

YourAlias=$1

echo "Script Version 1.2 : Creating New Scratch Org..."

sfdx force:org:create --setdefaultusername -f config/project-scratch-def.json --setalias $YourAlias -d 30

echo "------> Starting managed package installation..."

echo "----------- CPQ : ( w = 40)"
sfdx force:package:install -p 04t4N000000ceDxQAI -u $YourAlias  -w 40 --noprompt

echo "----------- Billing :"
sfdx force:package:install -p 04t0K000001E2m7QAC -u $YourAlias  -w 40

echo "----------- Salesforce Billing Reporting Add-on :"
sfdx force:package:install -p 04t4P000002icr9QAA -u $YourAlias  -w 40

echo "----------- Sparklane :"
sfdx force:package:install -p 04t4I000000gNw8QAE -u $YourAlias  -w 40

echo "----------- Adobe Sign :"
sfdx force:package:install -p 04t0g000000tOItAAM -u $YourAlias  -w 40

echo "----------- CPQ - Conga Quotes :"
sfdx force:package:install -p 04tf20000003UBeAAM -u $YourAlias  -w 40 --noprompt

echo "----------- Conga Invoices Generation :"
sfdx force:package:install -p 04t2M000002mdK2QAI -u $YourAlias  -w 40 --noprompt

#echo "----------- FA :"
#sfdx force:package:install -p 04t0M000001SbQHQA0 -u $YourAlias  -w 25

#echo "----------- Prodly :"
#sfdx force:package:install -p 04t0H000000p4jZQAQ -u $YourAlias  -w 25 --noprompt


echo "Finish installing all managed package"

echo "scratchInit finished"

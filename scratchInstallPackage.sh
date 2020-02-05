
# Bash Script used for installing all managed packaged in a scratch org

# Prerequisites :
# Be sure to be placed in a sfdx project folder in order to find the correct config/project-scratch-def.json
# Be sure you authorized DevHub access

YourAlias=$1

echo "Starting managed package installation..."

echo "CPQ :"
sfdx force:package:install -p 04t4N000000YT2ZQAW -u $YourScratchOrgUsername  -w 25 --noprompt

echo "Billing :"
sfdx force:package:install -p 04t0K00000179KyQAI -u $YourScratchOrgUsername  -w 25

echo "FA :"
sfdx force:package:install -p 04t0M000001SbQHQA0 -u $YourScratchOrgUsername  -w 25

echo "Sparklane :"
sfdx force:package:install -p 04t4I000000gNw8QAE -u $YourScratchOrgUsername  -w 25

echo "Conga :"
sfdx force:package:install -p 04tf2000002FhY6AAK -u $YourScratchOrgUsername  -w 25 --noprompt

echo "Adobe Sign :"
sfdx force:package:install -p 04t0g000000tOItAAM -u $YourScratchOrgUsername  -w 25

echo "Prodly :"
sfdx force:package:install -p 04t0H000000p4jZQAQ -u $YourScratchOrgUsername  -w 25 --noprompt

echo "Finish installing all managed package"
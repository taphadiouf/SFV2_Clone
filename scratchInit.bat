REM Bash Script used for creating new scratch org 

REM Prerequisites :
REM Be sure to be placed in a sfdx project folder in order to find the correct config/project-scratch-def.json
REM Be sure you authorized DevHub access

SET YourAlias=%1

ECHO "Creating New Scratch Org..."

sfdx force:org:create --setdefaultusername -f config/project-scratch-def.json --setalias $YourAlias% -d 30

ECHO "Starting managed package installation..."

ECHO "CPQ :"
sfdx force:package:install -p 04t4N000000YT2ZQAW -u %YourAlias%  -w 25 --noprompt

ECHO "Billing :"
sfdx force:package:install -p 04t0K00000179KyQAI -u %YourAlias%  -w 25

ECHO "FA :"
sfdx force:package:install -p 04t0M000001SbQHQA0 -u %YourAlias%  -w 25

ECHO "Sparklane :"
sfdx force:package:install -p 04t4I000000gNw8QAE -u %YourAlias%  -w 25

REM ECHO "Conga :"
REM sfdx force:package:install -p 04tf2000002FhY6AAK -u %YourAlias%  -w 25 --noprompt

ECHO "Adobe Sign :"
sfdx force:package:install -p 04t0g000000tOItAAM -u %YourAlias%  -w 25

ECHO "Prodly :"
sfdx force:package:install -p 04t0H000000p4jZQAQ -u %YourAlias%  -w 25 --noprompt

ECHO "Finish installing all managed package"

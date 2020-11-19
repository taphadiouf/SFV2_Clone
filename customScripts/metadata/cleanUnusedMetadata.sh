echo "Start Cleaning..."
#rm ./force-app/main/default/objects/blng__Invoice__c/fields/blng__InvoicePostedDate__c.field-meta.xml
rm -rf ./force-app/main/default/flowDefinitions/*
rm -rf ./mdapiout
echo "Finished Cleaning."

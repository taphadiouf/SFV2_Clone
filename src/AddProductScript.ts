export function onAfterCalculate(quote, lines, conn) {
console.log('Quote : '+ quote.record["Id"] );
console.log( 'LPCR_Contracted_Checkbox__c:' );
console.log( quote.record["LPCR_Contracted_Checkbox__c"] );
 if( quote.record["SBQQ__Type__c"] == 'Renewal' && quote.record["LPCR_Added_Product_Using_QCP__c"] == false && quote.record["LPCR_Contracted_Checkbox__c"] == true  ) {
	var newRecords = []; 
	
	var conditions = {
				ProductCode: 'FraisInscriptionMac'
			};
	var fields = ['Id','ProductCode'];
	return conn.sobject('Product2')
		.find(conditions, fields)
		.execute(function(err, records) {
			console.log(records);
			var product = records[0].Id;
			console.log( 'product ' + product );
			if(err){
				return Promise.reject(err);
			}else{
				
				if (true) {
					quote.record["LPCR_Added_Product_Using_QCP__c"] = true;
					newRecords.push(
					{ SBQQ__Product__c: product , SBQQ__Quote__c: quote.record["Id"] , SBQQ__Number__c: 100 }
					);
				}
				if (newRecords.length) {
					quote.record["LPCR_Added_Product_Using_QCP__c"] = true;
					return conn.sobject('SBQQ__QuoteLine__c').create(newRecords, function(err, ret)
					{ console.log(ret); }
					);
				}  
			}			
		});
  } return Promise.resolve(); }
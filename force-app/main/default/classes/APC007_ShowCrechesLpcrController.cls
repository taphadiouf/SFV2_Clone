/**
* @author Achraf ABOUL
* @date 29/05/2020
* @Description Controller for Show creches LWC 
*/
public with sharing class APC007_ShowCrechesLpcrController {

    @AuraEnabled(cacheable=false)
    public static String getLocations(String currentId,String modeAffich){
        Id reseauCrecheAccountRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_ReseauLPCR);
       
        List<Location> locations = new List<Location>();
        Location centerLocation = new Location();

        if(String.isNotBlank(modeAffich) && String.isNotBlank(currentId)){
            if('CompteFamille'.equals(modeAffich)){
                Account currentRecord = [SELECT Id, Name, ShippingLatitude, ShippingLongitude from Account where ShippingLatitude != Null AND ShippingLongitude != Null AND Id =: currentId limit 1];
                centerLocation.name = currentRecord.name;
                centerLocation.locationId = currentRecord.Id;
                centerLocation.latitude =  currentRecord.ShippingLatitude;
                centerLocation.longitude =  currentRecord.ShippingLongitude;
                centerLocation.isCenter =  true;
                
                locations.add(centerLocation);
            }
            else if('LeadFamille'.equals(modeAffich)){
                Lead currentRecord = [SELECT Id, Name, latitude, longitude from Lead where latitude != Null AND longitude != Null AND Id =: currentId limit 1];
                centerLocation.name = currentRecord.name;
                centerLocation.locationId = currentRecord.Id;
                centerLocation.latitude =  currentRecord.latitude;
                centerLocation.longitude =  currentRecord.longitude;
                centerLocation.isCenter =  true;
                
                locations.add(centerLocation);
            }
            
            else if('Preinscription'.equals(modeAffich)){
                LPCR_Preinscription__c currentRecord = [SELECT Id, Name, LPCR_Latitude__c, LPCR_Longitude__c  FROM LPCR_Preinscription__c  WHERE LPCR_Longitude__c != Null AND LPCR_Latitude__c != Null AND Id =: currentId limit 1];
                centerLocation.name = currentRecord.Name;
                centerLocation.locationId = currentRecord.Id;
                centerLocation.latitude =  currentRecord.LPCR_Latitude__c;
                centerLocation.longitude =  currentRecord.LPCR_Longitude__c;
                centerLocation.isCenter =  true;
                
                locations.add(centerLocation);
            }
        }
        Location currentLocation;
        for(Account eachAcc : [Select Id, Name, ShippingLatitude, ShippingLongitude from Account where ShippingLatitude != Null AND ShippingLongitude != Null AND RecordTypeId =: reseauCrecheAccountRT]){
            System.debug(eachAcc);
            currentLocation = new Location();
            currentLocation.locationId = eachAcc.Id;
            currentLocation.name = UM010_Constant.CRECHE_LPCR + eachAcc.name;
            currentLocation.latitude =  eachAcc.ShippingLatitude;
            currentLocation.longitude =  eachAcc.ShippingLongitude;
            locations.add(currentLocation);
        }
        LocationsConfiguration locConfig = new LocationsConfiguration();
        locConfig.locations = locations;
        locConfig.center = centerLocation;
        return JSON.serialize(locConfig);
    }
    public class Location{
        @AuraEnabled public String name;
        @AuraEnabled public Double latitude;
        @AuraEnabled public Double longitude;
        @AuraEnabled public Id locationId;
        @AuraEnabled public Boolean isCenter;
    }
    public class LocationsConfiguration{
        @AuraEnabled public List<Location> locations;
        @AuraEnabled public Location center;
    }
            
   
}
/**
* @author Achraf ABOUL
* @date 29/05/2020
* @Description Controller for Show creches LWC 
*/
public with sharing class APC007_ShowCrechesLpcrController {

    @AuraEnabled(cacheable=true)
    public static String getLocations(String currentId,String modeAffich){
        Id reseauCrecheAccountRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_ReseauLPCR);
       
        List<Location> locations = new List<Location>();
        Location centerLocation = new Location();

        if(String.isNotBlank(modeAffich) && String.isNotBlank(currentId)){
            if('CompteFamille'.equals(modeAffich)){
                Account currentRecord = [SELECT Id, Name, ShippingLatitude, ShippingLongitude from Account where  Id =: currentId limit 1];
                centerLocation.name = currentRecord.name;
                centerLocation.latitude =  currentRecord.ShippingLatitude;
                centerLocation.longitude =  currentRecord.ShippingLongitude;
                centerLocation.isCenter =  true;
                
                locations.add(centerLocation);
            }
            else if('LeadFamille'.equals(modeAffich)){
                Lead currentRecord = [SELECT Id, Name, latitude, longitude from Lead where Id =: currentId limit 1];
                centerLocation.name = currentRecord.name;
                centerLocation.latitude =  currentRecord.latitude;
                centerLocation.longitude =  currentRecord.longitude;
                centerLocation.isCenter =  true;
                
                locations.add(centerLocation);
            }
            /*
            else if('Preinscription'.equals(modeAffich)){
                LPCR_Preinscription__c currentRecord = [SELECT Id, LPCR_ContactParent__r.Name, LPCR_ContactParent__r.MailingAddress, LPCR_ContactParent__r.MailingStreet,
                LPCR_ContactParent__r.MailingCity, LPCR_ContactParent__r.MailingCountry, LPCR_ContactParent__r.MailingPostalCode, LPCR_ContactParent__r.MailingState  FROM LPCR_Preinscription__c  WHERE Id =: currentId limit 1];
                centerLocation.Street = currentRecord.LPCR_ContactParent__r.MailingStreet;
                centerLocation.PostalCode = currentRecord.LPCR_ContactParent__r.MailingPostalCode;
                centerLocation.City = currentRecord.LPCR_ContactParent__r.MailingCity;
                centerLocation.State = currentRecord.LPCR_ContactParent__r.MailingState;
                centerLocation.Country = currentRecord.LPCR_ContactParent__r.MailingCountry;
                Location locDetail = new Location();
                locDetail.icon = 'url: "http://maps.google.com/mapfiles/ms/icons/blue-dot.png"'; 
                locDetail.title = currentRecord.LPCR_ContactParent__r.Name;
                locDetail.description = currentRecord.LPCR_ContactParent__r.Name;
                locDetail.location = centerLocation;
                
                locations.add(locDetail);
            }*/
        }
        Location currentLocation;
        for(Account eachAcc : [Select Id, Name, ShippingLatitude, ShippingLongitude from Account where RecordTypeId =: reseauCrecheAccountRT]){
            System.debug(eachAcc);
            currentLocation = new Location();
            currentLocation.name = eachAcc.name;
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

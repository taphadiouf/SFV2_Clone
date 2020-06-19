/**
* @author Achraf ABOUL
* @date 29/05/2020
* @Description Controller for Show creches LWC 
*/
public with sharing class APC007_ShowCrechesLpcrController {
            @AuraEnabled(cacheable=true)
            public static String getAccounts(String currentId,String modeAffich){
                Id reseauCrecheAccountRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_ReseauLPCR);
                List<Account> accs =  [Select Id, Name,Type, Industry, ShippingAddress,ShippingStreet,
                                        ShippingCity, ShippingCountry, ShippingPostalCode,
                                        ShippingState,Phone from Account where /*ShippingStreet!=NULL AND
                                        ShippingCity!=NULL AND ShippingCountry!=NULL AND  ShippingPostalCode!=NULL AND
                                        ShippingState!=NULL AND*/ RecordTypeId =: reseauCrecheAccountRT] ;
               
                List<Location> locations = new List<Location>();
                GeoLocation centerLocation = new GeoLocation();

                for(Account acc :accs){
                    GeoLocation geoInfo = new GeoLocation();
                    geoInfo.Street = acc.ShippingStreet;
                    geoInfo.PostalCode = acc.ShippingPostalCode;
                    geoInfo.City = acc.ShippingCity;
                    geoInfo.State = acc.ShippingState;
                    geoInfo.Country = acc.ShippingCountry;
                    Location locDetail = new Location();
                    locDetail.icon = 'http://maps.google.com/mapfiles/ms/icons/yellow-dot.png'; 
                    locDetail.title = acc.Name;
                    locDetail.description = acc.Name;
                    locDetail.location = geoInfo;
                    
                    locations.add(locDetail);
                }
                if(String.isNotBlank(modeAffich) && String.isNotBlank(currentId)){
                    if('CompteFamille'.equals(modeAffich)){
                        Account currentRecord = [SELECT Id, Name,Type, Industry, ShippingAddress,ShippingStreet,
                        ShippingCity, ShippingCountry, ShippingPostalCode,
                        ShippingState,Phone from Account where  Id =: currentId limit 1];
                        centerLocation.Street =  currentRecord.ShippingStreet;
                        centerLocation.PostalCode =  currentRecord.ShippingPostalCode;
                        centerLocation.City = currentRecord.ShippingCity;
                        centerLocation.State = currentRecord.ShippingState;
                        centerLocation.Country = currentRecord.ShippingCountry;
                        Location locDetail = new Location();
                        locDetail.icon = 'url: "http://maps.google.com/mapfiles/ms/icons/blue-dot.png"'; 
                        locDetail.title = currentRecord.Name;
                        locDetail.description = currentRecord.Name;
                        locDetail.location = centerLocation;
                        
                        locations.add(locDetail);
                    }
                    else if('LeadFamille'.equals(modeAffich)){
                        Lead currentRecord = [SELECT Id, Name,Address,Street,
                        City, Country, PostalCode, State,Phone from Lead where Id =: currentId limit 1];
                        centerLocation.Street = currentRecord.Street;
                        centerLocation.PostalCode = currentRecord.PostalCode;
                        centerLocation.City = currentRecord.City;
                        centerLocation.State = currentRecord.State;
                        centerLocation.Country = currentRecord.Country;
                        Location locDetail = new Location();
                        locDetail.icon = 'url: "http://maps.google.com/mapfiles/ms/icons/blue-dot.png"'; 
                        locDetail.title = currentRecord.Name;
                        locDetail.description = currentRecord.Name;
                        locDetail.location = centerLocation;
                        
                        locations.add(locDetail);
                    }
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
                    }
                    
                }
                MapConfig mapConfiguration = new MapConfig();
                mapConfiguration.mapMarkers = locations;
                Center cent = new Center();
                cent.location = centerLocation;
                mapConfiguration.center = cent;
                return Json.serialize(mapConfiguration);
            }
            public class MapConfig{
                @AuraEnabled
                public List<Location> mapMarkers{get;set;}
                public Center center{get;set;}
            }
            public class Center{
                public GeoLocation location{get;set;}
            }
            public class Location{
                @AuraEnabled 
                public String icon{get;set;} 
                @AuraEnabled 
                public String title{get;set;} 
                @AuraEnabled
                public String description{get;set;} 
                @AuraEnabled 
                public GeoLocation location{get;set;} 
            }
            public class GeoLocation{
                @AuraEnabled 
                public String Street{get;set;}
                @AuraEnabled 
                public String PostalCode{get;set;}
                @AuraEnabled 
                public String City{get;set;}
                @AuraEnabled 
                public String State{get;set;}
                @AuraEnabled 
                public String Country{get;set;}
            }
            
   
}

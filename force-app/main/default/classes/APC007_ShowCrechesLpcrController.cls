/**
* @author Achraf ABOUL
* @date 29/05/2020
* @Description Controller for Show creches LWC 
*/
public with sharing class APC007_ShowCrechesLpcrController {
    public APC007_ShowCrechesLpcrController() {
    }
            @AuraEnabled(cacheable=true)
            public static List<Location> getAccounts(){
                Id reseauCrecheAccountRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_ReseauLPCR);
                List<Account> accs =  [Select Id, Name,Type, Industry, ShippingAddress,ShippingStreet,
                                        ShippingCity, ShippingCountry, ShippingPostalCode,
                                        ShippingState,Phone from Account where /*ShippingStreet!=NULL AND
                                        ShippingCity!=NULL AND ShippingCountry!=NULL AND  ShippingPostalCode!=NULL AND
                                        ShippingState!=NULL AND*/ RecordTypeId =: reseauCrecheAccountRT] ;
                
                List<Location> locations = new List<Location>();
                for(Account acc :accs){
                    System.debug(acc);
                    GeoLocation geoInfo = new GeoLocation();
                    geoInfo.Street = acc.ShippingStreet;
                    geoInfo.PostalCode = acc.ShippingPostalCode;
                    geoInfo.City = acc.ShippingCity;
                    geoInfo.State = acc.ShippingState;
                    geoInfo.Country = acc.ShippingCountry;
                    Location locDetail = new Location();
                    locDetail.icon = 'action:map'; 
                    locDetail.title = acc.Name;
                    locDetail.description = acc.Name;
                    locDetail.location = geoInfo;
                    
                    locations.add(locDetail);
                }
                return locations ;
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

public class WRP001_QuoteModel {
    public SBQQ__Quote__c record;
    public WRP002_QuoteLineModel[] lineItems;
    public WRP003_QuoteLineGroupModel[] lineItemGroups;
    public Integer nextKey;
    public Boolean applyAdditionalDiscountLast;
    public Boolean applyPartnerDiscountFirst;
    public Boolean channelDiscountsOffList;
    public Decimal customerTotal;
    public Decimal netTotal;
    public Decimal netNonSegmentTotal;
}
public with sharing class PartnerOrderSummaryController
{
    public PartnerOrderSummaryController() {                 
        
        Set<String> Profiles = new Set<String> { 'Compliatric Customer', 'Compliatric Start-up Customer' };
        //Set<String> OrderTypes = new Set<String> { 'Initial','Add-On' };       
        
        PartnerOrders = [
            SELECT  
                CHANNEL_ORDERS__Customer__r.Id,
                CHANNEL_ORDERS__Customer__r.Account__r.Name, 
                CHANNEL_ORDERS__Customer__r.Account__r.Service_Renewal_Date__c,
                SUM(Total_Power_Licenses__c)TotalPower, 
                SUM(Total_Basic_Licenses__c)TotalBasic,
                SUM(Total_Admin_Licenses__c)TotalAdmin,
                SUM(Total_Partner_Admin_Licenses__c)TotalPartnerAdmin
            FROM CHANNEL_ORDERS__Service_Order__c 
            WHERE CHANNEL_ORDERS__Customer__r.Account__r.RecordType.Name IN :Profiles
            AND CHANNEL_ORDERS__Service_Order_Status__c != 'Error'
            AND CHANNEL_ORDERS__Customer__r.Account__r.Active__c = 'Yes'
            GROUP BY CHANNEL_ORDERS__Customer__r.Id,CHANNEL_ORDERS__Customer__r.Account__r.Name, CHANNEL_ORDERS__Customer__r.Account__r.Service_Renewal_Date__c
            ORDER BY CHANNEL_ORDERS__Customer__r.Account__r.Name
        ];
        
        PartnersOrderSummary = new List<PartnerOrderSummary>();
        
        for(AggregateResult agg : PartnerOrders)
        {
            PartnerOrderSummary pos = new PartnerOrderSummary();
            pos.CompanyId = (Id)agg.get('Id');
            pos.CompanyName = (string)agg.get('Name');
            pos.ServiceRenewalDate = (Date)agg.get('Service_Renewal_Date__c');
            pos.DecimalTotalPower = (decimal)agg.get('TotalPower');
            pos.DecimalTotalBasic = (decimal)agg.get('TotalBasic');
            pos.DecimalTotalAdmin = (decimal)agg.get('TotalAdmin');
            pos.DecimalTotalPartnerAdmin = (decimal)agg.get('TotalPartnerAdmin');
            pos.TotalPower = ((decimal)agg.get('TotalPower')).intValue();
            pos.TotalBasic = ((decimal)agg.get('TotalBasic')).intValue();
            pos.TotalAdmin = ((decimal)agg.get('TotalAdmin')).intValue();
            pos.TotalPartnerAdmin = ((decimal)agg.get('TotalPartnerAdmin')).intValue();
            pos.TotalLicenses = pos.TotalPower + pos.TotalBasic + pos.TotalAdmin + pos.TotalPartnerAdmin;
            PartnersOrderSummary.Add(pos);
        }
    }

    public List<AggregateResult> PartnerOrders { get; set; }
    public List<PartnerOrderSummary> PartnersOrderSummary { get; set; }

    public class PartnerOrderSummary
    {        
        public Id CompanyId {get;set;}
        public string CompanyName { get;set; }
        public Date ServiceRenewalDate {get;set;}
        public decimal DecimalTotalPower {get;set;}
        public decimal DecimalTotalBasic {get;set;}
        public decimal DecimalTotalAdmin {get;set;}
        public decimal DecimalTotalPartnerAdmin {get;set;}
        public integer TotalPower {get;set;}
        public integer TotalBasic {get;set;}
        public integer TotalAdmin {get;set;}
        public integer TotalPartnerAdmin {get;set;}    
        public integer TotalLicenses {get;set;}
    }
}
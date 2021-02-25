public with sharing class OpportunityLineItemCalculator {
    
    
    public static void onAfterTrigger(List<OpportunityLineItem> olilist){
        Set<String> ignoreProducts = new Set<String>();
        
        List<CustomSettings_IgnoreProducts__c> ip = CustomSettings_IgnoreProducts__c.getall().values();
            
        for(CustomSettings_IgnoreProducts__c i : ip) {
            ignoreProducts.add(i.Name);
        }
        if(checkRecursive.isFirstRun()) {        
        	Set<Id> oppIds = new Set<Id>();
        
            for(OpportunityLineItem oli : olilist) {
                oppIds.add(oli.OpportunityId);
            }
            
        
            Map<Id,Decimal> mapofCost = new Map<Id,Decimal>();            
            
            List<AggregateResult> aggResults = [SELECT OpportunityId, SUM(TotalPrice) UnitPrices
                                               FROM OpportunityLineItem
                                               WHERE OpportunityId IN :oppIds 
                                                AND Product2.Name NOT IN :ignoreProducts
                                               GROUP BY OpportunityId];
        
            if(aggResults.size() > 0) {
                for(AggregateResult ar : aggResults) {
                    mapOfCost.put((Id)ar.get('OpportunityId'), (Decimal)ar.get('UnitPrices'));    
                }        
            }
            
            /* Select the Support Line Item to update */
            List<OpportunityLineItem> updatelist =  [SELECT Id, OpportunityId, Product2Id, Product2.Name, UnitPrice
                                                    FROM OpportunityLineItem
                                                    WHERE OpportunityId IN :oppIds 
                                                    AND Product2.Name IN('Support')];
            
            for(OpportunityLineItem oli : updatelist) {
                if(mapOfCost.get(oli.OpportunityId) != null) {
                    oli.UnitPrice = (Decimal)mapOfCost.get(oli.OpportunityId);
                }
            }
            
            update updatelist;
        }    
    }

}
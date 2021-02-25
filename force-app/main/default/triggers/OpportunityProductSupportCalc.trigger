trigger OpportunityProductSupportCalc on OpportunityLineItem (after insert, after update, after delete, after undelete) {    
    if(Trigger.isDelete) {
        OpportunityLineItemCalculator.onAfterTrigger(Trigger.old);
    }
    else
    {
        OpportunityLineItemCalculator.onAfterTrigger(Trigger.new);
    }
        
}
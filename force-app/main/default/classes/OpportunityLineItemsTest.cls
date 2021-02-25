@isTest
private without sharing class OpportunityLineItemsTest {
	
    @isTest(SeeAllData=true)
    private static void testOpportunityLineItemTriggerViaDML() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        
        insert acc;    
        
        List<Product2> newproducts = new List<Product2>();
        Product2 p1 = new Product2();
        p1.Name = 'Support';                  
        newproducts.add(p1);
        
        Product2 p2 = new Product2();
        p2.Name = 'Basic User';
        newproducts.add(p2);
        
        Product2 p3 = new Product2();
        p3.Name = 'Initial Setup Fee';
        newproducts.add(p3);
        
        Product2 p4 = new Product2();
        p4.Name = 'Power User All Modules';
        newproducts.add(p4);
        
        Product2 p5 = new Product2();
        p5.Name = 'Platform Fee';
        newproducts.add(p5);
        
        insert newproducts;                     
        
        Pricebook2 pb = [SELECT Id, Name FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        
        List<PricebookEntry> entries = new List<PricebookEntry>();
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.IsActive = true;
        pbe.Pricebook2Id = pb.Id;
        pbe.Product2Id = p1.Id;
        pbe.UnitPrice = 0.00;              
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.IsActive = true;
        pbe2.Pricebook2Id = pb.Id;
        pbe2.Product2Id = p2.Id;
        pbe2.UnitPrice = 3.90;        
        PricebookEntry pbe3 = new PricebookEntry();
        pbe3.IsActive = true;
        pbe3.Pricebook2Id = pb.Id;
        pbe3.Product2Id = p3.Id;
        pbe3.UnitPrice = 3500.00;        
        PricebookEntry pbe4 = new PricebookEntry();
        pbe4.IsActive = true;
        pbe4.Pricebook2Id = pb.Id;
        pbe4.Product2Id = p4.Id;
        pbe4.UnitPrice = 89.00;        
        PricebookEntry pbe5 = new PricebookEntry();
        pbe5.IsActive = true;
        pbe5.Pricebook2Id = pb.Id;
        pbe5.Product2Id = p5.Id;        
        pbe5.UnitPrice = 206.00;        
        
        entries.add(pbe);
        entries.add(pbe2);
        entries.add(pbe3);
        entries.add(pbe4);
        entries.add(pbe5);
        
        insert entries;
        
        
        Opportunity op = new Opportunity();
        op.AccountId = acc.Id;
        op.Pricebook2Id = pb.Id;
        op.Name = 'Test Opportunity';
        op.CloseDate = Date.today();
        op.StageName = 'Demo';
        
        insert op;
        
        Map<String,Id> productIDs = new Map<String,Id>();
        
        List<Product2> products = [SELECT Id, Name FROM Product2 WHERE IsActive = true];
        
        for(Product2 p : products) {
            productIDs.put(p.Name,p.Id);
        }        
                
        List<OpportunityLineItem> olilisttest = new List<OpportunityLineItem>();
        
        OpportunityLineItem oli1 = new OpportunityLineItem();     	
        oli1.Product2Id = productIDs.get('Initial Setup Fee');    
        oli1.PricebookEntryId = pbe3.Id;
        oli1.UnitPrice = 3500.00;
        oli1.Quantity = 1.00;             
        oli1.OpportunityId = op.Id;
        
        olilisttest.add(oli1);        
        
        OpportunityLineItem oli2 = new OpportunityLineItem();     	        
        oli2.Product2Id = productIDs.get('Platform Fee');        
        oli2.PricebookEntryId = pbe5.Id;
        oli2.UnitPrice = 206.00;
        oli2.Quantity = 1.00;        
        oli2.OpportunityId = op.Id;        
        
        olilisttest.add(oli2);    
        
        OpportunityLineItem oli3 = new OpportunityLineItem();     	        
        oli3.Product2Id = productIDs.get('Basic User');
        oli3.PricebookEntryId = pbe2.Id;
        oli3.UnitPrice = 3.90;
        oli3.Quantity = 75.00;        
        oli3.OpportunityId = op.Id;        
        
        olilisttest.add(oli3);        
        
        OpportunityLineItem oli = new OpportunityLineItem();     	        
        oli.Product2Id = productIDs.get('Power User All Modules');
        oli.PricebookEntryId = pbe4.Id;
        oli.UnitPrice = 89.00;
        oli.Quantity = 2.00;        
        oli.OpportunityId = op.Id;   
        olilisttest.add(oli);
        
        insert olilisttest;
        
        List<OpportunityLineItem> thislist = [SELECT Id, Name, UnitPrice, Quantity FROM OpportunityLineItem WHERE OpportunityId = :op.Id];
        System.debug('###### ' + thislist);
        Test.startTest();
        
        OpportunityLineItem olinew = new OpportunityLineItem();        
        olinew.Product2Id = productIDs.get('Support');
        olinew.PricebookEntryId = pbe.Id;
        olinew.Quantity = 0.20;
        olinew.UnitPrice = 0.00;
        olinew.OpportunityId = op.Id;   
        
        olilisttest.add(olinew);       
        upsert olilisttest;
        
        OpportunityLineItem olinew2 = new OpportunityLineItem();     	        
        olinew2.Product2Id = productIDs.get('Basic User');
        olinew2.PricebookEntryId = pbe2.Id;
        olinew2.UnitPrice = 3.90;
        olinew2.Quantity = 5.00;        
        olinew2.OpportunityId = op.Id;       
        
        olilisttest.add(olinew2);  
        
        OpportunityLineItemCalculator.onAfterTrigger(olilisttest);
        
      	List<OpportunityLineItem> olidelete = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :op.Id AND Product2.Name = 'Basic User'];
        
        delete olidelete;
        
        Test.stopTest();
        
        
    }
    
}
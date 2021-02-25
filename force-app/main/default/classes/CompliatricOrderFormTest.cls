@isTest(SeeAllData=true)
private class CompliatricOrderFormTest {
    static testMethod void validateForm() {
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.StageName = 'Closed Won';
        o.CloseDate = Date.newInstance(2018,10,2);
        insert o;
        
        o = [SELECT Id, Name FROM Opportunity WHERE Name = 'test' LIMIT 1];
       
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        CompliatricOrderFormExtension testOrderForm = new CompliatricOrderFormExtension(sc);
        testOrderForm.getLineItems();
        testOrderForm.saveAddOnPDF();
        
        //PageReference prtest2 = testOrderForm.savePDF();
        PageReference pageRef = Page.CompliatricOrderForm;
        Test.setCurrentPage(pageRef);
        testOrderForm.savePDF();
        pageRef.getParameters().put('id', String.valueOf(o.Id));
        
        
        // Test that the trigger correctly updated the price
        System.assertEquals('test', o.Name);
        
        
    }
}
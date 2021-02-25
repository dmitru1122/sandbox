public class CompliatricOrderFormExtension {
    
    private Opportunity opp;
    private List<OpportunityLineItem> oitems;
    private ApexPages.StandardController stdController;
    private final String fileNameEnd = 'Order Form';
    
    public CompliatricOrderFormExtension(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.opp = (Opportunity)stdController.getRecord();
        
    }
    
    public List<OpportunityLineItem> getLineItems() {
        return [SELECT Id, Name, Opportunity.Name, Product2.Invoice_Description__c, Invoice_Quantity__c, UnitPrice, Recurring_Costs__c FROM OpportunityLineItem WHERE OpportunityId = :this.opp.Id ORDER BY SortOrder];
    
    }
    
    public PageReference savePDF() {
    
        String datestr = Date.Today().Format() ;
        //String dateStr =  d.format('dd/MM/yyyy') ;
        PageReference pdf = Page.CompliatricOrderForm;
        ContentWorkspace cw;
        
        Blob body;
        
        try {
            body = pdf.getContentAsPDF();
        }
        catch(VisualforceException e) {
            system.debug('In Catch Block ');
            body = Blob.valueOf('Some Text');
        }
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = body;
        cv.PathOnClient = this.opp.Name + ' ' + this.fileNameEnd + '.pdf';
        cv.Title = this.opp.Name + ' ' + this.fileNameEnd + ' ' + dateStr;
        
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId, VersionData, PathOnClient, Title FROM ContentVersion WHERE Id = : cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = this.opp.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        
        insert cdl;
        
        ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
        cw = [SELECT Id FROM ContentWorkspace WHERE Name = 'Compliatric Order Forms' LIMIT 1];
        
        if(cw != null) {
            cwd.ContentDocumentId = cv.ContentDocumentId;
            cwd.ContentWorkspaceId = cw.Id;
            insert cwd;            
        }
        
        return new PageReference('/' + this.opp.Id);

    }
  
    public PageReference saveAddOnPDF() {
    
        
        String datestr = Date.Today().Format() ;
        //String dateStr =  d.format('dd/MM/yyyy') ;
        PageReference pdf = Page.CompliatricAddOnOrderForm;
        ContentWorkspace cw;
        
        Blob body;
        
        try {
            body = pdf.getContentAsPDF();
        }
        catch(VisualforceException e) {
            system.debug('In Catch Block ');
            body = Blob.valueOf('Some Text');
        }
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = body;
        cv.PathOnClient = this.opp.Name + ' ' + this.fileNameEnd + '.pdf';
        cv.Title = this.opp.Name + ' Add On ' + this.fileNameEnd + ' ' + dateStr;
        
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId, VersionData, PathOnClient, Title FROM ContentVersion WHERE Id = : cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = this.opp.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        
        insert cdl;
        
        ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
        cw = [SELECT Id FROM ContentWorkspace WHERE Name = 'Compliatric Order Forms' LIMIT 1];
        
        if(cw != null) {
            cwd.ContentDocumentId = cv.ContentDocumentId;
            cwd.ContentWorkspaceId = cw.Id;
            insert cwd;            
        }
        
        return new PageReference('/' + this.opp.Id);

    }
  
}
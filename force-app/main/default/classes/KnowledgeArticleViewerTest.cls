@isTest
private class KnowledgeArticleViewerTest {
    static testMethod void validateKnowledgeArticleReview() {
        Knowledge__kav kav = new Knowledge__kav();
        kav.Language = 'en_us';
        kav.UrlName = 'Test-Knowledge';
        kav.Title = 'Test Knowledge';
        kav.External_URL__c = 'https://docs.google.com/';

        insert kav;
        
        ApexPages.StandardController ctl = new ApexPages.StandardController(kav);

        PageReference pr = Page.KnowledgeDisplayArticle;

        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('Id',kav.Id);

        KnowledgeArticleViewer viewer = new KnowledgeArticleViewer();
        System.assertEquals(kav.External_URL__c,viewer.getLatestKnowledgeArticle());

    }
}
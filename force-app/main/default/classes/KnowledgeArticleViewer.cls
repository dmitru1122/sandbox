public with sharing class KnowledgeArticleViewer {
    public KnowledgeArticleViewer() {

    }

        
    public string getLatestKnowledgeArticle() {
        //System.debug('### Controller: ' + this.ctrl);
        Knowledge__kav kav = new Knowledge__kav();
        String URL = '';
        String articleId = ApexPages.currentPage().getParameters().get('Id');
        //System.debug('### ArticleID ' + id);
        System.debug('### ArticleID ' + articleId);

        if(articleId != null) {
            List<Knowledge__kav> kavs = [SELECT Id, External_URL__c FROM Knowledge__kav WHERE Id = :articleId];

            if(kavs.size() > 0) {
                URL = kavs[0].External_URL__c;
            }
        }

        return URL;
    }

}
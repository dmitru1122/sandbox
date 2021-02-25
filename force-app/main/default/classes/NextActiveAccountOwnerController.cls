public class NextActiveAccountOwnerController {

    public PageReference redirectAction() {
        try {
            String accountId = ApexPages.CurrentPage().getParameters().get( 'id' );
            String type = ApexPages.CurrentPage().getParameters().get( 'type' );
            String nextAccount = '';
            if( type.equalsIgnoreCase( 'rt' ) ) nextAccount = GlobalHelpers.ButtonNextActiveAccountByRecordType( accountId );
            else nextAccount = GlobalHelpers.ButtonNextActiveAccount( accountId );

            PageReference pageRef = new PageReference( '/' + nextAccount );
            pageRef.setRedirect( true );
            return pageRef;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
			return null;
        }
	}
}
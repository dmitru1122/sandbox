global class CreateCaseFromEmail implements Messaging.InboundEmailHandler {

	private static final String SUBJECT = 'Create Case';
	
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,
																Messaging.InboundEnvelope env) {

		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
			try{
				System.debug(email.plainTextBody);
				EmailRequest request = (EmailRequest)System.JSON.deserialize(email.plainTextBody , EmailRequest.class);
				System.debug(request);
				Account acc = [Select Id, Name, Org_Id__c From Account Where Org_Id__c =: request.getOrganizationId()];
				System.debug(request.getOrganizationId());
				if(acc != null) {
					System.debug(acc);
					Case c = new Case();
					c.Account = acc;
					c.Description = email.plainTextBody;
					c.Origin = 'Email';
					c.Status = 'new';
					insert c;
					result.success = true;
				}
			}
			catch(Exception e){
				result.success = false;
				return result;
			}
    	return result;
	}

	public class EmailRequest {
		public String Manufacturer { get; set; }
		public String SDSProductName { get; set; }
		public Date NewerThanDate { get; set; }
		public String Email { get; set; }
		public String Name { get; set; }
		public String OrganizationId { get; set; }

		public EmailRequest(String Manufacturer, String SDSProductName, Date NewerThanDate, String Email, String Name, String OrganizationId) {
			this.Manufacturer = Manufacturer;
			this.SDSProductName = SDSProductName;
			this.NewerThanDate = NewerThanDate;
			this.Email = Email;
			this.Name = Name;
			this.OrganizationId = OrganizationId;
		}

		public String getOrganizationId() {
			return this.OrganizationId;
		}
	}
}
global class EmailToReportAllOrgsUsers implements Messaging.InboundEmailHandler {

	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
		final String ORGANIZATIONID = 'OrganizationId';
		final String POWERISACTIVE = 'powerIsActive';
		final String POWERISNOTACTIVE = 'powerIsNotActive';
		final String BASICISACTIVE = 'basicIsActive';
		final String BASICISNOTACTIVE = 'basicIsNotActive';
		final String OTHERISACTIVE = 'otherIsActive';
		final String OTHERISNOTACTIVE = 'otherIsNotActive';
		final String UNUSEDLICENSES = 'UnusedLicenses';

		final String PERCENTACTIVUSERS = 'percentActivUsers';

		final String TOTAL_LOGINS = 'TotalOfLlogins';
		final String LOGINS_LAST_MONTH = 'UserLastActive';



		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();


		try {
			String myPlainText = '';
			myPlainText = email.plainTextBody;
			JSONParser parser = JSON.createParser(myPlainText);

			String organizationToId = NULL;
			Integer toPowerIsActive = 0;
			Integer toPowerIsNotActive = 0;
			Integer toBasicIsActive = 0;
			Integer toBasicIsNotActive = 0;
			Integer toOtherIsActive = 0;
			Integer toOtherIsNotActive = 0;
			Integer toUnusedLicenses = 0;
			String  topercentActivUsers = '';
			Integer toTotalOfLloginsThatMonth = 0;
			Integer toUserThatMonthActive = 0;



			while (parser.nextToken() !=NULL) {
				if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
					if (parser.getText() == ORGANIZATIONID) {
						parser.nextToken();
						organizationToId = parser.getText();

					} else if (parser.getText() == POWERISACTIVE) {
						parser.nextToken();
						toPowerIsActive = parser.getIntegerValue();

					} else if (parser.getText() == POWERISNOTACTIVE) {
						parser.nextToken();
						toPowerIsNotActive = parser.getIntegerValue();

					} else if (parser.getText() == BASICISACTIVE) {
						parser.nextToken();
						toBasicIsActive = parser.getIntegerValue();

					} else if (parser.getText() == BASICISNOTACTIVE) {
						parser.nextToken();
						toBasicIsNotActive = parser.getIntegerValue();

					} else if (parser.getText() == OTHERISACTIVE) {
						parser.nextToken();
						toOtherIsActive = parser.getIntegerValue();

					} else if (parser.getText() == OTHERISNOTACTIVE) {
						parser.nextToken();
						toOtherIsNotActive = parser.getIntegerValue();

					} else if (parser.getText() == UNUSEDLICENSES) {
						parser.nextToken();
						toUnusedLicenses = parser.getIntegerValue();

					} else if (parser.getText() == PERCENTACTIVUSERS) {
						parser.nextToken();
						topercentActivUsers = parser.getText();

					} else if (parser.getText() == TOTAL_LOGINS) {
						parser.nextToken();
						toTotalOfLloginsThatMonth = parser.getIntegerValue();

					} else if (parser.getText() == LOGINS_LAST_MONTH) {
						parser.nextToken();
						toUserThatMonthActive = parser.getIntegerValue();
					}
				}
			}


			if (organizationToId != NULL && String.isNotBlank(organizationToId)) {
				String subOrganizationToId = organizationToId.left(15);

				List<Account> listAccount = [
					SELECT Id
					FROM Account
					WHERE Org_Id__c =:organizationToId
					OR Org_Id__c =:subOrganizationToId
				];

				if (listAccount.size() >0) {

					ReportToUsersAllOrgs__c newReport = new ReportToUsersAllOrgs__c();
					newReport.Account__c = listAccount[0].Id;
					newReport.Name = String.valueOf(System.today());
					newReport.DateReport__c = System.today();

					newReport.Unused_Licenses__c = toUnusedLicenses;
					newReport.LoginByUser__c = topercentActivUsers;

					newReport.ActiveBasicUsers__c = toBasicIsActive;
					newReport.InActiveBasicUsers__c = toBasicIsNotActive;

					newReport.ActivePowerUsers__c = toPowerIsActive;
					newReport.InActivePowerUsers__c = toPowerIsNotActive;

					newReport.ActiveOtherUsers__c = toOtherIsActive;
					newReport.InActiveOtherUsers__c = toOtherIsNotActive;

					newReport.Total_of_logins_that_month__c = toTotalOfLloginsThatMonth;
					newReport.Unique_Users_Logged__c = toUserThatMonthActive;


					insert newReport;
				}

			}
			result.success = true;

		} catch(Exception e){
			result.success = false;
			result.message = e.getMessage() + e.getStackTraceString();
		}
		return result;
	}
}